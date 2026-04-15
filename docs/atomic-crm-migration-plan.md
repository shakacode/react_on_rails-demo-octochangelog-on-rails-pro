# Atomic CRM Migration Plan

## Goal

Prepare the next high-value React on Rails Pro showcase migration:

- `shakacode/react_on_rails-demo-atomic-crm`

This document turns the high-level recommendation into a concrete implementation plan grounded in
the current `marmelab/atomic-crm` codebase.

## Source Snapshot

- Upstream repo: [marmelab/atomic-crm](https://github.com/marmelab/atomic-crm)
- License: MIT
- Upstream app description: "A full-featured CRM built with React, shadcn/ui, and Supabase."
- Demo URL: [marmelab.com/atomic-crm-demo](https://marmelab.com/atomic-crm-demo)

## Upstream Baseline Check

Local sanity check performed during this planning pass:

- `npm install`
- `npm run build`

The upstream production build completed successfully and emitted:

- main app bundle: about `2.03 MB` minified JavaScript before gzip
- deal list chunk: about `137.57 kB` minified JavaScript before gzip
- main stylesheet: about `119.97 kB`

Why this matters:

- Atomic CRM already has enough client-side surface area that a Rails + RSC reshape can tell a
  strong bundle-discipline story
- the deal workflow is large enough to justify a dedicated client island
- dashboard, list, and show pages are good candidates to move more composition work to the server

## What Atomic CRM Currently Is

Atomic CRM is not just a dashboard template. It is a real CRM application with:

- contacts, companies, deals, notes, tags, tasks, and sales users
- a deal pipeline displayed as a Kanban board
- activity history and aggregated list/detail views
- onboarding and multiple auth flows
- CSV import/export
- settings and profile screens
- inbound email processing and user-management edge functions

The current architecture is:

- React 19 + TypeScript + Vite frontend
- React Router v7 for application routing
- React Query for data fetching and caching
- `ra-core` and Shadcn Admin Kit for admin application structure
- Supabase for PostgreSQL, REST API, auth, storage, triggers, and edge functions

## Why This Is The Best Next Demo

Octochangelog proves a public, server-heavy read surface. Atomic CRM would prove something the
current ShakaCode demo set does not show as well:

- authenticated CRUD
- internal-tool and backoffice workflows
- multi-resource navigation
- dashboard, index, show, and edit surfaces
- a real client-heavy interaction area inside a Rails-owned app shell

That makes Atomic CRM the strongest next complement to:

- `react_on_rails-demo-octochangelog-on-rails-pro`
- `react_on_rails-hacker-news-app`
- `gumroad-rsc`

## Recommended Migration Thesis

Do **not** treat this as a one-to-one port of a Supabase-backed SPA into Rails.

The stronger React on Rails Pro story is:

- Rails replaces Supabase as the application shell and stateful backend
- Rails owns auth, sessions, policies, persistence, jobs, inbound email processing, and API boundaries
- React Server Components handle the dashboard, show pages, lists, and activity timelines where
  server composition is valuable
- client islands remain for the highest-interaction surfaces, especially the deal pipeline board,
  filters, inline edits, uploads, and import flows

This is a reshape, not just a transport rewrite.

## Upstream Architecture To Replace Or Re-map

### Replace With Rails

- Supabase Auth
  - replace with Rails session auth
- Supabase REST data provider
  - replace with Rails controllers, models, and queries
- Supabase storage
  - replace with Active Storage
- Supabase triggers and views
  - replace with Rails models, SQL views where useful, and service objects
- Supabase edge functions
  - replace with Rails controllers, background jobs, and mail/webhook handlers

### Keep As React Client Islands

- Kanban board drag and drop for deals
- high-interaction filters and list controls
- CSV import flows if the UX is kept rich and incremental
- inline edit interactions where optimistic UI matters
- mobile-specific interaction surfaces if included in scope

### Strong RSC Candidates

- dashboard summary cards and recent activity
- contacts list and contact show page
- companies list and company show page
- sales/user management index and detail pages
- read-heavy settings and configuration views
- aggregated history timelines and related-record panels

## Proposed Demo Scope

The first version should be narrower than upstream Atomic CRM. A good v1 scope is:

### Include

- dashboard
- contacts
- companies
- deals
- tasks
- notes/activity timeline
- login/logout and a simple seeded demo user flow
- enough seed/demo data to make the UI credible

### Defer

- full SSO matrix
- full API/integration story
- inbound email processing
- storage-heavy attachment workflows
- all customization surfaces
- all mobile-specific flows

This keeps the migration positioned as a strong product-shaped demo without turning it into a full CRM product build.

## Rails Architecture Recommendation

### Core Rails Pieces

- models:
  - `Contact`
  - `Company`
  - `Deal`
  - `Task`
  - `Note`
  - `User`
  - optionally `Tag`, `DealStage`, `DealCategory`
- controllers:
  - dashboard
  - contacts
  - companies
  - deals
  - tasks
  - sessions
  - imports
- services:
  - dashboard aggregation
  - activity timeline assembly
  - import parsing
  - kanban/pipeline updates
- persistence:
  - PostgreSQL, not SQLite, for this demo

### React on Rails Pro Shape

- Rails routes remain canonical
- `.erb` views stay thin and mount one or more RSC entrypoints
- use server components for page composition and heavy data assembly
- isolate deal-board interactions into explicit client components
- keep the client bundle intentionally narrow on non-board pages

## Suggested Route Plan

### Rails Routes

- `/`
  - dashboard
- `/contacts`
  - contacts index
- `/contacts/:id`
  - contact show
- `/companies`
  - companies index
- `/companies/:id`
  - company show
- `/deals`
  - deals index plus pipeline board island
- `/tasks`
  - tasks index
- `/login`
  - login page

### Nice To Have Later

- `/settings`
- `/imports`
- `/sales`

## Data And Demo Strategy

Atomic CRM only works as a showcase if it has believable data.

Recommended seed shape:

- 200-500 contacts
- 30-50 companies
- 20-40 deals distributed across stages
- 50-100 tasks
- enough notes/activity to make timelines interesting

The goal is to make:

- dashboard summaries nontrivial
- list pages dense enough to feel real
- the deal board visually convincing

## Benchmark Targets

This repo should not chase "faster than every SPA" claims. The benchmark story should be:

- dashboard first render is server-composed and fast enough to feel Rails-native
- show/list pages stream useful HTML before client hydration
- the deal board island keeps bundle growth contained to the page that truly needs it

Useful benchmark artifacts for the eventual repo:

- warmed dashboard request timings
- warmed contact show timings
- warmed deals page timings
- client bundle size for the deal-board island
- client bundle size for the rest of the shared runtime

## Likely Technical Risks

### 1. Deal Board Scope Creep

The Kanban surface is the part most likely to drag the project into a full SPA rewrite if it is not
contained as an island.

### 2. Reproducing Supabase-Specific Behavior

Upstream uses:

- auth flows
- database views
- triggers
- edge functions

Those all need Rails-native replacements, not just thin wrappers.

### 3. Over-scoping Auth

For a showcase repo, full enterprise SSO is not worth the complexity unless auth itself is the story.

### 4. Import/Export Complexity

CSV import is useful for credibility, but easy to overbuild.

## Recommended Build Sequence

1. Create the repo: `shakacode/react_on_rails-demo-atomic-crm`
2. Scaffold Rails + React on Rails Pro + PostgreSQL
3. Establish auth, layout shell, and seeded data
4. Implement dashboard as a streamed RSC page
5. Implement contacts and companies index/show flows
6. Implement deals page with a client-island board
7. Implement tasks and activity timeline
8. Add benchmarks, screenshots, and positioning docs

## Definition Of Done For V1

The v1 migration is good enough when it proves:

- Rails is the application shell
- React on Rails Pro handles a real internal-tool application shape
- RSC adds value on dashboard/list/show composition
- the deal board is interactive without forcing the whole app into a client SPA
- the repo has strong docs, screenshots, and benchmark notes like Octochangelog

## Default Recommendation

If the next repo starts now, keep the name:

- `shakacode/react_on_rails-demo-atomic-crm`

And keep the positioning disciplined:

- "Rails-owned CRM demo with RSC dashboard/list/show pages and a client-island Kanban pipeline"
