# React on Rails Demo: Atomic CRM on Rails Pro

This repository bootstraps the next product-shaped React on Rails Pro demo:
`shakacode/react_on_rails-demo-atomic-crm`.

The source inspiration is [`marmelab/atomic-crm`](https://github.com/marmelab/atomic-crm), a React CRM app that
already has enough product surface area to show a more convincing Rails + React Server Components migration than a
toy dashboard or a read-only feed.

## Why This Demo

Atomic CRM is a strong showcase candidate because it lets React on Rails Pro demonstrate all of the following in one
app:

- Rails-owned routing, controllers, persistence, and HTML entrypoints
- React Server Components for dashboard, lists, and record pages
- a small client island for highly interactive workflow UI such as a deal pipeline
- a realistic internal product shape instead of a brochure site or a narrow content feed

This complements the other ShakaCode demos rather than duplicating them:

- `gumroad-rsc` shows commerce-oriented RSC patterns
- `react_on_rails-hacker-news-app` shows streamed read-heavy content and nested comments
- `react_on_rails-demo-atomic-crm` is the internal SaaS/product workflow demo with an explicit server/client split

## Current Status

The bootstrap now proves the critical plumbing end to end:

- Rails 8 app scaffolded with PostgreSQL
- React on Rails Pro + Shakapacker wired in locally
- `/` streams an RSC dashboard shell through React on Rails Pro
- the deal board mounts as a client island beside the streamed server-rendered surface
- the Node renderer, RSC bundle, and manifest flow are working locally

This is still an early migration scaffold, not the finished CRM port. The current screen is intentionally a thin
placeholder that validates the architecture before the data model and source features are ported.

## Quick Start

### Prerequisites

- Ruby `3.4.x`
- Node.js `24.8.0`
- PostgreSQL

### Install and Run

```bash
bundle install
npm install
bin/rails db:prepare
bin/dev
```

Then open [http://localhost:3000](http://localhost:3000).

## Useful Development Commands

```bash
bin/dev              # Rails + dev server + server bundle + node renderer + RSC bundle
bin/dev static       # Static asset watch mode with node renderer + RSC bundle
bin/dev prod         # Development with prebuilt production-style assets
npm run typecheck
npm run bench:home
bin/rails test
```

Additional notes for local boot and troubleshooting live in [docs/development-notes.md](docs/development-notes.md).

## Routes

- `/` renders the Atomic CRM landing/dashboard shell
- `/rsc_payload/:component_name` streams the React Server Component payload used by React on Rails Pro

## Architecture

### Request Flow

1. Rails routes `/` to `HomeController#index`.
2. The controller builds props for the streamed dashboard shell and the interactive deal board.
3. The `.erb` view calls `stream_react_component(...)` for the server-rendered surface.
4. React on Rails Pro opens the RSC stream through `/rsc_payload/:component_name`.
5. The Node renderer executes `rsc-bundle.js` and streams the server component payload back to the browser.
6. Only the deal board island hydrates on the client.

### Key Repo Pieces

- `app/controllers/home_controller.rb` prepares the Rails-side props and starts the streamed view
- `app/views/home/index.html.erb` mounts the RSC surface and the client island
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmHomePage.tsx` is the streamed server component
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmDealBoardIsland.tsx` is the interactive client island
- `client/node-renderer.js` configures the React on Rails Pro Node renderer

## Performance Snapshot

These are bootstrap measurements, not final product benchmarks.

### Upstream Atomic CRM Source Baseline

From the source app build captured during migration planning:

- main bundle: about `2.03 MB`
- `DealList` chunk: about `137.57 kB`
- stylesheet: about `119.97 kB`

### Current Local Bootstrap Build

From the current local scaffold:

- `AtomicCrmHomePage.js`: `1,539 B` (`556 B` gzip)
- `AtomicCrmDealBoardIsland.js`: `4,761 B` (`1,250 B` gzip)
- `application.css`: `4,053 B` (`1,387 B` gzip)
- `rsc-bundle.js`: `393,392 B` (`68,420 B` gzip)
- warm local `/` request: about `22-23 ms` total time after the first request

The apples-to-oranges caveat matters here:

- the upstream numbers come from the full source app build
- the current numbers come from a local migration scaffold with placeholder UI
- dev-mode vendor bundles are intentionally not the headline metric

More detail and the exact measurement commands are in [docs/performance-notes.md](docs/performance-notes.md).

## Why This Repo Is Useful

This repo is meant to answer the question, "What does React on Rails Pro buy us on a real product-shaped app?"

- It shows that Rails can stay in charge of application ownership instead of becoming a thin API shell.
- It shows that RSC can own the expensive, data-heavy rendering surfaces.
- It shows that highly interactive UI can stay isolated instead of forcing the whole app into a client SPA.
- It gives ShakaCode a demo that looks closer to internal SaaS software than a marketing page or feed reader.

## Migration Roadmap

Short term:

- port contacts, companies, deals, and tasks into Rails models and seeds
- replace placeholder props with real query-backed view models
- bring over list/show pages as streamed RSC routes
- keep the pipeline board as an explicit client island

Longer term:

- add auth, search, richer record detail pages, and more realistic CRM workflows
- produce production-mode measurements after the first real feature slice is ported
- publish the repo under the `react_on_rails-demo-*` naming pattern once the initial migration slice is solid
