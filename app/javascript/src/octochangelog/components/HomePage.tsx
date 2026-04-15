import React from "react";

import type { HomePageProps } from "../lib/types";

export default function HomePage({
  comparePath,
  distinctRepositories,
  featuredComparisons,
  recentRuns,
  sourceName,
  sourceUrl,
  totalComparisons,
}: HomePageProps) {
  const statFormatter = new Intl.NumberFormat("en-US");

  return (
    <main className="octo-page">
      <section className="octo-hero">
        <div className="octo-hero-copy">
          <p className="octo-eyebrow">React on Rails Pro showcase migration</p>
          <h1>Octochangelog is the best TanStack showcase candidate for a Rails + RSC port.</h1>
          <p className="octo-lead">
            It is a real product, it is MIT-licensed, and its hot path is exactly what React Server
            Components should absorb: server-side GitHub fetching, markdown normalization, release
            grouping, and rich rendering with almost no client JavaScript.
          </p>

          <div className="octo-hero-actions">
            <a className="octo-button octo-button--primary" href={comparePath}>
              Open the comparison studio
            </a>
            <a className="octo-button octo-button--ghost" href={sourceUrl} rel="noreferrer" target="_blank">
              View the original {sourceName}
            </a>
          </div>
        </div>

        <div className="octo-hero-panel">
          <div className="octo-stat-grid">
            <article className="octo-stat-card">
              <span>Comparisons logged</span>
              <strong>{statFormatter.format(totalComparisons)}</strong>
            </article>
            <article className="octo-stat-card">
              <span>Distinct repos explored</span>
              <strong>{statFormatter.format(distinctRepositories)}</strong>
            </article>
            <article className="octo-stat-card">
              <span>Client-side workload</span>
              <strong>Filters only</strong>
            </article>
            <article className="octo-stat-card">
              <span>Heavy markdown parsing</span>
              <strong>Server-only</strong>
            </article>
          </div>
        </div>
      </section>

      <section className="octo-section">
        <div className="octo-section-header">
          <p className="octo-eyebrow">Why this project fits</p>
          <h2>The migration exercises the exact boundaries React on Rails Pro should dominate.</h2>
        </div>

        <div className="octo-card-grid">
          <article className="octo-card">
            <h3>Rails owns the integration edges</h3>
            <p>
              GitHub OAuth, caching, routing, and history persistence all live in Rails where secrets
              and sessions belong.
            </p>
          </article>
          <article className="octo-card">
            <h3>RSC owns the expensive presentation tier</h3>
            <p>
              Release parsing, section grouping, markdown rendering, syntax highlighting, and result
              summaries stay on the server and never inflate the browser bundle.
            </p>
          </article>
          <article className="octo-card">
            <h3>Client React stays purposeful</h3>
            <p>
              The browser only hydrates the repository search, version selectors, and auth controls,
              which is a much cleaner client/server split than the original TanStack app.
            </p>
          </article>
        </div>
      </section>

      <section className="octo-section">
        <div className="octo-section-header">
          <p className="octo-eyebrow">Featured runs</p>
          <h2>Launch a comparison that shows the system doing real work.</h2>
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
          <h2>Recent comparison runs persist in SQLite to prove the app is more than a static demo.</h2>
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
