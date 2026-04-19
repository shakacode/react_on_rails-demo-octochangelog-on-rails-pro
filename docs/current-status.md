# Current Status

## Snapshot

As of April 19, 2026, this repo is no longer a scaffold. It is a working React on Rails Pro + React Server Components demo with green local verification, green GitHub Actions, canonical demo seed data, and repeatable local benchmark tooling.

## Companion Demo Update

The follow-on Atomic CRM workstream is now real, not hypothetical. The sibling repo at
`../react_on_rails-demo-atomic-crm` has already shipped dashboard, contacts, companies, deals, and
tasks routes, plus production-assets benchmark tooling and demo/positioning docs.

That matters because it gives the demo portfolio a second shape:

- Octochangelog remains the public, server-heavy comparison/search demo
- Atomic CRM is becoming the internal SaaS / product workflow demo with one explicit client island

The current blocker for Atomic CRM is external, not technical:

- the target GitHub repo still does not exist, so the local work cannot be pushed yet

## What Is Done

- Rails owns the public routes, compare flow, session state, OAuth callback handling, and persisted comparison history.
- React on Rails Pro streams the compare results as React Server Components.
- The compare controls are isolated as a client island instead of hydrating the entire page.
- GitHub repository search and release lookup are wired through Rails JSON endpoints.
- Markdown-heavy release notes are parsed and grouped on the server.
- Fresh setup now seeds canonical comparison history so the home page is persuasive immediately.
- `bin/benchmark-demo` now captures route timings plus shipped asset sizes from a single command.
- The local benchmark snapshot has been rerun against the live stack and written back into the docs.
- The default README, positioning notes, demo notes, and performance notes are in place.
- GitHub Actions now installs Ruby and Node, generates packs, builds assets, and runs the Rails test suite successfully.

## What The Demo Already Proves Well

- Rails can stay in charge of request orchestration while React 19 + RSC handle the rendering shape.
- A page can keep a very small client-interactive surface without giving up a modern React UI.
- Heavy rendering work can stay on the server without turning the page into a plain Rails template.
- React on Rails Pro can support a real API-backed page rather than a contrived component demo.

## What Is Not Done Yet

- No public hosted deployment is configured yet.
- No production-environment benchmark has been captured yet.
- No screenshot set or recorded walkthrough has been added yet.
- GitHub OAuth remains optional and depends on local credentials.

## Good Next Steps

1. Deploy a public preview so the repo has a live URL, not just local instructions.
2. Capture a production-style benchmark with production assets and a stable external API scenario.
3. Add a short screenshot or GIF set to the README for faster top-of-page comprehension.
4. Add one or two additional comparison examples that are intentionally markdown-heavy.

## Notable Caveat

The strongest claims this repo supports are about Rails ownership, server/client composition, and keeping the client surface small. It is less useful as a proof point for large write-heavy dashboards or purely SPA-style client state orchestration.
