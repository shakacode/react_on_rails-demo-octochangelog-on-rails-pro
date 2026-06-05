# Demo Guide

## Goal

Show why React on Rails Pro is compelling for pages that have:

- real server work
- obvious server/client boundaries
- React-quality interactivity
- a Rails team that still wants Rails to own the application shell

## Recommended Demo Flow

1. Start on `/`.
   Explain that this is a normal Rails route and Rails view, not a JavaScript router.
2. Call out the featured comparisons and recent history.
   Point out that Rails persists comparison runs and renders that history server-side.
3. Go to `/compare`.
   Explain that the sidebar form is the only client island on the page.
4. Search for a repository.
   Show that the repository search and release selectors are interactive without hydrating the whole results area.
5. Submit a comparison.
   Explain that Rails fetches GitHub data, then the Node renderer streams the RSC results tree back through the RSC payload route.
6. Scroll through grouped release notes.
   Point out that markdown parsing, grouping, and highlighted code rendering stayed on the server.
7. If OAuth is configured, show the GitHub auth button.
   Explain that the callback and session state remain normal Rails concerns.

## Good Repositories To Demo

- `octokit/rest.js`
  Good quick-path demo with short compare ranges.
- `vitejs/vite`
  Good for markdown-heavy release notes.
- `TanStack/router`
  Good for deeper history and more substantial grouped output.
- `shakacode/react_on_rails`
  Good meta-demo inside a React on Rails Pro repo.

## Useful Talking Points

- "Rails still owns the request, React owns the rendering surface."
- "Only the controls hydrate. The results tree streams as RSC."
- "We are not shipping markdown parsing and release grouping logic to the browser."
- "OAuth, sessions, redirects, persistence, and routing are still just Rails."
- "This is a better fit for server-heavy pages than pretending every surface needs to become a full SPA."

## Proof Commands Before A Demo

Run these when you want to confirm the repo is still demo-ready before a walkthrough:

```bash
bin/shakapacker
BENCHMARK_SKIP_COMPARE=1 bin/benchmark-demo
RAILS_ENV=test REACT_RENDERER_URL=http://127.0.0.1:3800 bin/rails test
```

Start the Node renderer on `127.0.0.1:3800` before the Rails test command when testing prerendered
React components locally.

## How To Position This Repo Alongside Other ShakaCode Demos

- `gumroad-rsc` is the product-experiment story inside a larger existing app.
- `react_on_rails-hacker-news-app` is the multi-route content-app story with feeds, comments, and caching.
- `react_on_rails-demo-octochangelog-on-rails-pro` is the showcase-migration story for a clearly server-heavy page with a tiny client island.
- `react_on_rails-demo-atomic-crm` is the recommended next portfolio story when the audience wants internal SaaS workflows, linked records, and write-adjacent surfaces.
- Use this repo when the conversation is about page-shape fit and Rails ownership, not about reproducing a whole app framework.

## What Not To Overclaim

- Do not pitch this as a reason to rewrite every Rails page in React.
- Do not present local development timings as production numbers.
- Do not claim this is better than Next.js or Inertia for every page shape.
- Do not claim deployment is solved here; this repo is still a demo/reference implementation.
