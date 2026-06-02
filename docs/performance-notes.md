# Performance Notes

## Scope

These notes are for demo positioning and local reproducibility. They are not a production benchmark report.

## Test Setup

- Date: April 15, 2026
- Mode: local development
- Rails server: `bundle exec rails s -p 3000`
- Node renderer: `RENDERER_PORT=3800 node client/node-renderer.js`
- GitHub mode: unauthenticated public API
- Compare sample: `repo=octokit/rest.js&from=22.0.0&to=latest`

## Local HTTP Timing Snapshot

Warmed landing-page requests:

- `/`: ~31-40 ms total on a representative local sample

Representative compare requests:

- first request after boot or cache miss: about `0.75 s` on a sample run
- warmed `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: ~356-431 ms total

## Asset Snapshot

- `public/packs/js/generated/CompareFiltersStandalone.js`: `1,918` bytes
- `public/packs/js/client0.js`: `22,012` bytes
- `public/packs/js/generated/OctochangelogCompareResultsPage.js`: `1,643` bytes
- `public/packs/css/application.css`: `13,648` bytes

## What These Numbers Mean

- The landing page is effectively Rails-fast after warmup.
- The compare page is doing real work: GitHub I/O, markdown parsing, grouping, and server rendering.
- The first compare request is slower because it pays for boot/cache misses and external API work.
- The warm compare path is the more useful number for steady-state discussion.
- The interactive client surface stays small because the heavy parsing/rendering path remains server-side.

## What The Browser Does Not Need To Download

The compare page does not need to hydrate the server-side markdown pipeline. That means libraries used for:

- markdown parsing
- GitHub-flavored markdown transforms
- syntax highlighting
- grouped release-note rendering

stay on the server path rather than becoming mandatory browser payload.

## How To Re-run

```bash
bundle exec rails s -p 3000
RENDERER_PORT=3800 node client/node-renderer.js
script/benchmark_demo.sh
```

If you want to target another local host or compare URL:

```bash
BASE_URL=http://127.0.0.1:3000 \
COMPARE_PATH='/compare?repo=TanStack/router&from=1.120.5&to=latest' \
script/benchmark_demo.sh
```

## Next Performance Step

If this repo needs a stronger performance story, the next useful step is a production-style benchmark with production assets and a stable hosted deployment, not more local curl samples.
