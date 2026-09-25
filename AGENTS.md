# Repository Agent Instructions

## Pull Request Readiness

Codex is pre-approved to mark draft pull requests as ready for review in this
repository when the requested work is complete, required checks and review-app
verification are passing or any non-blocking skip is documented, and there are
no known unresolved blocking review comments or user-requested changes.

Codex does not need to ask again before running `gh pr ready` under those
conditions. If required checks are failing, review-app verification is broken,
or blocking feedback remains unresolved, leave the pull request as draft and
report the blocker instead.

## Agent Workflow Configuration

Portable shared skills resolve this repo's commands and policy through:
- **Commands** — run `.agents/bin/<name>` (`setup`, `validate`, `test`, ...); see `.agents/bin/README.md`. A missing script means that capability is n/a here.
- **Policy / config** — `.agents/agent-workflow.yml`.

## Review and Merge

AI reviewer results are advisory unless they report a blocker. Before merging,
require every current-head `gh pr checks` entry to pass, all review threads to be
resolved, and GitHub to report clean mergeability. The review-app deployment must
also pass; document any non-blocking skip. Live branch rules and required approvals
remain authoritative.

At batch closeout, low-risk, portable documentation, workflow text, helper-script,
and validation-fixture changes may be auto-merged after the full gate passes.
Keep CI/workflow, build-configuration, dependency or runtime changes, broad
refactors, and release work maintainer-gated. This policy grants no standing merge
authority.

Prefix follow-up issue titles with `Follow-up:`. Update `CHANGELOG.md` only for
user-visible features and bug fixes. GitHub Actions runs automatically for every
pull request; this repository has no manual hosted-CI trigger.

The CI parity jobs are `scan_ruby`, `lint`, and `test` from
`.github/workflows/ci.yml`. The test job uses PostgreSQL 15 and the Node renderer.
