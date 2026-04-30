# Deployment Readiness

This repo has a working production-style Docker path, but it is not publicly deployable until the
real infrastructure values are supplied.

## What Is Already Verified

- `Dockerfile` installs Ruby, Node, gems, and JavaScript dependencies in the image.
- `bin/docker-start` runs Rails and the React on Rails Pro Node renderer in the same container.
- `bin/docker-smoke-test` builds the image, starts the container, and verifies `/` plus `/compare`.
- GitHub Actions runs the same smoke test in the `docker` job.
- Kamal secrets include both `RAILS_MASTER_KEY` and `RENDERER_PASSWORD`.
- Kamal asset bridging points at `/rails/public/packs`, where Shakapacker emits the fingerprinted packs used by the pages.

## Readiness Check

Run:

```bash
bin/deploy-readiness
```

The command intentionally exits non-zero while the repo still has placeholder deployment inputs.
That makes the external blockers visible before anyone tries `bin/kamal deploy`.

Use shape-check mode when you want a non-deploy proof run:

```bash
DEPLOY_READINESS_ALLOW_EXTERNAL_BLOCKERS=1 bin/deploy-readiness
```

That mode still fails for repo-owned deploy regressions, such as missing secrets, a broken
Shakapacker asset path, or a Docker command that no longer starts the renderer. It only allows the
known external blockers that require final host and registry decisions.

## External Inputs Still Needed

- Production host or hosts for `servers.web`.
- Real image registry in `registry.server`.
- Final image name in `image`.
- `RAILS_MASTER_KEY`, sourced from a password manager or environment variable.
- `RENDERER_PASSWORD`, sourced from a password manager or environment variable.
- Optional GitHub OAuth credentials if the public demo should use authenticated GitHub API limits.
- A backup policy for the persistent `ror_tanstack_storage` volume before using SQLite for a hosted demo.

## Suggested Deploy Flow

1. Replace the placeholder host and registry in `config/deploy.yml`.
2. Export or fetch `RAILS_MASTER_KEY` and `RENDERER_PASSWORD` through `.kamal/secrets`.
3. Run `bin/deploy-readiness` until it reports no blockers.
4. Run `bin/docker-smoke-test` locally after any Docker or renderer changes.
5. Deploy with `bin/kamal setup` for the first host, then `bin/kamal deploy` for later releases.
6. Capture the hosted benchmark with `BENCHMARK_BASE_URL=https://<host> bin/benchmark-demo`.

## Why The Hosted Benchmark Is Still Open

The local Docker benchmark proves that packaging does not add a visible latency cliff. It does not
prove hosted network latency, registry pull time, disk behavior, TLS/proxy overhead, or GitHub API
variance from the production host. Those measurements need the final host and domain.
