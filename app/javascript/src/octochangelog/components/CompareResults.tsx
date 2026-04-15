import type { RootContent } from "mdast";
import type { ComponentPropsWithoutRef, ReactNode } from "react";
import React from "react";

import {
  compareGroupKeys,
  compareReleasesByVersion,
  displayGroupTitle,
  extractVersionFromTag,
  formatCompactNumber,
  formatReadableDate,
  groupKeyForTitle,
  slugify,
} from "../lib/format";

import type { ComparisonPayload, GithubRelease, RepositorySummary } from "../lib/types";

type CompareResultsProps = {
  authEnabled: boolean;
  authenticated: boolean;
  comparison?: ComparisonPayload | null;
  from?: string | null;
  to?: string | null;
};

type ProcessedReleaseEntry = {
  content: ReactNode;
  id: string;
  originalTitle: string;
  release: GithubRelease;
};

type ProcessedReleaseGroup = {
  entries: ProcessedReleaseEntry[];
  key: string;
  title: string;
};

function firstTextValue(node: { children?: Array<{ value?: string }> }): string {
  return node.children?.find((child) => typeof child.value === "string")?.value ?? "";
}

function ExternalLink(props: ComponentPropsWithoutRef<"a">) {
  return <a {...props} rel="noreferrer" target="_blank" />;
}

async function processReleaseGroups(
  releases: GithubRelease[],
  repositoryFullName: string,
): Promise<{
  groups: ProcessedReleaseGroup[];
  processedEntryCount: number;
}> {
  const [
    { unified },
    remarkParseModule,
    remarkGfmModule,
    remarkStringifyModule,
    remarkGithubModule,
    remarkRehypeModule,
    rehypeHighlightModule,
    rehypeReactModule,
    jsxRuntime,
  ] = await Promise.all([
    import("unified"),
    import("remark-parse"),
    import("remark-gfm"),
    import("remark-stringify"),
    import("remark-github"),
    import("remark-rehype"),
    import("rehype-highlight"),
    import("rehype-react"),
    import("react/jsx-runtime"),
  ]);

  const parse = remarkParseModule.default;
  const remarkGfm = remarkGfmModule.default;
  const remarkGithub = remarkGithubModule.default;
  const remarkRehype = remarkRehypeModule.default;
  const rehypeHighlight = rehypeHighlightModule.default;
  const rehypeReact = rehypeReactModule.default;
  const stringify = remarkStringifyModule.default;
  const parseProcessor = unified().use(parse).use(remarkGfm);
  const stringifyProcessor = unified().use(stringify).use(remarkGfm);
  const groupedEntries = new Map<
    string,
    Array<Omit<ProcessedReleaseEntry, "content"> & { markdown: string }>
  >();
  let processedEntryCount = 0;

  const releasesInAscendingOrder = [...releases].sort((left, right) =>
    compareReleasesByVersion(left, right, "asc"),
  );

  const pushEntry = (
    groupKey: string,
    originalTitle: string,
    release: GithubRelease,
    nodes: RootContent[],
  ) => {
    if (nodes.length === 0) {
      return;
    }

    const markdown = stringifyProcessor.stringify({
      children: nodes,
      type: "root",
    });

    const nextEntry = {
      id: `${release.id}-${groupKey}-${processedEntryCount}`,
      markdown,
      originalTitle,
      release,
    };

    const existingEntries = groupedEntries.get(groupKey) ?? [];
    existingEntries.push(nextEntry);
    groupedEntries.set(groupKey, existingEntries);
    processedEntryCount += 1;
  };

  releasesInAscendingOrder.forEach((release) => {
    if (!release.body) {
      return;
    }

    const tree = parseProcessor.parse(release.body) as {
      children: RootContent[];
    };

    let activeGroupKey = "others";
    let activeOriginalTitle = "Other notes";
    let activeNodes: RootContent[] = [];

    tree.children.forEach((node) => {
      if (node.type === "heading" && [1, 2, 3].includes(node.depth ?? 0)) {
        pushEntry(activeGroupKey, activeOriginalTitle, release, activeNodes);

        activeOriginalTitle = firstTextValue(node);
        activeGroupKey = groupKeyForTitle(activeOriginalTitle);
        activeNodes = [];
        return;
      }

      activeNodes.push(node);
    });

    pushEntry(activeGroupKey, activeOriginalTitle, release, activeNodes);
  });

  const groups = Array.from(groupedEntries.entries())
    .sort(([left], [right]) => compareGroupKeys(left, right))
    .map(async ([key, entries]) => ({
      entries: await Promise.all(
        entries.map(async (entry) => {
          const file = await unified()
            .use(parse)
            .use(remarkGfm)
            .use(remarkGithub, { repository: repositoryFullName })
            .use(remarkRehype)
            .use(rehypeHighlight)
            .use(rehypeReact, {
              ...jsxRuntime,
              components: { a: ExternalLink },
            })
            .process(entry.markdown);

          return {
            content: file.result as ReactNode,
            id: entry.id,
            originalTitle: entry.originalTitle,
            release: entry.release,
          };
        }),
      ),
      key,
      title: displayGroupTitle(key, entries[0]?.originalTitle),
    }));

  return { groups: await Promise.all(groups), processedEntryCount };
}

function EmptyResultsState() {
  return (
    <div className="octo-empty-state octo-empty-state--tall">
      <p className="octo-eyebrow">Server components waiting</p>
      <h2>Choose a repository and version window to stream the processed changelog here.</h2>
      <p>
        The filter form is the only client island on this page. Once you submit, Rails fetches GitHub
        data and the RSC tree handles markdown grouping, rendering, and section summaries on the server.
      </p>
    </div>
  );
}

function ErrorResultsState({ message }: { message: string }) {
  return (
    <div className="octo-empty-state octo-empty-state--danger">
      <p className="octo-eyebrow">GitHub fetch failed</p>
      <h2>The comparison could not be generated.</h2>
      <p>{message}</p>
    </div>
  );
}

function NoChangesState({ totalStableReleases }: { totalStableReleases: number }) {
  return (
    <div className="octo-empty-state">
      <p className="octo-eyebrow">No releases in range</p>
      <h2>Nothing landed between those versions.</h2>
      <p>
        GitHub returned {formatCompactNumber(totalStableReleases)} stable releases for this repository,
        but the selected version window does not contain any changes.
      </p>
    </div>
  );
}

function SummaryCard({ label, value }: { label: string; value: string }) {
  return (
    <article className="octo-summary-card">
      <span>{label}</span>
      <strong>{value}</strong>
    </article>
  );
}

function StatusLine({
  authEnabled,
  authenticated,
  repository,
}: {
  authEnabled: boolean;
  authenticated: boolean;
  repository: RepositorySummary;
}) {
  if (authenticated) {
    return (
      <p className="octo-inline-note">
        Rails is using the authorized GitHub session for <strong>{repository.fullName}</strong>.
      </p>
    );
  }

  if (authEnabled) {
    return (
      <p className="octo-inline-note">
        Public GitHub rate limits are in effect for <strong>{repository.fullName}</strong>.
      </p>
    );
  }

  return (
    <p className="octo-inline-note">
      OAuth is not configured, so this demo is running in unauthenticated GitHub mode.
    </p>
  );
}

export default async function CompareResults({
  authEnabled,
  authenticated,
  comparison,
  from,
  to,
}: CompareResultsProps) {
  if (!comparison || !from || !to) {
    return <EmptyResultsState />;
  }

  if (comparison.error) {
    return <ErrorResultsState message={comparison.error} />;
  }

  if (!comparison.repository) {
    return <EmptyResultsState />;
  }

  if (comparison.releases.length === 0) {
    return <NoChangesState totalStableReleases={comparison.totalStableReleases} />;
  }

  const processedComparison = await processReleaseGroups(
    comparison.releases,
    comparison.repository.fullName,
  );
  const renderedAtLabel = new Intl.DateTimeFormat("en-US", {
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date());

  return (
    <section className="octo-results-panel">
      <div className="octo-results-overview">
        <div>
          <p className="octo-eyebrow">Server-rendered comparison</p>
          <h2>{comparison.repository.fullName}</h2>
          <p className="octo-lead octo-lead--compact">
            Showing grouped release notes between <strong>{from}</strong> and{" "}
            <strong>{to === "latest" ? "Latest" : to}</strong>.
          </p>
          <StatusLine
            authEnabled={authEnabled}
            authenticated={authenticated}
            repository={comparison.repository}
          />
        </div>

        <div className="octo-summary-grid">
          <SummaryCard label="Stable releases fetched" value={formatCompactNumber(comparison.totalStableReleases)} />
          <SummaryCard label="Releases in range" value={formatCompactNumber(comparison.releases.length)} />
          <SummaryCard label="Sections rendered" value={formatCompactNumber(processedComparison.processedEntryCount)} />
          <SummaryCard label="Rendered at" value={renderedAtLabel} />
        </div>
      </div>

      <div className="octo-group-nav">
        {processedComparison.groups.map((group) => (
          <a href={`#${slugify(group.title)}`} key={group.key}>
            {group.title}
          </a>
        ))}
      </div>

      <div className="octo-groups">
        {processedComparison.groups.map((group) => (
          <section className="octo-group" id={slugify(group.title)} key={group.key}>
            <header className="octo-group-header">
              <div>
                <p className="octo-eyebrow">Grouped from markdown headings</p>
                <h3>{group.title}</h3>
              </div>
              <span className="octo-pill octo-pill--soft">
                {formatCompactNumber(group.entries.length)} entries
              </span>
            </header>

            <div className="octo-release-stack">
              {group.entries.map((entry) => (
                <article className="octo-release-card" key={entry.id}>
                  <div className="octo-release-meta">
                    <div className="octo-pill-row">
                      <span className="octo-pill">{extractVersionFromTag(entry.release.tagName)}</span>
                      {formatReadableDate(entry.release.publishedAt) ? (
                        <span className="octo-pill octo-pill--soft">
                          {formatReadableDate(entry.release.publishedAt)}
                        </span>
                      ) : null}
                    </div>
                    <h4>
                      <a href={entry.release.url} rel="noreferrer" target="_blank">
                        {entry.release.name || entry.release.tagName}
                      </a>
                    </h4>
                  </div>

                  <div className="octo-markdown">
                    {entry.content}
                  </div>
                </article>
              ))}
            </div>
          </section>
        ))}
      </div>
    </section>
  );
}
