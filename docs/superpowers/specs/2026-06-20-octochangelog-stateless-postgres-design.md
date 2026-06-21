# Octochangelog: stateless (shared Postgres) → scale-to-zero

Date: 2026-06-20
Issue: [shakacode/react_on_rails-demo-octochangelog-on-rails-pro#19](https://github.com/shakacode/react_on_rails-demo-octochangelog-on-rails-pro/issues/19)

## Goal

Make the Octochangelog demo **stateless** so its `rails` web workload can
**scale to zero** on Control Plane like the rest of the demo fleet. Today the
`rails` workload is `stateful`: it mounts a persistent volume
(`cpln://volumeset/rails-storage`) at `/rails/storage`, which holds local SQLite
databases. Stateful single-replica workloads cannot safely scale to zero, so the
app must lose its local-disk state first.

## Audit (what is actually on the volume)

- `/rails/storage` holds **four SQLite databases**:
  - `production.sqlite3` — primary; a single table `comparison_runs`.
  - `production_cache.sqlite3` — Solid Cache.
  - `production_queue.sqlite3` — Solid Queue.
  - `production_cable.sqlite3` — Solid Cable.
- **No Active Storage blobs.** Active Storage is configured as `:local` but the
  app declares zero attachments (`has_one_attached`/`has_many_attached` appear
  nowhere). Nothing is written under `storage/` for Active Storage, so there is
  nothing to migrate and nothing is lost at scale-to-zero. Active Storage config
  is left unchanged.
- `/up` health endpoint exists. `bin/docker-entrypoint` runs `bin/rails
  db:prepare` when the Rails server boots.
- Background work is only the framework `ApplicationJob` plus one recurring job
  (`clear_solid_queue_finished_jobs`); Solid Queue runs in Puma
  (`SOLID_QUEUE_IN_PUMA=true`).

## Approach: mirror the Hacker News RSC demo

`shakacode/react-on-rails-demo-hacker-news-rsc` already runs this **identical**
four-database Solid stack on the org's shared Postgres and already scales to
zero. We mirror it to stay consistent with the fleet and minimize invention.

Established org convention (verified against live Control Plane + the HN repo):

- Each app gets its own Postgres **role + four databases** on the shared server
  `postgres.staging-shared-postgres.cpln.local:5432`:
  `<app>_production`, `<app>_production_cache`, `<app>_production_queue`,
  `<app>_production_cable`.
- The four connection URLs are exposed to the workload as `DATABASE_URL`,
  `CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, `CABLE_DATABASE_URL` (Rails maps
  `<NAME>_DATABASE_URL` onto the matching `database.yml` connection). The HN demo
  keeps these in a dedicated `<gvc>-database` secret; for octochangelog they live
  in the app's existing `{{APP_SECRETS}}` store (`...-secrets`), so staging and
  its review apps share the staging databases (a documented trade-off — see
  "Risks").
- Routine staging deploys run `cpflow deploy-image` (image-only) — they do **not**
  re-apply templates or revert imperative scaling changes, so the serverless
  conversion persists across deploys.

Naming base for this app: **`octochangelog`** (role `octochangelog`, databases
`octochangelog_production[_cache|_queue|_cable]`, `octochangelog_development`,
`octochangelog_test`). Decision: **Postgres everywhere** (dev/test/production),
for dev/prod parity.

Rejected alternative: collapse the four Solid databases into one Postgres
database. It would churn `cache.yml`/`cable.yml`/`production.rb` and diverge from
the fleet for no operational benefit.

## Phase 1 — App statelessness (PR against this repo)

| File | Change |
|---|---|
| `Gemfile` | `sqlite3` → `pg` |
| `config/database.yml` | postgresql adapter for all envs; dev/test → `octochangelog_development`/`_test`; production → HN-style four-DB block with `octochangelog` naming |
| `config/cache.yml`, `config/cable.yml`, `config/environments/production.rb` | unchanged — already reference the `cache`/`queue`/`cable` named connections |
| `.controlplane/templates/rails.yml` | `type: stateful` → `standard`; remove the `/rails/storage` volume mount |
| `.controlplane/templates/app.yml` | add `DATABASE_URL` / `CACHE_/QUEUE_/CABLE_DATABASE_URL` as `cpln://secret/{{APP_NAME}}-database.*` refs |
| `config/deploy.yml` (Kamal) | drop the `octochangelog_on_rails_pro_storage:/rails/storage` volume |
| `.github/workflows/ci.yml` | add a Postgres service for tests (Postgres everywhere) |
| `.controlplane/readme.md` | update the stale "mounts /rails/storage / SQLite" notes |

Verify: `bin/rails test` (and `bin/rails db:prepare`) pass against Postgres
locally; RuboCop clean.

## Live cutover (staging infra)

1. On `staging-shared-postgres` (as admin): create role `octochangelog` and its
   four databases (grant `CREATEDB` to the role so `db:prepare` can manage them,
   or pre-create + run an explicit `db:schema:load` for the Solid DBs).
2. Add the four URL keys to the app secret store
   `octochangelog-on-rails-pro-staging-secrets` (merge-patch, preserving existing
   keys); add the four `cpln://secret/{{APP_SECRETS}}.*` env refs to the GVC.
3. Build + deploy the new image (with `pg`); run `db:prepare` + `db:seed`
   against Postgres; verify the homepage shows seeded comparison runs.
4. Recreate the `rails` workload as `standard` with **no volume** (Control Plane
   cannot change workload `type` in place, so this is a delete+recreate). Capture
   the final canonical `*.cpln.app` endpoint.
5. Verify the app boots and works with no local volume; then drop the
   `rails-storage` volumeset.

## Phase 2 — Scale-to-zero (PR against `reactonrails-demos-scale-to-zero`)

1. `demos.yml`: fill the `changelog` block — domain `changelog.reactonrails.com`,
   `origin` = the endpoint from cutover step 4, `gvc
   octochangelog-on-rails-pro-staging`, `workload rails`, `health_path /up`,
   splash copy.
2. `worker/wrangler.toml`: add the `changelog.reactonrails.com` route; deploy the
   Worker (`cd worker && npm run deploy`).
3. `node scripts/convert-to-serverless.mjs changelog` → serverless `minScale 0`,
   `scaleToZeroDelay 900`. The renderer workload stays `minScale 1` (warm SSR).
   The script refuses workloads with volumes / `stateful` type, which is why
   cutover step 4 must complete first.

## Acceptance criteria

- `changelog.reactonrails.com` scales to zero after 15 min idle and wakes via the
  splash, with all data persisted in Postgres across sleep/wake cycles.
- The Control Plane `rails` workload is `serverless`, `minScale 0`, no persistent
  volume.

## Risks / notes

- **Brief downtime** during each `rails` workload delete+recreate (type change,
  then serverless conversion). Acceptable for staging; the Worker shows the
  "waking up" splash during the gap.
- **Seeds:** `db:prepare` only seeds when it creates a database. Ensure
  `db:seed` runs against the (empty) primary so the homepage has demo runs.
- **Shared Postgres is shared:** provisioning only *adds* the `octochangelog`
  role + databases; never touch other demos' data or the server config.
- **Review apps share the staging databases** (they use the staging
  `{{APP_SECRETS}}` store). Today review apps get isolated SQLite volumes; this
  change trades that for shared staging Postgres. The fleet's HN demo instead
  provisions per-review-app databases (`<app-name>` + suffixes). Matching that —
  per-review-app DB provisioning in the review-app workflow — is a follow-up,
  out of scope for #19 (staging scale-to-zero).
