# Performance Notes

## Scope

These notes capture the current migration bootstrap, not the finished CRM port.

They are useful for showing two things early:

- the source app starts from a substantial client-side bundle
- the Rails + RSC scaffold already keeps the route-specific surface area small

## Upstream Atomic CRM Baseline

Captured from the source app build during migration planning:

| Asset | Size |
| --- | --- |
| Main bundle | about `2.03 MB` |
| `DealList` chunk | about `137.57 kB` |
| Stylesheet | about `119.97 kB` |

Interpretation:

- the original app already has enough client-side weight to justify a server/client boundary rethink
- the deal list and board views are strong candidates for splitting server-rendered read paths from interactive islands

## Current Bootstrap Measurements

Captured from the current local scaffold after `bin/shakapacker`:

| Asset | Size | Gzip |
| --- | --- | --- |
| `public/packs/js/generated/AtomicCrmHomePage.js` | `1,539 B` | `556 B` |
| `public/packs/js/generated/AtomicCrmDealBoardIsland.js` | `4,761 B` | `1,250 B` |
| `public/packs/css/application.css` | `4,053 B` | `1,387 B` |
| `ssr-generated/rsc-bundle.js` | `393,392 B` | `68,420 B` |
| `ssr-generated/server-bundle.js` | `2,160,599 B` | n/a |

Local dev route timing sample for `/`:

| Run type | Time |
| --- | --- |
| first warm-up request | about `72 ms` total |
| warm follow-up requests | about `22-23 ms` total |

## Measurement Commands

Bundle sizes:

```bash
wc -c \
  public/packs/js/generated/AtomicCrmHomePage.js \
  public/packs/js/generated/AtomicCrmDealBoardIsland.js \
  public/packs/css/application.css \
  ssr-generated/rsc-bundle.js \
  ssr-generated/server-bundle.js
```

Gzip sizes:

```bash
gzip -c public/packs/js/generated/AtomicCrmHomePage.js | wc -c
gzip -c public/packs/js/generated/AtomicCrmDealBoardIsland.js | wc -c
gzip -c public/packs/css/application.css | wc -c
gzip -c ssr-generated/rsc-bundle.js | wc -c
```

Local route timing:

```bash
npm run bench:home
```

## Interpretation

The most important early signal is not "Rails is already faster than the original app."

It is this:

- the route-specific client entrypoints are tiny
- the client island is explicit and bounded
- the RSC path is working
- the app can now evolve toward a more honest production comparison once real data and real CRM screens are ported

## Next Benchmark Milestones

- record a production-mode asset build after the first real dashboard/list/show slice is ported
- compare route-level JavaScript shipped for dashboard, list, and detail pages
- compare warm request timing with seeded data
- compare the deal board interaction cost against the source app once the real workflow is migrated
