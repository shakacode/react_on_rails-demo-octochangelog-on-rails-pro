import React from "react";

import type { HomePageProps } from "../lib/types";

const FEATURES = [
  {
    icon: "swap",
    title: "Compare releases easily",
    description:
      "Sifting through changelogs on GitHub taking too much time? Let Octochangelog put the list of changes in a single view!",
  },
  {
    icon: "share",
    title: "Share changelogs",
    description: "Want to let your team review the changes in a dependency? Give them a link!",
  },
  {
    icon: "fire",
    title: "Don't miss breaking changes",
    description:
      "Octochangelog finds all breaking changes, and lists them at the top. You cannot miss those pesky gotchas now!",
  },
  {
    icon: "sort",
    title: "No manual sorting",
    description:
      "Want a list of major, minor and patch level changes? Octochangelog groups changes into categories for you!",
  },
  {
    icon: "tag",
    title: "Changes per version",
    description: "Want to know which version introduced a certain change? Octochangelog labels each change with the version number.",
  },
];

export default function HomePage({
  comparePath,
  featuredComparisons,
  recentRuns,
  sourceName,
  sourceUrl,
}: HomePageProps) {
  const exampleComparison = featuredComparisons[0];

  return (
    <main className="octo-page">
      <section className="octo-hero">
        <img className="octo-hero-mascot" src="/mascot-logo.png" alt="" width="600" height="600" />
        <div className="octo-hero-copy">
          <p className="octo-eyebrow">Rails + RSC edition</p>
          <h1>Octochangelog</h1>
          <h2>Compare GitHub changelogs in a single view</h2>
          <p className="octo-lead">
            Pick a repository and two versions. Octochangelog gathers the release notes, groups the
            important sections, and gives your team a link they can review together.
          </p>

          <div className="octo-action-row">
            <a className="octo-button octo-button--primary" href={comparePath}>
              Compare changelogs
            </a>
            {exampleComparison ? (
              <a className="octo-button octo-button--secondary" href={exampleComparison.href}>
                See example
              </a>
            ) : null}
          </div>
        </div>
      </section>

      <section className="octo-powered-strip" aria-label="Powered by">
        <div>
          <span>Powered by React on Rails Pro, React Server Components, and Control Plane</span>
          <strong>Rails owns routing, OAuth, persistence, and deploys while RSC streams the heavy changelog rendering.</strong>
        </div>
        <a href={sourceUrl} rel="noreferrer" target="_blank">
          View the original {sourceName}
        </a>
      </section>

      <section className="octo-section">
        <div className="octo-section-header">
          <p className="octo-eyebrow">What Octochangelog does</p>
          <h2>Everything that makes release reviews easier, with the Rails pieces underneath.</h2>
        </div>

        <div className="octo-feature-grid">
          {FEATURES.map((feature) => (
            <article className="octo-feature-card" key={feature.title}>
              <span className={`octo-feature-icon octo-feature-icon--${feature.icon}`} aria-hidden="true" />
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="octo-section">
        <div className="octo-section-header">
          <p className="octo-eyebrow">Try a real comparison</p>
          <h2>Start with examples that exercise grouped release notes.</h2>
        </div>

        <div className="octo-card-grid">
          {featuredComparisons.map((comparison) => (
            <a className="octo-card octo-card--interactive" href={comparison.href} key={comparison.href}>
              <div className="octo-pill-row">
                <span className="octo-pill">{comparison.repo}</span>
                <span className="octo-pill octo-pill--soft">
                  {comparison.from} to {comparison.to}
                </span>
              </div>
              <h3>{comparison.label}</h3>
              <p>{comparison.note}</p>
            </a>
          ))}
        </div>
      </section>

      <section className="octo-section">
        <div className="octo-section-header">
          <p className="octo-eyebrow">Rails-backed activity</p>
          <h2>Recent comparisons are persisted by Rails.</h2>
        </div>

        <div className="octo-history-card">
          {recentRuns.length > 0 ? (
            <ul className="octo-history-list">
              {recentRuns.map((run) => (
                <li className="octo-history-row" key={run.id}>
                  <div>
                    <a className="octo-history-link" href={run.href}>
                      {run.repositoryFullName}
                    </a>
                    <p>
                      {run.fromVersion} to {run.toVersion}
                    </p>
                  </div>
                  <span>{run.createdAtLabel}</span>
                </li>
              ))}
            </ul>
          ) : (
            <div className="octo-empty-state">
              <h3>No comparisons recorded yet</h3>
              <p>Run a few real comparisons and they will start showing up here automatically.</p>
            </div>
          )}
        </div>
      </section>
    </main>
  );
}
