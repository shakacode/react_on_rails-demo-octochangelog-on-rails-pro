# Agent Workflow Scripts

Standard entry points that portable agent-workflow skills call, so a skill can
run `.agents/bin/<name>` in any repo without knowing this repo's specific
commands. Each script is a thin, repo-owned wrapper. A script that is **absent**
means that capability is n/a here.

| Script | Purpose | This repo runs |
| --- | --- | --- |
| `setup` | Install dependencies | `bin/setup --skip-server` |
| `validate` | Pre-push gate | `.agents/bin/lint` + `.agents/bin/test` |
| `test` | Run tests | `bin/rails test "$@"` |
| `lint` | Lint / format | `bin/rubocop "$@"` |
| `build` | Build / type-check | n/a |
| `docs` | Documentation checks | n/a |
| `ci-detect` | Detect affected CI jobs | n/a |

Non-command policy lives in [`../agent-workflow.yml`](../agent-workflow.yml).
