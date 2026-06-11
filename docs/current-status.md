# Current Status

## Snapshot

As of June 4, 2026, this repo is no longer a scaffold. It is a working React on Rails Pro + React Server Components demo with green local verification, green GitHub Actions, and Control Plane review-app coverage.

## What Is Done

- Rails owns the public routes, compare flow, session state, OAuth callback handling, and persisted comparison history.
- React on Rails Pro streams the compare results as React Server Components.
- `react-on-rails-rsc` is pinned to the published `19.0.5-rc.7` release.
- The compare controls are isolated as a client island instead of hydrating the entire page.
- GitHub repository search and release lookup are wired through Rails JSON endpoints.
- Markdown-heavy release notes are parsed and grouped on the server.
- `Octochangelog::DemoCatalog` owns canonical featured comparisons and seeded demo history.
- `bin/benchmark-demo` captures route timings and asset-size snapshots in text, JSON, or markdown.
- The default README, positioning notes, demo notes, and performance notes are in place.
- GitHub Actions now installs Ruby and Node, generates packs, builds assets, and runs the Rails test suite with the renderer alive in the same step.
- The README now includes captured screenshots and a rerunnable local benchmark script.
- Control Plane deployment scaffolding is now present for review apps, staging, and production promotion.
- The Control Plane setup includes both the public Rails workload and the internal React on Rails Pro Node renderer workload.

## What The Demo Already Proves Well

- Rails can stay in charge of request orchestration while React 19 + RSC handle the rendering shape.
- A page can keep a very small client-interactive surface without giving up a modern React UI.
- Heavy rendering work can stay on the server without turning the page into a plain Rails template.
- React on Rails Pro can support a real API-backed page rather than a contrived component demo.

## What Is Not Done Yet

- No permanent public production URL is configured yet.
- No hosted Control Plane benchmark has been captured yet.
- No recorded walkthrough or GIF set has been added yet.
- GitHub OAuth remains optional and depends on local credentials.

## Good Next Steps

1. Set the GitHub repository secrets and variables required by `.github/workflows/cpflow-*.yml`, including the optional renderer password if you do not want the default fallback.
2. Provision the first staging app and confirm both the Rails workload and renderer workload boot on a pull request review app.
3. Capture a hosted staging benchmark with production assets and a stable external API scenario.
4. Add a short screenshot or GIF set to the README for faster top-of-page comprehension.
5. Add one or two additional comparison examples that are intentionally markdown-heavy.

## Notable Caveat

The strongest claims this repo supports are about Rails ownership, server/client composition, and keeping the client surface small. It is less useful as a proof point for large write-heavy dashboards or purely SPA-style client state orchestration.
