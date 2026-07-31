# CI/CD Quality Gates

## Purpose
Define safe, reproducible GitHub verification for Xcode projects under the active manual-only,
zero-additional-cost policy.

Apply `./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md` first for user authority, project
modes, test permissions, recommendations, and source-of-truth boundaries.

## Execution Authority

- GitHub verification is manually triggered by the user for every project, including production.
- Supported policy modes are `off` and `manual`; mandatory CI is not active.
- Not running a workflow is `NOT_RUN_BY_USER_DECISION`, not PASS or FAIL.
- A workflow must not create, modify, or run tests unless the matching permission allows it.
- UI, Simulator/device, and performance/Instruments work require their separate permissions.
- Codex Review is a separate manual service and must not be called from CI by default.
- Branch protection and required checks remain deferred until the user explicitly reopens them.

## Manual Workflow Modes

- `static`: deterministic repository/source checks.
- `build`: static checks plus the selected Xcode build.
- `build-and-tests`: build plus permitted tests.
- `full`: the approved maximum project-specific matrix within current permissions.

Initial time budgets are 5, 15, 30, and 60 minutes respectively. A project may use a smaller
budget; expanding cost or runner class requires user approval.

## Cost Boundary

- Expected additional monetary cost is `$0`.
- Use standard GitHub-hosted runners only where included usage is available.
- Larger paid runners and automatic paid overage are forbidden by default.
- Private repositories use included quota only; stop before additional spending.
- Workflows must not call OpenAI or another paid AI API, purchase credits, or depend on a paid
  quality service without separate approval.
- Minimize artifact retention and cancel obsolete runs for the same branch when safe.

## Recommended CI Gates
- Clean build for supported simulator/device matrix.
- Unit tests where test phase is enabled.
- UI smoke tests for release-critical flows where stable.
- Static formatting/linting if configured.
- Architecture/static rule checks configured for the repository.
- Secret scan.
- Dependency/license review for new packages.
- Archive/signing check for release branches.
- dSYM/upload check for release builds.
- Privacy manifest and Info.plist permission review.
- Store bounded `.xcresult`, logs, coverage, lint/static reports, screenshots/videos from UI
  failures, dependency reports, or release artifacts only where they are needed as evidence.
- Cancel obsolete builds for the same branch/PR to reduce noise and resource waste.

## PR Gate Output
Each PR/review states:
1. GitHub Manual Check necessity score and recommended mode.
2. Expected monetary cost and current test permission.
3. Checks selected, actually run, passed, failed, blocked, skipped, or not run by decision.
4. Exact source SHA, relevant toolchain/profile versions, and local evidence.
5. Manual checks and residual risk before merge/release.
6. A separate Codex Review necessity score and mode.

## Reproducibility Rules
- Pin the Xcode/runtime image or explicitly record the selected image/version.
- Pin third-party GitHub Actions by full commit SHA; record the human-readable release in a comment.
- Use fixed tool versions for linters/formatters where possible; avoid unreviewed `latest` installs
  in release-critical pipelines.
- Cache dependencies and toolchains deliberately. Be cautious with DerivedData caching because
  stale cache keys can create misleading build failures or hide integration problems.
- Use least-privilege workflow permissions and do not expose write credentials to untrusted code.
- Redact secrets and private data from logs, summaries, filenames, and uploaded artifacts.
- Evidence from another SHA, profile, engine version, or permission set is stale.

## Result Semantics

Individual results use `PASS`, `FAIL`, `BLOCKED`, `NOT_APPLICABLE`,
`NOT_RUN_BY_USER_DECISION`, or `SKIPPED`. Overall engineering verdicts use `READY`,
`READY_WITH_ACCEPTED_RISK`, `NEEDS_OWNER_DECISION`, `NOT_READY`, `BLOCKED`, or `BYPASSED`.

A failure can make the engineering verdict not ready, but the workflow remains advisory and does
not technically block GitHub merge under the active policy. `BLOCKED`, `SKIPPED`, missing, stale,
or bypassed evidence must never be displayed as normal PASS.

Coverage is evidence, not the quality goal by itself; never treat a coverage number as a substitute
for correctness, privacy, accessibility, performance, and release readiness.
