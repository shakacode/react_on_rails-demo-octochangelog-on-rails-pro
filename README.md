# Octochangelog on Rails Pro

This repository is a full React on Rails Pro + React Server Components migration of
[Octochangelog](https://github.com/Belco90/octochangelog), one of the TanStack showcase projects.

## Why this project

Octochangelog was the best showcase candidate because it is:

- A real product instead of a starter template.
- MIT licensed, so the migration can stand on its own.
- Dominated by server-heavy work: GitHub fetches, markdown parsing, changelog grouping, and rich rendering.
- A clean fit for a Rails + RSC split where the browser only hydrates the controls that truly need JavaScript.

## What was migrated

- Rails now owns routing, sessions, OAuth callback handling, caching, and persisted comparison history.
- React on Rails Pro streams the comparison results as React Server Components.
- The compare form is a standalone client React island mounted with `react_component`.
- The expensive release-note processing stays on the server and does not ship parsing libraries to the browser.

## Local setup

Requirements:

- Ruby 3.4+
- Node 24+
- SQLite 3

Install and boot:

```bash
bundle install
npm install
bin/rails db:prepare
bin/rails react_on_rails:generate_packs
bin/shakapacker
```

Run the app in two terminals:

```bash
bundle exec rails s -p 3000
RENDERER_PORT=3800 node client/node-renderer.js
```

Then open [http://127.0.0.1:3000](http://127.0.0.1:3000).

If you use `overmind`, `bin/dev` is also available.

## Optional GitHub OAuth

For higher GitHub API limits, set these in `.env`:

```bash
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
```

Without them, the app still works against public GitHub data.

## Architecture

- `app/controllers/compare_controller.rb`: Rails-side orchestration for GitHub fetches and comparison persistence.
- `app/services/github/client.rb`: GitHub REST and OAuth wrapper plus release-range filtering.
- `app/javascript/src/octochangelog/components/CompareFilters.tsx`: client island for repo search and version selection.
- `app/javascript/src/octochangelog/components/CompareResults.tsx`: streamed RSC results renderer.
- `app/models/comparison_run.rb`: persisted history of compare requests.

## Verification

Build and tests run clean:

```bash
bin/shakapacker
bin/rails test
```

Local smoke checks completed against a live Rails server + node renderer:

- Home page SSR rendered successfully.
- Compare page SSR rendered successfully with `repo=octokit/rest.js&from=22.0.0&to=latest`.
- Browser verification confirmed the filter island hydrated and populated release selectors.

Local timing snapshot from `curl` against the dev server on April 14, 2026:

- `/`: ~32-44 ms total
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: ~348-431 ms total in unauthenticated mode

Generated asset snapshot:

- `public/packs/js/generated/CompareFiltersStandalone.js`: 1,872 bytes
- `public/packs/js/client0.js`: 21,899 bytes
- `public/packs/js/generated/OctochangelogCompareResultsPage.js`: 1,597 bytes
- `public/packs/css/application.css`: 13,648 bytes
