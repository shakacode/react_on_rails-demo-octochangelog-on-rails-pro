# Control Plane Deployment Notes

This repo includes `cpflow` 5.1.1 scaffolding for:

- opt-in PR review apps
- automatic staging deploys
- manual promotion from staging to production

## Why This Shape

This app ships a production Dockerfile at the repository root. It is **stateless**:
the primary database and Solid Cache, Solid Queue, and Action Cable all live on
the org's shared Postgres (GVC `staging-shared-postgres`), so the `rails`
workload mounts no persistent volume and can scale to zero.

The Control Plane setup:

- `.controlplane/controlplane.yml` points `dockerfile: ../Dockerfile`
- `templates/rails.yml` runs the public `rails` workload on port `80` as a plain
  `standard` (stateless) workload with no volume
- `templates/renderer.yml` runs the internal React on Rails Pro Node renderer on port `3800` with the `http2` protocol expected by the Pro renderer
- `templates/app.yml` injects the shared-Postgres connection URLs (`DATABASE_URL`
  and `CACHE_/QUEUE_/CABLE_DATABASE_URL`) from the app secret store
- `bin/docker-entrypoint` runs `bin/rails db:prepare` against Postgres when the Rails server starts

Because this demo uses Shakapacker plus the React on Rails Pro Node renderer, the root `Dockerfile` now installs Node.js and runs `npm ci` so the same image can both precompile assets and serve renderer requests in Control Plane.
The renderer is also configured to bind `0.0.0.0` in production so the separate `rails` workload can reach it over the shared Control Plane network.
Its bundle cache is stored under `/rails/tmp/.node-renderer-bundles`, which stays writable for the non-root app user inside the production image.

## Required Runtime Secrets

Before the app will boot on Control Plane, configure the shared app secret stores:

- `octochangelog-on-rails-pro-staging-secrets` for staging and review apps
- `octochangelog-on-rails-pro-production-secrets` for production

Each store must include at least:

- `SECRET_KEY_BASE`
- `RENDERER_PASSWORD`
- `REACT_ON_RAILS_PRO_LICENSE`
- `DATABASE_URL`, `CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, `CABLE_DATABASE_URL` — shared-Postgres connection strings, one per database in `config/database.yml`

Optional:

- `RAILS_MASTER_KEY`, only when production encrypted credentials are required
- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`

These are referenced from `templates/app.yml` through `cpln://secret/{{APP_SECRETS}}`.

Review apps run pull request code. Do not mount a production `SECRET_KEY_BASE`,
`RAILS_MASTER_KEY`, React on Rails Pro license, or production OAuth credentials
into review apps. Use review/staging-specific values because values mounted
through `cpln://secret/...` can be read by app code after the workload starts.

## Local cpflow Flow

Typical setup:

```sh
export APP_NAME=octochangelog-on-rails-pro-staging

cpflow setup-app -a "$APP_NAME"
cpflow build-image -a "$APP_NAME"
cpflow deploy-image -a "$APP_NAME"
cpflow open -a "$APP_NAME"
```

## Production Promotion and Rollback

The production promotion workflow captures the current workload images before
deploying and restores those images if the post-deploy health check fails. That
rollback does not reverse database changes prepared during the replacement
Rails workload boot. Keep production migrations backward-compatible, using an
expand/contract style for destructive schema changes.

## GitHub Actions Variables and Secrets

The generated `cpflow-*` workflows are thin wrappers pinned to
`shakacode/control-plane-flow@v5.1.1`; production promotion also pins the local
`.cpflow` checkout to that release's immutable commit. See
`.github/cpflow-help.md` for the full generated command reference and
version-pinning notes.

Repository secrets:

- `CPLN_TOKEN_STAGING`

Repository variables:

- `CPLN_ORG_STAGING=shakacode-open-source-examples-staging`
- `STAGING_APP_NAME=octochangelog-on-rails-pro-staging`
- `REVIEW_APP_PREFIX=octochangelog-on-rails-pro-review-pr`

Optional:

- `STAGING_APP_BRANCH=main`
- `PRIMARY_WORKLOAD=rails`

Production GitHub Environment secrets and variables:

- `CPLN_TOKEN_PRODUCTION`, as a secret on the protected `production` environment
- `CPLN_ORG_PRODUCTION=shakacode-open-source-examples-production`
- `PRODUCTION_APP_NAME=octochangelog-on-rails-pro-production`

Use a staging/review `CPLN_TOKEN_STAGING` that cannot access production Control
Plane resources. In public repositories, review-app deploys skip fork PR heads
because Docker builds use repository secrets. If a forked change needs a review
app, first move the reviewed change to a trusted branch in this repository.
