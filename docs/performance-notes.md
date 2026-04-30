# Performance Notes

## Scope

These notes are for demo positioning and local reproducibility. They include local development and
local production-assets measurements. They are not a hosted production benchmark report.

## Benchmark Command

The repo now includes `bin/benchmark-demo` so the timing and asset snapshot can be re-run without
retyping curl loops.

Default usage:

```bash
bin/benchmark-demo
```

Useful variants:

```bash
BENCHMARK_BASE_URL=http://127.0.0.1:3001 bin/benchmark-demo
BENCHMARK_BASE_URL=http://127.0.0.1:3003 bin/benchmark-demo
BENCHMARK_SKIP_COMPARE=1 bin/benchmark-demo
BENCHMARK_OUTPUT=json bin/benchmark-demo
BENCHMARK_OUTPUT=markdown bin/benchmark-demo
bin/docker-benchmark
BUILD_IMAGE=0 BENCHMARK_OUTPUT=markdown bin/docker-benchmark
```

Notes:

- the default compare route still depends on live GitHub API latency and rate limits
- `BENCHMARK_SKIP_COMPARE=1` is useful when you only want the homepage timing plus asset sizes
- `BENCHMARK_OUTPUT=markdown` emits a docs-ready table for README or PR updates
- `bin/docker-benchmark` starts the production image, runs cold and warmed benchmark passes, and
  cleans up the container afterward
- the script reports HTTP status codes so a failed external compare path is visible instead of silently folded into the numbers

## Development Setup

- Date: April 22, 2026
- Mode: local development
- Rails server: `bundle exec rails s -p 3000`
- Node renderer: `RENDERER_PORT=3800 node client/node-renderer.js`
- GitHub mode: unauthenticated public API
- Compare sample: `repo=octokit/rest.js&from=22.0.0&to=latest`
- Measurement command: `bin/benchmark-demo`

## Local HTTP Timing Snapshot

First benchmark pass after starting the app:

- `/`: `33-429 ms` total, `119 ms` average
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: `365 ms-1.567 s` total, `773 ms` average

Immediate warmed rerun:

- `/`: `29-48 ms` total, `38 ms` average
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: `352-430 ms` total, `388 ms` average

## Production-Assets Setup

- Date: April 23, 2026
- Mode: local production-assets workflow
- Startup command: `bin/dev prod --no-open-browser --skip-database-check`
- Rails server: `http://127.0.0.1:3001`
- Node renderer: started by `Procfile.dev-prod-assets` on port `3800`
- Asset mode: `NODE_ENV=production`, `RAILS_ENV=development`
- GitHub mode: unauthenticated public API
- Compare sample: `repo=octokit/rest.js&from=22.0.0&to=latest`
- Measurement command: `BENCHMARK_BASE_URL=http://127.0.0.1:3001 bin/benchmark-demo`

First benchmark pass after starting `bin/dev prod`:

- `/`: `29-428 ms` total, `115 ms` average
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: `365-686 ms` total, `483 ms` average

Immediate warmed rerun:

- `/`: `27-32 ms` total, `30 ms` average
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: `356-401 ms` total, `380 ms` average

## Docker Production Container

- Date: April 23, 2026
- Mode: local Docker image built from `Dockerfile`
- Smoke command: `bin/docker-smoke-test`
- Benchmark command: `bin/docker-benchmark`
- Runtime shape: Rails plus the React on Rails Pro Node renderer inside one container
- Benchmark wrapper base URL: `http://127.0.0.1:3003`
- Required production secrets: `RAILS_MASTER_KEY`, `RENDERER_PASSWORD`
- GitHub mode: unauthenticated public API
- Compare sample: `repo=octokit/rest.js&from=22.0.0&to=latest`
- Current measurement command: `bin/docker-benchmark`
- The April 23 snapshot below was captured with a manually started container on port `3002`.

Warmed rerun after the container booted successfully:

- `/`: `19-41 ms` total, `26 ms` average
- `/compare?repo=octokit/rest.js&from=22.0.0&to=latest`: `337-363 ms` total, `346 ms` average

## Asset Snapshot

- `public/packs/js/generated/CompareFiltersStandalone.js`: `1,918` bytes
- `public/packs/js/client0.js`: `22,012` bytes
- `public/packs/js/generated/OctochangelogCompareResultsPage.js`: `1,643` bytes
- `public/packs/css/application.css`: `13,648` bytes

## What These Numbers Mean

- The landing page is effectively Rails-fast after warmup.
- The compare page is doing real work: GitHub I/O, markdown parsing, grouping, and server rendering.
- The first benchmark pass is noisier because it pays for cold-path work and external API variance.
- The warmed compare path is the more useful number for steady-state discussion.
- The local `bin/dev prod` run lands very close to the warmed development timings because the compare route is dominated by server work and external GitHub latency, not client bundle size.
- The April 23 Docker production-container snapshot landed in essentially the same steady-state range as `bin/dev prod`, which is the important proof that the packaged deploy path was not where that sampled latency came from.
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
```

Then in another terminal:

```bash
bin/benchmark-demo
```

To reproduce the production-assets pass instead:

```bash
bin/dev prod --no-open-browser --skip-database-check
BENCHMARK_BASE_URL=http://127.0.0.1:3001 bin/benchmark-demo
```

To reproduce the Docker production-container pass instead:

```bash
bin/docker-benchmark
BUILD_IMAGE=0 BENCHMARK_OUTPUT=markdown bin/docker-benchmark
```

`bin/docker-smoke-test` is intentionally a pass/fail verification command and removes its container
on exit. Use `bin/docker-benchmark` when you need route timings from the production image.

## Next Performance Step

If this repo needs a stronger performance story, the next useful step is a hosted benchmark with
stable deployment inputs and a repeatable external API scenario, not more local curl samples.
Use `bin/deploy-readiness` before that hosted run so placeholder Kamal inputs do not masquerade as
performance work.
