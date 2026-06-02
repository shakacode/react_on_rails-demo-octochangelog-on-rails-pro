# Current Status

## Snapshot

As of April 15, 2026, this repo is no longer a scaffold. It is a working React on Rails Pro + React Server Components demo with green local verification and green GitHub Actions.

## What Is Done

- Rails owns the public routes, compare flow, session state, OAuth callback handling, and persisted comparison history.
- React on Rails Pro streams the compare results as React Server Components.
- The compare controls are isolated as a client island instead of hydrating the entire page.
- GitHub repository search and release lookup are wired through Rails JSON endpoints.
- Markdown-heavy release notes are parsed and grouped on the server.
- The default README, positioning notes, demo notes, and performance notes are in place.
- GitHub Actions now installs Ruby and Node, generates packs, builds assets, and runs the Rails test suite successfully.
- The README now includes captured screenshots and a rerunnable local benchmark script.

## What The Demo Already Proves Well

- Rails can stay in charge of request orchestration while React 19 + RSC handle the rendering shape.
- A page can keep a very small client-interactive surface without giving up a modern React UI.
- Heavy rendering work can stay on the server without turning the page into a plain Rails template.
- React on Rails Pro can support a real API-backed page rather than a contrived component demo.

## What Is Not Done Yet

- No public hosted deployment is configured yet.
- No production-environment benchmark has been captured yet.
- No recorded walkthrough or GIF set has been added yet.
- GitHub OAuth remains optional and depends on local credentials.

## Good Next Steps

1. Deploy a public preview so the repo has a live URL, not just local instructions.
2. Capture a production-style benchmark with production assets and a stable external API scenario.
3. Add a short recorded walkthrough or GIF set for faster async sharing.
4. Add one or two additional comparison examples that are intentionally markdown-heavy.

## Notable Caveat

The strongest claims this repo supports are about Rails ownership, server/client composition, and keeping the client surface small. It is less useful as a proof point for large write-heavy dashboards or purely SPA-style client state orchestration.
