# Performance Notes

## Scope

These notes are for demo positioning and local reproducibility. They include local development timing plus one
production-like Docker runtime smoke test. They are still not a hosted production benchmark report.

## Benchmark Command

The repo includes `bin/benchmark-demo` so the timing and asset snapshot can be re-run without
retyping curl loops.

Default usage:

```bash
bin/benchmark-demo
```

Useful variants:

```bash
BENCHMARK_BASE_URL=http://127.0.0.1:3001 bin/benchmark-demo
BENCHMARK_SKIP_COMPARE=1 bin/benchmark-demo
BENCHMARK_OUTPUT=json bin/benchmark-demo
BENCHMARK_OUTPUT=markdown bin/benchmark-demo
```

Notes:

- the default compare route still depends on live GitHub API latency and rate limits
- `BENCHMARK_SKIP_COMPARE=1` is useful when you only want the homepage timing plus asset sizes
- `BENCHMARK_OUTPUT=markdown` emits a docs-ready table for README or PR updates
- the script reports HTTP status codes so a failed external compare path is visible instead of silently folded into the numbers

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

## Production-like Docker Runtime Snapshot

- Date: April 15, 2026
- Mode: production image, two local containers from the same image
- Shape: one `rails` container plus one Node renderer container
- Runtime env: `SECRET_KEY_BASE` provided directly, unauthenticated GitHub API

Landing page:

- first request after container boot: ~159 ms total
- warmed `/`: ~23-27 ms total

Compare page:

- first sampled `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: ~284 ms total
- later sampled requests on the same route: ~323 ms and ~1.28 s total

Notes:

- the renderer needed two production-specific fixes to make this work in a split-workload shape:
  bind `0.0.0.0` instead of `localhost`, and store renderer bundle cache files in writable `tmp/`
- compare timings still vary because GitHub I/O dominates the request and this run used unauthenticated API access

## Asset Snapshot

- `public/packs/js/generated/CompareFiltersStandalone.js`: about `5 KiB`
- `public/packs/js/client0.js`: about `22 KiB`
- `public/packs/js/generated/OctochangelogCompareResultsPage.js`: about `2 KiB`
- `public/packs/css/application.css`: about `16 KiB`

## What These Numbers Mean

- The landing page is effectively Rails-fast after warmup.
- The compare page is doing real work: GitHub I/O, markdown parsing, grouping, and server rendering.
- The first compare request is slower because it pays for boot/cache misses and external API work.
- The warm compare path is the more useful number for steady-state discussion.
- The interactive client surface stays small because the heavy parsing/rendering path remains server-side.
- The production-like container run confirms that the Control Plane-style split between Rails and the renderer works with the real production image once container networking and writable-cache details are configured correctly.

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
bin/benchmark-demo
```

If you want to target another local host or compare URL:

```bash
BENCHMARK_BASE_URL=http://127.0.0.1:3000 \
BENCHMARK_COMPARE_PATH='/compare?repo=TanStack/router&from=1.120.5&to=latest' \
bin/benchmark-demo
```

## Next Performance Step

If this repo needs a stronger performance story, the next useful step is a hosted benchmark against a real staging or production Control Plane deployment, not more local curl samples.
