# Agent Workflow Scripts

Thin, repo-owned wrappers that agent skills call instead of this repo's
specific commands. Shaka's standard `setup`, `validate`, and `test` live in
[`../shaka/bin/`](../shaka/bin/); other tools stay here. A script that is **absent**
means that capability is n/a here.

| Script | Purpose | This repo runs |
| --- | --- | --- |
| `setup` | Install dependencies | `bin/setup --skip-server` |
| `validate` | Pre-push gate | `.agents/bin/lint` + `.agents/shaka/bin/test` |
| `test` | Run CI-equivalent tests | prepares the database and packs, starts and waits for the Node renderer, then runs `bin/rails db:test:prepare test "$@"` |
| `lint` | Lint / format | `bin/rubocop "$@"` |
| `build` | Build / type-check | n/a |
| `docs` | Documentation checks | n/a |
| `ci-detect` | Detect affected CI jobs | n/a |

Non-command policy lives in [`../agent-workflow.yml`](../agent-workflow.yml).
