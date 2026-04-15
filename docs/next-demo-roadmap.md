# Next Demo Roadmap

## Goal

Extend the ShakaCode React on Rails Pro demo portfolio with a few more migrations that each prove a
different application shape. The naming convention should stay:

- `shakacode/react_on_rails-demo-<slug>`

This repo already covers the "server-heavy public read surface with a very small client island"
story. The next demos should cover other high-value page and application shapes.

## Current Portfolio Shape

- `react_on_rails-demo-octochangelog-on-rails-pro`
  Public compare/read surface, external API fetches, markdown-heavy server rendering, thin client island.
- `react_on_rails-hacker-news-app`
  Multi-route content app, feeds, nested comments, and Rails-managed rendering/caching.
- `gumroad-rsc`
  Product-experiment proof point inside a larger real application context.

## Recommended Order

### 1. `react_on_rails-demo-atomic-crm`

- Source: [TanStack showcase](https://tanstack.com/showcase/7da0d666-1732-4c3f-b91e-dc9a28673de0), [GitHub repo](https://github.com/marmelab/atomic-crm)
- Why it should be next:
  - MIT-licensed and easy to publish as a standalone ShakaCode demo
  - real authenticated CRUD and dashboard/internal-tool shape
  - complements Octochangelog instead of duplicating it
- What it would prove:
  - Rails can own auth, sessions, authorization, persistence, and background jobs
  - React on Rails Pro can handle dashboard shells, record views, and activity surfaces
  - RSC can serve server-rendered dashboards, summaries, and index/detail pages
  - client islands can stay focused on boards, filters, inline editing, and other high-interaction widgets
- Why this is the strongest portfolio addition:
  - it adds the backoffice/internal-tool story that the current demo set does not cover well
  - it is much easier to position in buyer conversations than a generic starter or component library

### 2. `react_on_rails-demo-notra`

- Source: [TanStack showcase](https://tanstack.com/showcase/d9e4e4d9-bd93-46ac-a718-86ce4cfda5d7), [GitHub repo](https://github.com/usenotra/notra)
- Why it is interesting:
  - strong workflow story around GitHub, Linear, Slack, AI drafting, and background processing
  - good fit for Rails jobs, webhook ingestion, queues, and server-rendered review surfaces
  - more ambitious than Octochangelog and more product-shaped than a starter
- What it would prove:
  - Rails can own event ingestion, jobs, scheduling, workspace settings, and integration state
  - RSC can power review queues, generated-draft views, and content history pages
  - client islands can handle editor controls, filters, approval actions, and settings screens
- Caveat:
  - the repo is AGPL-3.0, so it should only move forward if that license is acceptable for a published demo

### 3. `react_on_rails-demo-tailwindadmin`

- Source: [TanStack showcase](https://tanstack.com/showcase/78c04cee-2f8a-4a8e-845c-d3ea310eff00), [GitHub repo](https://github.com/Tailwind-Admin/free-tailwind-admin-dashboard-template)
- Why it is still useful:
  - MIT-licensed and easy to adopt
  - fast path to a polished admin/dashboard visual demo
  - good fallback if the goal is to showcase design quality quickly
- What it would prove:
  - Rails can host a polished admin shell with React-owned interactive surfaces
  - React on Rails Pro can support dashboard layouts, navigation shells, and widget-heavy pages
- Why it ranks below Atomic CRM and Notra:
  - it is closer to a template/demo shell than a product migration
  - it does not create as strong a Rails-ownership or RSC-value story as Atomic CRM

## Interesting, But Not Top Picks

### FrontDesk

- Source: [TanStack showcase](https://tanstack.com/showcase/db011209-4020-4501-a4ac-33a054421cb8)
- Why it is interesting:
  - community portal and support-platform shape is a strong real-world use case
  - could showcase Rails ownership of integrations, support workflows, and ticketing state
- Why it is not a top pick yet:
  - the public source repo and license were not immediately obvious during this evaluation pass
  - that uncertainty makes it a worse next move than Atomic CRM

### GitCMS

- Source: [TanStack showcase](https://tanstack.com/showcase/3222107f-258e-40f1-8140-da46cedfc641)
- Why it is interesting:
  - excellent "content as code" and agent-tooling story
  - good fit for Rails-backed content workflows and server-rendered editorial surfaces
- Why it is not a top pick yet:
  - the public source repo and license were not immediately obvious during this evaluation pass
  - until that is clearer, it is not a safe default candidate

### OpenPanel

- Source: [TanStack showcase](https://tanstack.com/showcase/fe207108-6d88-417d-bbae-509fb7975881), [GitHub repo](https://github.com/stefanpejcic/OpenPanel)
- Why it is interesting:
  - analytics/observability is a strong product category
  - it could produce a compelling server-rendered dashboard story
- Why it is deprioritized:
  - licensing and redistribution are less straightforward than the MIT options
  - it is not the cleanest showcase candidate for a published ShakaCode migration demo

### React-admin And Shadcn Admin Kit

- Sources:
  - [React-admin showcase](https://tanstack.com/showcase/1b3fcb42-093d-42e0-ae56-1fe1c42ed402)
  - [Shadcn Admin Kit showcase](https://tanstack.com/showcase/3c25ba05-30df-4a5b-a3f4-3643c59e6795)
- Why they are deprioritized:
  - both are more framework/component-kit shaped than product-migration shaped
  - they are less persuasive as "Rails owns the app shell, RSC owns the right surfaces" demos

## Suggested Portfolio End State

If the goal is a compact but complete ShakaCode demo lineup, the strongest set is:

1. `react_on_rails-demo-octochangelog-on-rails-pro`
2. `react_on_rails-demo-atomic-crm`
3. `react_on_rails-demo-notra`

That set covers:

- public read-heavy comparison pages
- authenticated CRUD and internal-tool dashboards
- workflow, integrations, jobs, and AI-assisted content operations

## Default Recommendation

If there is only budget for one more conversion right now, do:

- `shakacode/react_on_rails-demo-atomic-crm`

It is the cleanest licensing choice and the strongest addition to the current portfolio.
