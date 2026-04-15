# Performance Notes

## Scope

These notes capture the current dashboard + contacts slice, not the finished CRM port.

They are useful for showing two things early:

- the source app starts from a substantial client-side bundle
- the Rails + RSC migration already keeps the route-specific surface area small even after introducing seeded CRM data

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

## Current Dashboard + Contacts Measurements

Captured from the current local repo after `bin/shakapacker`:

| Asset | Size | Gzip |
| --- | --- | --- |
| `public/packs/js/generated/AtomicCrmHomePage.js` | `1,539 B` | `556 B` |
| `public/packs/js/generated/AtomicCrmContactsPage.js` | `1,571 B` | `561 B` |
| `public/packs/js/generated/AtomicCrmContactShowPage.js` | `1,595 B` | `569 B` |
| `public/packs/js/generated/AtomicCrmDealBoardIsland.js` | `5,035 B` | `1,304 B` |
| `public/packs/css/application.css` | `9,939 B` | `2,418 B` |
| `ssr-generated/rsc-bundle.js` | `419,882 B` | `70,894 B` |
| `ssr-generated/server-bundle.js` | `2,189,453 B` | n/a |

Local dev route timing samples:

| Route | Samples |
| --- | --- |
| `/` | `32.905 ms`, `25.945 ms`, `28.166 ms`, `26.882 ms`, `27.756 ms` |
| `/contacts` | `42.104 ms`, `26.456 ms`, `28.605 ms`, `38.301 ms`, `28.811 ms` |
| `/contacts/1` | `24.705 ms`, `27.199 ms`, `26.578 ms`, `34.306 ms`, `35.029 ms` |

Latest warm request observed in the Rails log:

| Route | Total | Active Record | Query count |
| --- | --- |
| `/` | `13 ms` | `1.3 ms` | `13` |
| `/contacts` | `15-21 ms` | `1.3-2.1 ms` | `12` |
| `/contacts/1` | `11 ms` | `0.8 ms` | `7` |

## Measurement Commands

Bundle sizes:

```bash
wc -c \
  public/packs/js/generated/AtomicCrmHomePage.js \
  public/packs/js/generated/AtomicCrmContactsPage.js \
  public/packs/js/generated/AtomicCrmContactShowPage.js \
  public/packs/js/generated/AtomicCrmDealBoardIsland.js \
  public/packs/css/application.css \
  ssr-generated/rsc-bundle.js \
  ssr-generated/server-bundle.js
```

Gzip sizes:

```bash
gzip -c public/packs/js/generated/AtomicCrmHomePage.js | wc -c
gzip -c public/packs/js/generated/AtomicCrmContactsPage.js | wc -c
gzip -c public/packs/js/generated/AtomicCrmContactShowPage.js | wc -c
gzip -c public/packs/js/generated/AtomicCrmDealBoardIsland.js | wc -c
gzip -c public/packs/css/application.css | wc -c
gzip -c ssr-generated/rsc-bundle.js | wc -c
```

Local route timing:

```bash
npm run bench:home
npm run bench:home -- http://127.0.0.1:3000/contacts
npm run bench:home -- http://127.0.0.1:3000/contacts/1
```

## Interpretation

The most important early signal is not "Rails is already faster than the original app."

It is this:

- the route-specific client entrypoints are tiny
- the client island is explicit and bounded
- the RSC path is working
- the app is already serving a Rails-backed dashboard without introducing a separate JSON API layer
- the contacts list and detail routes keep their route-specific client payloads close to `1.5 kB` each
- the app can now evolve toward a more honest production comparison once more CRM screens are ported

## Next Benchmark Milestones

- record a production-mode asset build after the first real dashboard/list/show slice is ported
- compare route-level JavaScript shipped for dashboard, contacts list, contact detail, and the future company/deal routes
- compare warm request timing with seeded data
- compare the deal board interaction cost against the source app once the real workflow is migrated
