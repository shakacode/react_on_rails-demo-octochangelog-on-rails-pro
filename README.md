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

The repo now proves both the React on Rails Pro plumbing and the first real migration slice:

- Rails 8 app scaffolded with PostgreSQL
- React on Rails Pro + Shakapacker wired in locally
- seeded Rails models for companies, contacts, deals, tasks, and notes
- `/` streams a query-backed CRM dashboard through React on Rails Pro
- `/contacts` streams a Rails-backed contacts directory with account rollups
- `/contacts/:id` streams a contact detail page with related tasks, deals, and notes
- the deal board mounts as a client island beside the streamed server-rendered surface
- the Node renderer, RSC bundle, and manifest flow are working locally

This is still an early migration, not the finished CRM port. The home route is now a real Rails-backed screen with
seeded data, but most secondary routes from the source app are not ported yet.

## Quick Start

### Prerequisites

- Ruby `3.4.x`
- Node.js `24.8.0`
- PostgreSQL

### Install and Run

```bash
bundle install
npm install
bin/rails db:prepare db:seed
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
- `/contacts` renders the streamed contacts directory
- `/contacts/:id` renders the streamed contact detail page
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
- `app/controllers/contacts_controller.rb` owns the list/show contact routes
- `app/views/home/index.html.erb` mounts the RSC surface and the client island
- `app/views/contacts/*.html.erb` mount the streamed contacts routes
- `app/presenters/atomic_crm/home_page_payload.rb` builds the dashboard payload from Rails models
- `app/presenters/atomic_crm/contacts_page_payload.rb` builds the contacts directory props
- `app/presenters/atomic_crm/contact_page_payload.rb` builds the contact detail props
- `app/javascript/src/atomic_crm/components/AtomicCrmAppChrome.tsx` provides the shared product shell
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmHomePage.tsx` is the streamed server component
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmContactsPage.tsx` is the streamed contacts index route
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmContactShowPage.tsx` is the streamed contact detail route
- `app/javascript/src/atomic_crm/ror_components/AtomicCrmDealBoardIsland.tsx` is the interactive client island
- `client/node-renderer.js` configures the React on Rails Pro Node renderer

## Performance Snapshot

These are still early measurements, but they now reflect a seeded Rails-backed dashboard rather than a placeholder shell.

### Upstream Atomic CRM Source Baseline

From the source app build captured during migration planning:

- main bundle: about `2.03 MB`
- `DealList` chunk: about `137.57 kB`
- stylesheet: about `119.97 kB`

### Current Local Bootstrap Build

From the current local dashboard + contacts slice:

- `AtomicCrmHomePage.js`: `1,539 B` (`556 B` gzip)
- `AtomicCrmContactsPage.js`: `1,571 B` (`561 B` gzip)
- `AtomicCrmContactShowPage.js`: `1,595 B` (`569 B` gzip)
- `AtomicCrmDealBoardIsland.js`: `5,035 B` (`1,304 B` gzip)
- `application.css`: `9,939 B` (`2,418 B` gzip)
- `rsc-bundle.js`: `419,882 B` (`70,894 B` gzip)
- `server-bundle.js`: `2,189,453 B`
- warm local `/` request: about `26-33 ms` total in the latest five-run sample
- warm local `/contacts` request: about `26-42 ms` total after the first request
- warm local `/contacts/:id` request: about `25-35 ms` total after the first request
- latest Rails logs: `/` completed in `13 ms`, `/contacts` in `15-21 ms`, `/contacts/:id` in `11 ms`

The apples-to-oranges caveat matters here:

- the upstream numbers come from the full source app build
- the current numbers come from a local Rails-backed dashboard slice with seeded CRM data
- dev-mode vendor bundles are intentionally not the headline metric

More detail and the exact measurement commands are in [docs/performance-notes.md](docs/performance-notes.md).

## Why This Repo Is Useful

This repo is meant to answer the question, "What does React on Rails Pro buy us on a real product-shaped app?"

- It shows that Rails can stay in charge of application ownership instead of becoming a thin API shell.
- It shows that RSC can own the expensive, data-heavy rendering surfaces.
- It shows that highly interactive UI can stay isolated instead of forcing the whole app into a client SPA.
- It shows how Rails presenters and Active Record queries can feed RSC surfaces directly without introducing a separate API layer.
- It now shows a realistic master/detail CRM route pair instead of only a dashboard shell.
- It gives ShakaCode a demo that looks closer to internal SaaS software than a marketing page or feed reader.

## Migration Roadmap

Short term:

- port companies and deals onto the same streamed shell pattern
- expand from seeded contacts into richer company and deal detail pages
- add route-level comparisons showing how little client JavaScript each read-heavy page ships
- keep the pipeline board as an explicit client island

Longer term:

- add auth, search, richer record detail pages, and more realistic CRM workflows
- produce production-mode measurements after more than one real route is ported
- compare route-level JavaScript shipped versus the source SPA as the migrated surface grows
