# Control Plane Deployment Notes

This repo now includes `cpflow` scaffolding for:

- opt-in PR review apps
- automatic staging deploys
- manual promotion from staging to production

## Why This Shape

This app already ships a production Dockerfile at the repository root and stores
production SQLite, Solid Cache, Solid Queue, Action Cable, and Thruster state
under `/rails/storage`.

The Control Plane setup mirrors that:

- `.controlplane/controlplane.yml` points `dockerfile: ../Dockerfile`
- `templates/storage.yml` creates a persistent volume for `/rails/storage`
- `templates/rails.yml` runs the public `rails` workload on port `80`
- `templates/renderer.yml` runs the internal React on Rails Pro Node renderer on port `3800`
- `release_script.sh` runs `bin/rails db:prepare` before deploys switch images

Because this demo uses Shakapacker plus the React on Rails Pro Node renderer, the root `Dockerfile` now installs Node.js and runs `npm ci` so the same image can both precompile assets and serve renderer requests in Control Plane.
The renderer is also configured to bind `0.0.0.0` in production so the separate `rails` workload can reach it over the shared Control Plane network.
Its bundle cache is stored under `/rails/tmp/.node-renderer-bundles`, which stays writable for the non-root app user inside the production image.

## Required Runtime Secrets

Before the app will boot on Control Plane, configure the shared app secret stores:

- `octochangelog-on-rails-pro-staging-secrets` for staging and review apps
- `octochangelog-on-rails-pro-production-secrets` for production

Each store must include at least:

- `RAILS_MASTER_KEY`
- `RENDERER_PASSWORD`

Optional:

- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`

These are referenced from `templates/app.yml` through `cpln://secret/{{APP_SECRETS}}`.

Review apps run pull request code. Do not mount a production `RAILS_MASTER_KEY`
or production OAuth credentials into review apps. Use review/staging-specific
credentials because values mounted through `cpln://secret/...` can be read by app
code after the workload starts.

## Local cpflow Flow

Typical setup:

```sh
export APP_NAME=octochangelog-on-rails-pro-staging

cpflow setup-app -a "$APP_NAME"
cpflow build-image -a "$APP_NAME"
cpflow deploy-image -a "$APP_NAME" --run-release-phase
cpflow open -a "$APP_NAME"
```

## Production Promotion and Rollback

The production promotion workflow captures the current workload images before
deploying and restores those images if the post-deploy health check fails. That
rollback does not reverse database migrations already run by the release phase.
Keep production migrations backward-compatible, using an expand/contract style
for destructive schema changes.

## GitHub Actions Variables and Secrets

Set these in GitHub before enabling the generated `cpflow-*` workflows:

- `CPLN_TOKEN_STAGING`
- `CPLN_TOKEN_PRODUCTION`
- `CPLN_ORG_STAGING=shakacode-open-source-examples-staging`
- `CPLN_ORG_PRODUCTION=shakacode-open-source-examples-production`
- `STAGING_APP_NAME=octochangelog-on-rails-pro-staging`
- `PRODUCTION_APP_NAME=octochangelog-on-rails-pro-production`
- `REVIEW_APP_PREFIX=octochangelog-on-rails-pro-review-pr`

Optional:

- `STAGING_APP_BRANCH=main`
- `PRIMARY_WORKLOAD=rails`

Use a staging/review `CPLN_TOKEN_STAGING` that cannot access production Control
Plane resources. In public repositories, review-app deploys skip fork PR heads
because Docker builds use repository secrets. If a forked change needs a review
app, first move the reviewed change to a trusted branch in this repository.
