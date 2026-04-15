import React from "react";
import clsx from "clsx";
import {
  startTransition,
  useDeferredValue,
  useEffect,
  useRef,
  useState,
} from "react";

import { buildAuthStartPath, isRepositorySlug } from "../lib/format";

import type { ReleaseOption, RepositorySearchResult } from "../lib/types";

type CompareFiltersProps = {
  authEnabled: boolean;
  authenticated: boolean;
  comparePath: string;
  csrfToken: string;
  initialFrom?: string | null;
  initialRepo?: string | null;
  initialTo?: string | null;
  loginPathBase: string;
  logoutPath: string;
  releasesEndpoint: string;
  repositoriesEndpoint: string;
};

type RepositoriesResponse = { error?: string; items: RepositorySearchResult[] };
type ReleasesResponse = { error?: string; items: ReleaseOption[] };
type LoadState = "error" | "idle" | "loading" | "ready";

async function readJson<T>(url: string, signal: AbortSignal): Promise<T> {
  const response = await fetch(url, {
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
    },
    signal,
  });

  const payload = (await response.json()) as T & { error?: string };
  if (!response.ok) {
    throw new Error(payload.error || `Request failed with status ${response.status}`);
  }

  return payload as T;
}

export default function CompareFilters({
  authEnabled,
  authenticated,
  comparePath,
  csrfToken,
  initialFrom,
  initialRepo,
  initialTo,
  loginPathBase,
  logoutPath,
  releasesEndpoint,
  repositoriesEndpoint,
}: CompareFiltersProps) {
  const [repositoryQuery, setRepositoryQuery] = useState(initialRepo ?? "");
  const [fromVersion, setFromVersion] = useState(initialFrom ?? "");
  const [toVersion, setToVersion] = useState(initialTo ?? "");
  const [repositorySuggestions, setRepositorySuggestions] = useState<RepositorySearchResult[]>([]);
  const [repositoryState, setRepositoryState] = useState<LoadState>("idle");
  const [repositoryError, setRepositoryError] = useState("");
  const [releaseOptions, setReleaseOptions] = useState<ReleaseOption[]>([]);
  const [releaseState, setReleaseState] = useState<LoadState>("idle");
  const [releaseError, setReleaseError] = useState("");
  const deferredRepositoryQuery = useDeferredValue(repositoryQuery);
  const lastResolvedRepository = useRef((initialRepo ?? "").trim());

  const normalizedRepositoryQuery = repositoryQuery.trim();
  const currentAuthPath = buildAuthStartPath(loginPathBase, {
    from: fromVersion || undefined,
    repo: normalizedRepositoryQuery || undefined,
    to: toVersion || undefined,
  });

  const fromOptions = releaseOptions.length > 1 ? releaseOptions.slice(1) : [];
  const toOptions = releaseOptions.length
    ? [
        {
          id: -1,
          name: `Latest (${releaseOptions[0].version})`,
          tagName: "latest",
          url: releaseOptions[0].url,
          version: "latest",
        },
        ...releaseOptions,
      ]
    : [];

  useEffect(() => {
    const query = deferredRepositoryQuery.trim();
    if (query.length < 2) {
      startTransition(() => {
        setRepositorySuggestions([]);
        setRepositoryState("idle");
        setRepositoryError("");
      });
      return;
    }

    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => {
      void (async () => {
        setRepositoryState("loading");
        setRepositoryError("");

        const url = new URL(repositoriesEndpoint, window.location.origin);
        url.searchParams.set("q", query);

        try {
          const payload = await readJson<RepositoriesResponse>(url.toString(), controller.signal);
          startTransition(() => {
            setRepositorySuggestions(payload.items);
            setRepositoryState("ready");
          });
        } catch (error) {
          if ((error as Error).name === "AbortError") {
            return;
          }

          startTransition(() => {
            setRepositorySuggestions([]);
            setRepositoryState("error");
            setRepositoryError((error as Error).message);
          });
        }
      })();
    }, 180);

    return () => {
      controller.abort();
      window.clearTimeout(timeoutId);
    };
  }, [deferredRepositoryQuery, repositoriesEndpoint]);

  useEffect(() => {
    if (!isRepositorySlug(normalizedRepositoryQuery)) {
      startTransition(() => {
        setReleaseOptions([]);
        setReleaseState("idle");
        setReleaseError("");
      });
      return;
    }

    if (
      lastResolvedRepository.current &&
      lastResolvedRepository.current !== normalizedRepositoryQuery
    ) {
      startTransition(() => {
        setFromVersion("");
        setToVersion("");
      });
    }

    const controller = new AbortController();
    void (async () => {
      setReleaseState("loading");
      setReleaseError("");

      const url = new URL(releasesEndpoint, window.location.origin);
      url.searchParams.set("repo", normalizedRepositoryQuery);

      try {
        const payload = await readJson<ReleasesResponse>(url.toString(), controller.signal);
        startTransition(() => {
          setReleaseOptions(payload.items);
          setReleaseState("ready");
          setReleaseError("");
          lastResolvedRepository.current = normalizedRepositoryQuery;
          setFromVersion((current) =>
            payload.items.some((option) => option.version === current) ? current : "",
          );
          setToVersion((current) => {
            const hasCurrent =
              current === "latest" || payload.items.some((option) => option.version === current);
            return hasCurrent ? current : payload.items.length > 0 ? "latest" : "";
          });
        });
      } catch (error) {
        if ((error as Error).name === "AbortError") {
          return;
        }

        startTransition(() => {
          setReleaseOptions([]);
          setReleaseState("error");
          setReleaseError((error as Error).message);
        });
      }
    })();

    return () => controller.abort();
  }, [normalizedRepositoryQuery, releasesEndpoint]);

  const releaseHelpText = (() => {
    if (!normalizedRepositoryQuery) {
      return "Pick a repository to load version options.";
    }

    if (!isRepositorySlug(normalizedRepositoryQuery)) {
      return "Use the owner/repo format once you choose a repository.";
    }

    if (releaseState === "loading") {
      return "Loading stable releases from GitHub through Rails…";
    }

    if (releaseState === "error") {
      return releaseError;
    }

    if (releaseOptions.length === 0) {
      return "No stable releases were found for this repository.";
    }

    return `${releaseOptions.length} stable releases are available for this repository.`;
  })();

  const submitDisabled =
    !isRepositorySlug(normalizedRepositoryQuery) ||
    !fromVersion ||
    !toVersion ||
    releaseState === "loading";

  return (
    <section className="octo-filter-card">
      <div className="octo-filter-header">
        <div>
          <p className="octo-eyebrow">Client-side island</p>
          <h2>Drive the comparison from the browser without hydrating the results zone.</h2>
        </div>
        <span
          className={clsx("octo-pill", authenticated ? "octo-pill--success" : "octo-pill--soft")}
        >
          {authenticated ? "GitHub authorized" : "Public GitHub mode"}
        </span>
      </div>

      <form action={comparePath} className="octo-form-grid" method="get">
        <label className="octo-field">
          <span>Repository</span>
          <input
            autoComplete="off"
            name="repo"
            onChange={(event) => setRepositoryQuery(event.target.value)}
            placeholder="owner/repo or search by name"
            type="text"
            value={repositoryQuery}
          />
        </label>

        <label className="octo-field">
          <span>From version</span>
          <select
            disabled={releaseOptions.length === 0 || releaseState === "loading"}
            name="from"
            onChange={(event) => setFromVersion(event.target.value)}
            value={fromVersion}
          >
            <option value="">Choose a release</option>
            {fromOptions.map((option) => (
              <option key={`${option.id}-${option.version}`} value={option.version}>
                {option.version}
              </option>
            ))}
          </select>
        </label>

        <label className="octo-field">
          <span>To version</span>
          <select
            disabled={releaseOptions.length === 0 || releaseState === "loading"}
            name="to"
            onChange={(event) => setToVersion(event.target.value)}
            value={toVersion}
          >
            <option value="">Choose a release</option>
            {toOptions.map((option) => (
              <option key={`${option.id}-${option.version}`} value={option.version}>
                {option.name ?? option.version}
              </option>
            ))}
          </select>
        </label>

        <button className="octo-button octo-button--primary" disabled={submitDisabled} type="submit">
          Compare releases
        </button>
      </form>

      <p className="octo-help-text">{releaseHelpText}</p>

      {repositorySuggestions.length > 0 ? (
        <div className="octo-suggestion-grid">
          {repositorySuggestions.slice(0, 4).map((repository) => (
            <button
              className="octo-suggestion"
              key={repository.id}
              onClick={() => setRepositoryQuery(repository.fullName)}
              type="button"
            >
              <strong>{repository.fullName}</strong>
              <span>{repository.description || "No description from GitHub."}</span>
              <small>
                {repository.language || "Unknown language"} · {repository.stargazersCount ?? 0} stars
              </small>
            </button>
          ))}
        </div>
      ) : null}

      {repositoryState === "error" ? <p className="octo-error-note">{repositoryError}</p> : null}

      <div className="octo-auth-callout">
        <div>
          <h3>GitHub authorization</h3>
          <p>
            When OAuth is enabled, Rails keeps the token in the encrypted session and uses it for both
            the version selector API and the server-side comparison fetch.
          </p>
        </div>

        {authenticated ? (
          <form action={logoutPath} method="post">
            <input name="authenticity_token" type="hidden" value={csrfToken} />
            <input name="_method" type="hidden" value="delete" />
            <button className="octo-button octo-button--ghost" type="submit">
              Sign out GitHub
            </button>
          </form>
        ) : authEnabled ? (
          <a className="octo-button octo-button--ghost" href={currentAuthPath}>
            Authorize with GitHub
          </a>
        ) : (
          <p className="octo-help-text">
            Set <code>GITHUB_CLIENT_ID</code> and <code>GITHUB_CLIENT_SECRET</code> to enable OAuth.
          </p>
        )}
      </div>
    </section>
  );
}
