# Universal Xcode Quality Control Plan

## Status And Authority

- Status: approved planning baseline; Stages 0–8, Stage 9A, and the bounded
  Stage 6A/6B/6C/6D/6E1/6F/6G1/6G2/6H verifier slices are complete, and the roadmap continues through
  preauthorized bounded iterations with user checkpoints only for manual PR/workflow actions.
  QualityControl PR #11 passed exact-head Manual Static Quality Check and Codex Review and merged
  into `main` as `639c70001c15a93aa1dc0c0ae53b7f84f0865079`.
  QualityControl PR #12 passed exact-head Manual Static Quality Check and Codex Review and merged
  into `main` as `3d5fd8aaf5f535f8f95a37699a3d9100d05eff6a`.
  The public canary completed Stage 8 on 2026-08-02; corrective PR #1 merged as
  `d601c0149d48a6aed21377cbeb04ded54c4f3183`, and the user reported the final manual `build` PASS.
- Boundary: task recovery for `new-task-be0b`.
- Authority: this document records the agreed roadmap but does not yet replace reusable standards,
  project-local policies, GitHub settings, or the active AI Fieldbook task plan.
- Promotion trigger: after the first two different pilot consumers validate the design and the user
  explicitly approves app-neutral promotion.
- Intended audience: the user and agents planning or implementing the future universal Xcode quality
  control system.
- Review trigger: any change to the five-section model, user-controlled test policy, zero-cost CI
  constraint, PR recommendation scoring, trust model, or rollout order.

## Current Progress

- [x] Stage 0 — accepted provisional decisions and limits are recorded below.
- [x] Stage 1 — the separate GitHub Manual Check and Codex Review recommendation format is active
  as a manual reporting contract and remains subject to calibration on real PRs.
- [x] Stage 2 — the read-only inventory and proposed migration ownership are recorded in
  `universal-quality-control-inventory-and-migration-map.md`.
- [x] User approved the Stage 2 migration map on 2026-07-28.
- [x] Stage 3 — human governance is normalized in one reusable entry point; CI, static-gate, and
  testing policies now reference the approved ownership and permission model.
- [x] Stage 4 — the public `MArtem/AIZenflowQualityControl` repository now contains the minimal
  app-neutral skeleton and governance at commit `a2b9e64ec6bc21bf066089159adea0147acc494b`.
- [x] Stage 5 — the bounded Swift CLI implements `doctor`, `validate-profile`, and `static`;
  static checks and the user-owned build/runtime acceptance matrix pass.
- [x] Stage 6A — the first Swift Testing verifier-contract suite covers fail-closed aggregation,
  invalid and oversized profiles, a positive control, and repository-contained parallel fixtures.
- [x] Stage 6B — adversarial path and symbolic-link tests cover lexical traversal, resolved
  repository/sandbox escapes, and non-following static-scan behavior with runtime-only fixtures.
- [x] Stage 6C — static-policy rejection/validation and bounded-scan contracts cover malformed
  policies, deterministic limits, empty scans, forbidden artifacts, and resolved scope overlap.
- [x] Stage 6D — injected small-limit contracts prove that entry and finding ceilings stop scans
  without high-volume fixtures or a false normal `PASS`.
- [x] Stage 6E1 — a monotonic cooperative deadline blocks partial static scans, preserves an
  earlier `FAIL`, and checks again before a normal completion result.
- [x] Stage 6F — immutable engine floors reject excessive file limits, unauthorized excluded
  directories, and removal of required forbidden suffixes before repository scanning.
- [x] Stage 6G1 — committed static-only fixtures preserve canonical-policy `PASS` while a dedicated
  stricter policy deterministically turns the deliberate canary input into `FAIL`.
- [x] Stage 6G2 — a manual-only public workflow verifies the exact deliberate failure and then
  remains red by design without weakening the normal green static workflow.
- [x] Stage 6H — the hard static-worker deadline, bounded output, workflow deadline budget, and
  parent-exit cancellation passed exact-head checks and merged through PR #12.
- [x] Stage 6 — complete: the public canary adds the remaining buildable Xcode fixture and proves
  the pinned engine through manual static and unsigned macOS build paths.
- [x] Stage 7 — the independent permission evaluator and trusted user-authorization boundary
  passed exact-head checks and merged through PR #11.
- [x] Stage 8 — the public `MArtem/AIZenflowQualityControlCanary` provides manual `static` and
  `build` modes on a standard public runner with pinned Actions and engine SHA, no tests, signing,
  Simulator, branch protection, paid API, or paid service.
- [x] Stage 9A — evidence schema/status/verdict contracts and fail-closed trusted-context
  verification passed exact-head checks and merged through PR #11; CLI integration and evidence
  production remain later work.

Stage 4 itself added no executable engine, workflow, hook, branch rule, app profile, app test,
build, or Simulator run. Later stages added the bounded engine, verifier tests, and public canary;
they still do not establish a stable release or production-app adoption.

Stage 3 verification note: the routed startup context is measured as two explicit budgets rather
than one ambiguous total. The reusable Level 0 baseline is 2965/5000 words, while the current
task plan and handoff are 2972/3500 words. The router, context-cost reporter, and documentation
consistency checks pass; the reported 5937-word startup total is informational and does not combine
the two ownership classes into a false budget failure.

## Goal

Build a universal quality-control system for existing and new Xcode projects that substantially
reduces the need to read agent-written code line by line without pretending that automated checks
can replace product intent, targeted HIGH/CRITICAL review, or explicit user risk acceptance.

The system must progress from simple to complex and from one proven consumer to reusable policy:

```text
idea
-> manual rule
-> one minimal implementation
-> canary verification
-> first project pilot
-> second different project pilot
-> reusable promotion
-> safe bootstrap and rollout
```

## Active Scope Reset — 2026-08-11

The active objective is strictly: **find more real defects before a PR and reduce the user's
need to inspect routine agent-written code manually**. Work that does not directly improve either
outcome is deferred, even when it could harden a theoretical future evidence system.

Active work is limited to:

1. deterministic static rules with demonstrated false-positive controls and bounded inputs;
2. the existing manual zero-cost canary `static`/`build` checks;
3. one proportional local semantic review before each engine push, followed by the user-owned
   Manual Static check and Codex Review when recommended;
4. correcting an engine defect only when it can create a false pass, hide a real finding, or make
   an existing check unusable for a normal Xcode consumer.

The following move to backlog and must not start without a new, separately justified user decision:

- cryptographic attestation, executable provenance, hardened-runtime/signing controls, hostile-runner
  defenses, and other security properties beyond the declared trusted manual workflow/runner;
- general evidence production beyond the already useful static result, artifact hashing, and
  execution-boundary expansion;
- automated risk scoring, hooks, metrics, drift operations, bootstrap/migration tooling, branch
  protection, release automation, and advanced gates.

`quality static-evidence` work in open QualityControl PR #18 is therefore **deferred in its current
form**. It must not receive further security hardening or merge as a claim of hostile-environment
attestation. Before any later merge, its remaining scope must be reduced to a concrete
false-pass/false-fail correction that improves normal static-check usefulness; otherwise the PR is
closed and the work remains backlog.

This reset does not weaken existing fail-closed behavior. It stops speculative control-plane work
and makes defect detection, honest results, and low review burden the only admission criteria for
new implementation.

## Approved Constraints

- The user retains control over writing, modifying, and running tests.
- Test creation, test modification, local execution, CI execution, UI tests, Simulator work, and
  performance/Instruments work are separate permissions.
- GitHub Actions must run at zero additional monetary cost or stop before paid usage.
- GitHub Actions cannot consume the Codex weekly allowance; these are separate systems.
- Standard GitHub-hosted runners may be used for public repositories; larger paid runners and paid
  external services are forbidden by default.
- CI must not call the OpenAI API or automatically purchase Codex credits.
- GitHub workflows are manual for every project, including production projects. The user decides
  whether and when to run them; absence of a run must not block merge or be treated as a hidden
  failure.
- Codex PR review remains manually triggered by the user.
- Branch protection is explicitly deferred and outside the active implementation scope. Do not
  configure, enable, or require it until the user identifies a real release/production project and
  explicitly reopens this decision.
- Before each PR and after a material push, the agent reports separate necessity scores for GitHub
  manual verification and Codex Review, including the recommended mode and reasons.
- No app name, scheme, bundle identifier, task ID, feature decision, or app-specific exception may
  become a universal engine default.
- The active AI Fieldbook implementation plan remains separate and must not be overwritten by this
  infrastructure roadmap.
- On 2026-07-30 the user preauthorized bounded implementation, file-count expansion, branch,
  commit, push, and ready-PR publication for the remainder of this plan, limited to
  `MArtem/AIZenflowQualityControl` and `MArtem/AIZenflowDocumentation`. The agent should stop only
  for user-owned PR checks, workflow runs, merges, HIGH/CRITICAL exceptions, paid services,
  additional repositories, or a material policy/product decision.

## Final Five-Section Model

### Section 1 — Universal Knowledge And Tooling Infrastructure

Owns:

- documentation-vault normalization;
- the future executable quality-control repository;
- schemas and machine policies;
- project profiles and immutable engine locks;
- typed Xcode and SwiftPM adapters;
- bootstrap and existing-project migrator;
- verifier unit, fixture, adversarial, and GitHub canary checks;
- release, versioning, rollback, and promotion rules for the engine.

### Section 2 — User-Controlled Test Policy

Owns:

- Prototype, Controlled, and Production project modes;
- separate `allow`, `deny`, and `ask` decisions for test creation, modification, and local execution;
- separate `off` and `manual` CI execution modes; mandatory CI is outside the active policy;
- independent permissions for UI tests, Simulator work, and performance/Instruments work;
- explicit residual-risk reporting when tests are denied or unavailable.

### Section 3 — Zero-Cost GitHub CI And Merge Verification

Owns:

- manual `static`, `build`, `build-and-tests`, and `full` workflow modes;
- standard runners only, zero-cost budgets, no automatic paid overage, and no paid API calls;
- exact-SHA evidence generation and verdict aggregation;
- advisory manual checks without required CI or merge blocking;
- minimal artifact retention, cancellation, redaction, and pinned Actions.

### Section 4 — PR Risk And Recommendation Policy

Owns:

- LOW, MEDIUM, HIGH, and CRITICAL classification;
- GitHub Manual Check necessity from 0 to 100 percent;
- recommended `static`, `build`, `build-and-tests`, or `full` mode;
- Codex Review necessity from 0 to 100 percent;
- normal versus Exhaustive review recommendation;
- manual/UI verification recommendation, residual risk, and merge-readiness summary;
- recalculation after a material push or review fix.

### Section 5 — Operations, Exceptions, And Trust Growth

Owns:

- lightweight Codex hooks that enforce permissions and completion-language honesty;
- scoped exceptions and explicit emergency bypass;
- metrics, audits, drift checks, and periodic calibration;
- engine and gate rollback procedures;
- trust levels and evidence-based reduction of manual code reading.

## Implementation Roadmap

### Stage 0 — Confirm Decisions And Limits

Type: one-time global decision.

- Confirm the five-section model.
- Confirm the user-controlled test policy.
- Confirm zero-cost GitHub Actions requirements.
- Confirm manual Codex Review and manual GitHub workflow defaults.
- Confirm repository names, visibility, ownership, and pilot candidates.
- Confirm that each implementation block requires separate user approval.

Exit: an approved short authority/constraints record exists and no material decision remains implicit.

### Stage 1 — Start Manual PR Recommendations

Type: define once; use for every PR.

Before infrastructure exists, the agent reports:

```text
GitHub Manual Check: <0-100%>
Recommended mode: static | build | build-and-tests | full | none
Expected monetary cost: $0 or blocked
Test permission state: allow | deny | ask

Codex Review: <0-100%>
Recommended mode: none | normal | exhaustive

Manual/UI Check: required | recommended | not needed
Residual risk: low | medium | high | critical
Merge readiness: ready | needs verification | not ready | blocked
```

Exit: the format is understandable and useful on several real changes.

### Stage 2 — Read-Only Inventory And Migration Map

Type: one-time global analysis.

- Inventory reusable, app-specific, task-specific, duplicate, legacy, and candidate material.
- Inspect documentation, scripts, static gates, prompts, skills, hooks, templates, and workflows.
- Identify app names and assumptions embedded in apparently generic assets.
- Produce a no-write migration map before moving anything.

Exit: the user approves what will be kept, moved, rewritten, archived, or promoted.

### Stage 3 — Normalize Sources Of Truth

Type: one-time global documentation change.

Target model:

```text
MArtem/AIZenflowDocumentation
  human-readable reusable governance

MArtem/AIZenflowQualityControl
  executable engine, schemas, machine policies, reusable workflows, and verifier checks

Each project repository
  project facts, selected permissions, baseline, exceptions, and thin launchers
```

Exit: no two active sources claim authority for the same rule or executable mechanism.

### Stage 4 — Create The Minimal Executable Repository

Type: one-time global infrastructure.

Create the approved repository with an initially small structure:

```text
engine/
schemas/
policies/
adapters/
fixtures/
tests/
bootstrap/
workflows/
docs/
```

Add versioning, ownership, release rules, threat model, and a prohibition on app-specific defaults.

Exit: the repository exists as a separate protected source of truth but controls no production project.

Completion evidence on 2026-07-29:

- public repository: `https://github.com/MArtem/AIZenflowQualityControl`;
- local checkout: `/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl`;
- initial commit: `a2b9e64ec6bc21bf066089159adea0147acc494b`;
- 13 files define the root README, ignore baseline, directory boundaries, ownership/source of
  truth, versioning/release policy, and threat model;
- local `HEAD`, `origin/main`, and remote `main` matched after the explicitly authorized push;
- no tests, builds, workflows, hooks, app profiles, or executable verifier were created or run.

### Stage 5 — Implement One Minimal Vertical Slice

Type: one-time reusable engine foundation.

Initial commands:

```text
quality doctor
quality validate-profile
quality static
```

The first project profile contains only project/workspace, scheme, source paths, project mode,
test-policy references, and sandbox/cache paths. The engine validates them and runs a small static
gate set. It does not yet run tests, coverage, mutation, review, or branch protection.

Exit: the engine has no app names and distinguishes a valid fixture from an invalid one.

Completion evidence on 2026-07-29:

- SwiftPM manifest: tools 6.0, macOS 13, `QualityCore` plus `quality`, zero dependencies;
- agent static evidence: PackageDescription graph, JSON parse, Swift core/CLI warnings-as-errors
  typecheck, app-neutrality scan, ignored cache verification, and `git diff --check` pass;
- user Debug `swift build`: PASS, exit `0`;
- valid runtime profile: `PASS`, exit `0`;
- invalid traversal/cache-boundary profile: `FAIL`, exit `1`;
- positive synthetic-fixture `doctor`: `PASS`, exit `0`;
- positive one-file synthetic-fixture `static`: `PASS`, exit `0`;
- missing repository `doctor`: `BLOCKED`, exit `2`;
- Stage 5 PR #1 merged into `main` as `0917511dd8a9d48f00cd88fdc1f5f6a18547edb5`;
- the user-triggered manual static workflow passed on the selected revision with all static steps
  green; its initial non-blocking Node.js 20 deprecation annotation was removed by pinning the
  official Node.js 24-compatible `actions/checkout` v5.0.0 commit;
- the follow-up one-line workflow PR #2 passed the user-run manual static check without that
  annotation, and Codex Review reported no major issue for exact head
  `77bf03eb9f59781bfc703e636fafa99455a42b58` before merge as
  `b6cab683003a8946f5af8e8e139e8d1cbc3a1062`;
- no verifier tests, hook, app profile, app integration, Xcode project build, or production
  verifier claim was added.

### Stage 6 — Verify The Verifier

Type: implement once; require for every engine release.

With explicit user approval, add:

- schema and aggregation tests;
- path, timeout, and malformed-evidence checks;
- passing and deliberately failing fixture projects;
- bypass checks for fake success, stale evidence, forged review/coverage, skipped jobs, and profile weakening;
- a public GitHub canary proving that failing checks really fail.

Exit: no deliberately broken fixture or known bypass produces a normal `PASS`.

Stage 6A completion evidence on 2026-07-29:

- `QualityCoreTests` uses Swift Testing and contains four contract tests, including four
  parameterized invalid-profile cases;
- empty evidence is `BLOCKED`, and aggregation precedence is checked in both status orders;
- malformed, unknown-property, duplicate-property, and otherwise-valid oversized profiles cannot
  produce normal `PASS`; a valid closed profile remains the positive control;
- test fixtures and SwiftPM caches remain under ignored `.quality-control-cache/`; fixture
  creation, writes, and cleanup use pinned no-follow descriptors and remain parallel-safe;
- the user-authorized contained package `swift test` passed with warnings as errors;
- the user-triggered Manual Static Quality Check passed for every material revision;
- Codex Review findings were corrected over successive exact SHAs, and the final review reported
  no additional error for head `4e053475c7963ba14ddc9f035bda2fd3cb3acd52`;
- PR #3 merged into `main` as `7ea88bcc60f8c136759ec87204d9fd276dc3b4f9`.

Stage 6B completion evidence on 2026-07-29:

- six adversarial verifier cases cover lexical project/source traversal, project and source-root
  symlink escapes in `doctor`, source-root escape and nested symlink handling in `static`, and a
  sandbox-cache symlink escape;
- fixtures are created per test under ignored `.quality-control-cache/test-fixtures/`, use
  descriptor-relative no-follow creation and cleanup, and leave no tracked symlink objects or
  runtime fixture residue;
- a review-found fixture-helper ownership defect was fixed so a failed exclusive write cannot
  unlink a pre-existing entry; a dedicated regression test preserves the original contents;
- the final user-authorized contained package `swift test` passed 11 tests in 2 suites with warnings
  as errors, and `git diff --check` passed;
- the user-triggered Manual Static Quality Check and final Codex Review both passed for exact head
  `9070916f3821aab7fe4ef36308fe61e1512b7987`;
- PR #4 merged into `main` as `318cc86d7b0f9f9c3f25d686fba53d67a9869fcc`.

Stage 6C completion evidence on 2026-07-29:

- one new Swift Testing file covers four policy-document rejection cases, seven parameterized
  policy-contract failures, an empty source scope, an oversized file, a forbidden artifact, and
  two lexically distinct source scopes that resolve to an overlap through an in-repository alias;
- an initial 16/17 run exposed an incorrect test fixture: lexical overlap was correctly rejected by
  profile validation before the intended static check. The fixture was corrected to exercise
  resolved overlap, with no production-engine change;
- the final user-authorized contained package `swift test` passed 17 tests in 3 suites, including
  all 11 parameterized policy arguments; `swiftc -parse` and whitespace checks passed;
- runtime fixtures remained isolated under `.quality-control-cache/test-fixtures/` and were removed
  after execution;
- the user-triggered Manual Static Quality Check and final Codex Review both passed for exact head
  `c47efcf0e7542b41330a29aaf1fe8b0008caf35b`;
- PR #5 merged into `main` as `dcdedd5af78b204ffc648c21ebf84166f4e9d32a`.

Stage 6D completion evidence on 2026-07-29:

- a package-internal immutable limit value preserves the public `staticScan` API and production
  ceilings of 100,000 entries and 1,000 findings while allowing small deterministic verifier inputs;
- two Swift Testing contracts use only three tiny runtime files each and prove that the entry
  ceiling produces `BLOCKED`, the finding ceiling preserves `FAIL`, both emit
  `QC.STATIC.SCAN_LIMIT_REACHED`, and neither emits `QC.STATIC.SCAN` or normal `PASS`;
- `swiftc -parse` and `git diff --check` passed, and the user-authorized contained package
  `swift test` passed 19 tests in 3 suites with warnings as errors;
- runtime fixtures remained repository-contained and were removed after execution; the complete
  local diff and adversarial trust-boundary review found no P0–P2 issue;
- the user reported that the Manual Static Quality Check and Codex bot review both passed for exact
  head `846871aa574f53f8c69ca1b7088a1f811e122967`;
- PR #6 merged into `main` as `51c53192568bbd39e1403e86bf8eba6bd9df61ab`.

Stage 6E1 completion evidence on 2026-07-30:

- `quality static` now uses an invocation-relative `ContinuousClock` deadline of 240 seconds inside
  the existing five-minute GitHub job ceiling without changing public CLI arguments;
- cooperative checkpoints cover source validation, entry collection, entry processing, and the
  final boundary before a normal completion result; timeout emits one `QC.STATIC.TIMEOUT` with
  `BLOCKED`, while a deterministic finding recorded before timeout preserves overall `FAIL`;
- two Swift Testing contracts use progress-based injected predicates and three tiny runtime files
  each, with no sleep, wall-clock delay, shared mutable state, or serialization;
- review before verification added the required explicit wrapper return and a final deadline check
  that closes the last-entry false-`PASS` window;
- `swiftc -parse` and `git diff --check` passed, and the user-authorized contained package
  `swift test` passed 21 tests in 3 suites with warnings as errors;
- runtime fixtures remained repository-contained and were removed after execution; the complete
  local diff and adversarial trust-boundary review found no remaining P0–P3 issue;
- the user reported that the Manual Static Quality Check and Codex Review passed for exact head
  `b5c20f7cace0193674ced21fb9fff735f211601c`;
- PR #7 merged into `main` as `0c3ddb90743c17f03f35b3431b1a68914a9c5a70`.

Stage 6F completion evidence on 2026-07-30:

- static-policy validation now enforces an immutable maximum file size of 5,000,000 bytes, limits
  excluded directory names to `.git`, `.build`, and `DerivedData`, and requires `.xcresult`,
  `.xcarchive`, and `.ipa` forbidden suffixes case-insensitively;
- stricter policies remain valid: they may lower the file-size limit, omit allowed exclusions, or
  add further forbidden suffixes;
- one parameterized Swift Testing contract proves that all three weakening attempts fail before
  repository scanning with stable `QC.POLICY.*_WEAKENING` IDs and no normal scan result;
- `swiftc -parse` and `git diff --check` passed, and the user-authorized contained package
  `swift test` passed 22 tests in 3 suites;
- the complete diff and adversarial trust-boundary review found no P0–P2 issue, and the user
  reported that the Manual Static Quality Check and Codex Review passed for exact head
  `e0396e43d4732cfdebc7777edc1b90cbfcf7badd`;
- PR #8 merged into `main` as `28dac46ce85252a2d6d87c52977c0a1377908a31`.

Stage 6G1 completion evidence on 2026-07-30:

- two committed static-only fixture repositories contain one safe Swift source and one 79-byte
  `.canary-fail` input; the complete fixture payload, including policy, is 342 bytes;
- the dedicated fixture policy is stricter than the canonical policy and adds only
  `.canary-fail`, so the deliberate input remains inert during the normal repository self-scan;
- one parameterized Swift Testing contract proves a passing fixture is `PASS`, the deliberate
  fixture remains `PASS` under the canonical policy, and the same fixture becomes `FAIL` with the
  exact `QC.STATIC.FORBIDDEN_ARTIFACT` path under the dedicated policy;
- JSON parsing, `swiftc -parse`, and `git diff --check` passed, and the user-authorized contained
  package `swift test` passed 23 tests in 3 suites with warnings as errors;
- the complete diff and trust-boundary review found no P0–P2 issue, and the user reported that the
  Manual Static Quality Check and Codex Review passed for exact head
  `c5e0f40a4f24ef0a618a97119ef29ae4408db3a7`;
- PR #9 merged into `main` as `e1c13852819fec570bec56b97fbeba7267fa0c67`.

Stage 6G2 completion evidence on 2026-07-30:

- a separate `workflow_dispatch` canary uses a five-minute standard public `macos-15` runner,
  read-only permissions, pinned checkout, no persisted credentials, no artifact upload, and no paid
  service or AI API;
- the workflow requires command exit `1`, aggregate `FAIL`, exactly one non-PASS
  `QC.STATIC.FORBIDDEN_ARTIFACT` with status `FAIL` at
  `Sources/DeliberateFailure.canary-fail`, and no normal `QC.STATIC.SCAN` before writing
  `EXPECTED_FAIL_VERIFIED` and deliberately returning exit `1` to GitHub;
- Codex Review found one P2 false-verification path in the initial validator; the final commit
  compares the complete non-PASS check collection against the exact expected ID/status/path tuple;
- YAML parsing, every embedded shell block under `bash -n`, workflow trust-boundary checks, and
  `git diff --check` passed; the final Manual Static Quality Check and Codex Review passed for exact
  head `a443695edb983f2248ddcc7df7af3742ec9148fd`;
- PR #10 merged into `main` as `b6d022c365248e28a84f0e914ce7504bf081f903`;
- on that exact merge SHA, the normal Manual Static Quality Check passed and the Manual Failing
  Canary concluded red with `EXPECTED_FAIL_VERIFIED`, the exact finding ID, and the exact path.

Stage 6 remains incomplete only because buildable Xcode fixture projects still remain. The hard
local timeout, stale/forged evidence, skipped-job, and cross-SHA/bypass contracts are complete
through PRs #11 and #12. Stage 6G2 added no production engine, schema, canonical policy, buildable
Xcode fixture, app integration, Xcode build, Simulator run, or versioned evidence model.

Stage 6H completion evidence:

- QualityControl PR #12 at exact head `4e4150786c7dee81ee64763a0da74b810ac693ec`
  isolates the public `quality static` scan in a same-binary child worker with a 245-second local
  hard ceiling, a dynamically shortened five-minute-workflow budget, bounded TERM/KILL handling,
  authenticated-parent exit monitoring, and an 8 MiB output envelope;
- the parent validates output-drain completion, schema version, command, aggregate status, and
  terminal exit before forwarding the report, while a same-executable parent check blocks direct
  invocation of the hidden worker even with a forged environment marker;
- the contained warnings-as-errors package run passed 64 tests in five suites, the exact-final
  targeted worker suite passed six tests, and both normal and exhausted-deadline CLI paths passed
  through the new parent/worker boundary; workflow parsing, embedded `bash -n`, and
  `git diff --check` passed;
- Codex Review found two P2 gaps at the initial head: insufficient workflow-job deadline reserve
  and a worker that could outlive a terminated parent; corrective commit
  `4e4150786c7dee81ee64763a0da74b810ac693ec` closes both with dedicated contracts;
- the complete local diff review covered timeout-after-partial-PASS, malformed/oversized/truncated
  output, drain failure, signals, schema/command/aggregate/exit mismatch, pipe saturation, and
  direct-worker bypass, with no remaining local P0–P2 finding;
- the user reported that final Manual Static Quality Check and Codex Review passed on exact head
  `4e4150786c7dee81ee64763a0da74b810ac693ec`, and PR #12 merged into `main` as
  `3d5fd8aaf5f535f8f95a37699a3d9100d05eff6a`;
- the merged slice adds no buildable Xcode fixture, schema/profile change, evidence producer, app
  integration, Xcode/Simulator execution, GitHub settings change, or paid service.

Stage 7/9A completion evidence:

- QualityControl PR #11 at ninth corrective head `2658bbff0a61a0e3d324d9348df13de6d25874f3`
  introduces the independent permission evaluator, closed evidence schema version 1, bounded
  evidence loader, advisory statuses/verdicts, and a fail-closed verifier;
- trusted expectations bind the complete source/engine/profile/toolchain identity, permission
  snapshot, commands with terminal outcomes and complete action sets, exact command binding plus
  trusted status and message for every gate, user-authorized actions, test counts, review revision,
  artifact hashes, and residual risks outside the evidence being checked;
- stale or forged identity, permission weakening, missing/extra commands or gates, self-asserted
  user authorization or test counts, prohibited execution, exit/status mismatch, stale review,
  artifact mismatch, and false claimed verdicts return `BYPASSED`; `SKIPPED` cannot become `READY`;
- Codex Review of initial head `42c9882a380c03962eb95be19b17fced633b498a` found three P1
  bypasses and one P2 overflow path; corrective commit `3b9d94bc9676f9d14c2a3b7332ae3ba739450ef9`
  closed those findings;
- Codex Review of `3b9d94bc9676f9d14c2a3b7332ae3ba739450ef9` found four P1 trust
  gaps covering terminal outcomes, all-skipped counts, non-executed statuses, and multi-action
  commands, plus two P2 bounds/schema-parity gaps; corrective commit
  `2a09cfcb8660a418a7e54de8c49f8a901986f244` closes all six with dedicated regressions;
- Codex Review of `2a09cfcb8660a418a7e54de8c49f8a901986f244` found two P1 gaps in
  trusted command outcomes/accounting and two P2 schema/runtime parity gaps; corrective commit
  `e33c4491870c583838ec6f2612850ec6e7492059` binds expected exit codes, requires every command to
  be referenced by a gate, makes residual risks schema-unique, and aligns Unicode length units;
- Codex Review of `e33c4491870c583838ec6f2612850ec6e7492059` found two P2 gaps in
  raw command-argument privacy and status-dependent gate schema; corrective commit
  `5f41a1370cb477bea5d002fa5f74fa61545973ef` replaces raw argv with trusted SHA-256 command
  identity and mirrors runtime command-ID requirements in the schema;
- Codex Review of `5f41a1370cb477bea5d002fa5f74fa61545973ef` found one P1 executed-status
  trust gap and three P2 profile-version/schema/public-surface gaps; corrective commit
  `4abb3f68c525db3cbead5cfdca6e03ed5fbc2fc8` binds every gate status to trusted context, closes
  profile schema version 1 in memory and JSON schema, requires actions for user-decision gates,
  and removes unchecked aggregation from the public verifier surface;
- Codex Review of `4abb3f68c525db3cbead5cfdca6e03ed5fbc2fc8` found four P2 gaps in
  trusted gate messages, bounded string work, schema-invalid direct decoding, and action-dependent
  authorization schema; corrective commit `cbfdc112d6571c8bc5c221ce5ba6329e9dfe5f8b` binds gate
  messages, bounds scalar scanning, makes the full evidence model encode-only behind a bounded
  duplicate/unknown/null-rejecting loader, and aligns schema authorization with action presence;
- Codex Review of `cbfdc112d6571c8bc5c221ce5ba6329e9dfe5f8b` found two P2 gaps in
  commandless pre-execution outcomes and schema duplicate parity; corrective commit
  `dd1ab1b4105eb460e0a07e91219d86d342d7b596` permits empty command sets only when gates reference
  no command and rejects identical duplicate command, gate, and artifact objects in the schema;
- Codex Review of `dd1ab1b4105eb460e0a07e91219d86d342d7b596` found two P2 schema/runtime
  gaps in Unicode whitespace and aggregate byte limits; corrective commit
  `7970df889e39a744bbf76de8c890ea2713a634c7` defines one explicit whitespace scalar set and aligns
  evidence bounds at 64 top-level entries, 1,024 scalars per string, and an 8 MiB loader envelope;
- Codex Review of `7970df889e39a744bbf76de8c890ea2713a634c7` found one P2 ambiguous
  timezone-free verification date; documentation-only corrective commit
  `2658bbff0a61a0e3d324d9348df13de6d25874f3` removes the date without changing code/schema/tests;
- the latest code-bearing corrective contained Swift package run passed 58 tests in four suites with warnings as
  errors; JSON syntax, required-field/closed-object/action-authorization/residual-uniqueness audit,
  schema/runtime relative-path and Unicode-length parity, `git diff --check`, and the complete
  corrective adversarial diff review passed with no remaining local P0–P2 finding;
- the user reported that the final Manual Static Quality Check and Codex Review both passed for
  exact head `2658bbff0a61a0e3d324d9348df13de6d25874f3`, and PR #11 merged into `main` as
  `639c70001c15a93aa1dc0c0ae53b7f84f0865079`;
- PR #11 intentionally adds no evidence CLI integration or producer, artifact hashing, cryptographic
  attestation, hard worker timeout, buildable Xcode fixture, Xcode/Simulator execution, application
  integration, GitHub settings change, paid service, or automatic accepted-risk governance.

The merged contracts complete Stage 7, Stage 9A, Stage 6H, and the corresponding Stage 6
stale/forged/skipped/cross-SHA bypass items. The Stage 8 public buildable Xcode canary described
below subsequently closed the final Stage 6 fixture risk.

### Stage 7 — Implement The Test Permission Model

Type: define once; configure per project and task.

Support:

```text
project mode: prototype | controlled | production
test creation: allow | deny | ask
test modification: allow | deny | ask
local execution: allow | deny | ask
CI execution: off | manual
UI/Simulator/performance: independently controlled
```

Exit: no test write or execution can happen silently, and denied tests never become hidden proof of readiness.

### Stage 8 — Add One Zero-Cost Manual GitHub Workflow

Type: first single canary consumer.

- Use one public canary repository.
- Add manual `static` and `build` modes first.
- Use standard runners only.
- Pin Actions, disable unnecessary credentials, cancel stale runs, minimize retention, and call no paid API.
- Do not enable branch blocking yet.

Exit: the user can select a branch, run the workflow manually, see the exact SHA, and confirm zero cost.

Completion evidence on 2026-08-02:

- public `MArtem/AIZenflowQualityControlCanary` contains a synthetic Swift 6 macOS Xcode target;
- manual-only `static` and `build` modes use standard `macos-15`, pinned `actions/checkout`, and
  engine SHA `3d5fd8aaf5f535f8f95a37699a3d9100d05eff6a` with least-privilege read access;
- the initial manual static run passed; the initial build correctly failed on the canary entry-point
  defect rather than producing a false PASS;
- corrective PR #1 at head `386c835046a2115e1e39745e2cdc6fd5a59eb6aa` passed static typecheck and
  Codex Review with no major issue, then merged as `d601c0149d48a6aed21377cbeb04ded54c4f3183`;
- the user reported the final manual `build` PASS on merged `main`; the workflow itself includes the
  static gate and records the source and engine SHAs;
- the runner/service contract remained standard public and zero-cost, with no tests, signing,
  Simulator, branch protection, paid API, or paid service.

### Stage 9 — Add Evidence And Advisory Verdicts

Type: implement once; produce for every run.

Gate statuses:

```text
PASS
FAIL
BLOCKED
NOT_APPLICABLE
NOT_RUN_BY_USER_DECISION
SKIPPED
```

Overall verdicts:

```text
READY
READY_WITH_ACCEPTED_RISK
NEEDS_OWNER_DECISION
NOT_READY
BLOCKED
BYPASSED
```

Evidence includes exact SHAs, engine/profile versions, toolchain, executed commands, permissions,
gate results, test counts when applicable, review SHA, artifact hashes, and residual risks.

Exit: a human can understand what was and was not proved without reading raw logs.

### Stage 10 — Automate Risk And Recommendation Scoring

Type: implement once; recalculate for every PR and material push.

Inputs include changed paths, behavior impact, capabilities, uncertainty, diff size, test permission,
verification gaps, reversibility, and control-plane changes. The classifier may raise risk but may
not silently lower a deterministic risk floor.

GitHub recommendation thresholds:

```text
0-19    none
20-39   static
40-59   build
60-79   build-and-tests when permitted
80-100  full within project permissions
```

Codex Review thresholds:

```text
0-29    normally skip
30-49   optional
50-69   normal review recommended
70-84   normal review strongly recommended
85-94   exhaustive recommended
95-100  exhaustive strongly recommended, still user-controlled
```

Exit: automated recommendations remain explainable and close to manual judgments on real examples.

### Stage 11 — Implement The Governance Framework

Type: implement once; operate continuously.

- Add lightweight hooks for permission checks, protected paths, and evidence-aware completion claims.
- Add exact-scope, owned, expiring exceptions.
- Add explicit emergency bypass that never looks like normal `PASS`.
- Define minimal metrics, audit, drift, rollback, and trust-level commands.
- Do not make hooks run heavy build/test pipelines.

Exit: governance prevents silent permission or evidence violations without making normal work unusable.

### Stage 12 — First Real Pilot: Simple Project

Type: first project consumer.

Attach profiles, thin launcher, selected permissions, manual static/build workflow, evidence,
recommendations, hooks, and minimal metrics. Keep checks advisory and collect five to ten changes.

Exit: usability, time, false positives, and cost are known for one simple project.

### Stage 13 — Second Real Pilot: Different Production Project

Type: second independent consumer.

Use a project with meaningfully different structure and risks. Add manual `build-and-tests` only when
the user allows it. Collect normal/exhaustive review recommendations, evidence, exceptions, and metrics.

Exit: common behavior works without adding app-specific logic to the engine.

### Stage 14 — Promote Proven Patterns

Type: one-time reusable promotion.

Promotion rule:

```text
one project -> local candidate
two different projects -> reusable candidate
explicit review and approval -> reusable standard
```

Remove pilot-only workarounds, stabilize schema v1, release the first stable engine version, and
promote only app-neutral knowledge into reusable documentation.

Exit: the shared engine and rules are supported by evidence from at least two different consumers.

### Stage 15 — Build Safe Bootstrap And Migrator

Type: implement once; reuse for every future project.

New projects use dry-run bootstrap. Existing projects use:

```text
inventory
-> conflict report
-> migration plan
-> explicit apply
-> post-check
-> reversible rollback
```

Exit: projects adopt the system without copying or forking the engine and without losing local configuration.

### Stage 16 — Introduce Branch Protection Gradually (Deferred)

Type: future configuration once per real release/production project.

Status: deferred by explicit user decision. Do not implement, configure, or treat this stage as an
active dependency until the user explicitly reopens it after a real release project exists.

Historical design options retained only for future reconsideration:

```text
prototype  -> optional
controlled -> optional manual
production -> optional manual
```

Under the current user policy, blocking is not enabled for any project. A future branch-protection
discussion must not silently change the separate rule that CI execution remains user-triggered.

Exit if this deferred stage is ever reopened: the user explicitly approves every protection rule;
manual CI remains non-mandatory unless the user separately changes that policy.

### Stage 17 — Operate And Measure

Type: continuous, mostly automatic.

Track risk tier, selected check/review modes, CI duration and cost, review results, residual risk,
escaped defects, manual review time, bypasses, expired exceptions, and configuration drift. Do not
collect source code, secrets, private user data, or full logs as telemetry.

Exit: monthly evidence shows whether the system improves quality and reduces manual workload.

### Stage 18 — Add Advanced Gates Selectively

Type: gradual, risk-based expansion.

Candidates include coverage, integration/UI tests, mutation, sanitizers, migration/relaunch,
performance/memory, accessibility, release/archive, artifact attestation, and device matrices.

Every new gate progresses through:

```text
OFF -> OBSERVE -> ADVISORY -> REQUIRED
```

Exit: each required gate has demonstrated value, acceptable reliability, and a known cost.

### Stage 19 — Reduce Manual Code Reading By Evidence

Type: workflow change after sufficient measurement.

Trust levels:

```text
Level 0: full manual review
Level 1: intent, evidence, and critical lines
Level 2: LOW without line-by-line review
Level 3: selected MEDIUM without full diff review
```

Level 2 requires at least 20-30 representative successful PRs with no unexplained false-green or
HIGH escaped defect. Level 3 requires at least 30-50 representative PRs and stable metrics.
HIGH/CRITICAL and control-plane changes retain targeted human review.

## First Approved Implementation Block When Work Begins

Do not create the entire system at once. The first bounded block is:

1. record the accepted Stage 0 provisional defaults;
2. finalize the Stage 1 recommendation format;
3. perform the Stage 2 read-only inventory;
4. produce the migration map;
5. stop for user review.

No new repository, workflow, hook, branch rule, app test, build, or Simulator run belongs in that first block.

## Accepted Provisional Defaults

The user accepted the recommended defaults on 2026-07-28. They are active planning assumptions,
not irreversible commitments, and may be revised as pilots produce evidence.

1. Executable repository: `MArtem/AIZenflowQualityControl`.
2. Repository visibility: public, with no secrets or private product code.
3. Canary repository: public `MArtem/AIZenflowQualityControlCanary`.
4. Engine code, schemas, policies, workflows, and governance changes are prepared through PRs and
   authorized by the user; Codex may prepare changes but does not self-approve policy weakening,
   exceptions, or bypasses.
5. `MArtem/AIZenflowDocumentation` remains public, including app-neutral quality-control governance.
6. Pilot order: disposable canary fixture first, AI Fieldbook as the first real production consumer
   after its active work is closed, and TchopApp later as the legacy-complexity consumer.
7. New Xcode projects default to `Controlled` until the user explicitly classifies them as
   `Prototype` or `Production`.
8. Test defaults:
   - Prototype: creation/modification `deny`, local execution `ask`, CI `off`.
   - Controlled: creation/modification/local execution `ask`, CI `manual`.
   - Production: creation/modification/local execution `ask`, CI `manual`.
   - UI tests, Simulator work, and performance/Instruments work remain independently `ask`.
9. CI is never mandatory under the active policy. The user manually decides whether and when to
   run it for every project; `required` is not an active mode.
10. Branch protection remains deferred and outside the active scope until the user explicitly
    reopens it for a real release/production project. Reopening it does not silently make CI mandatory.
11. Public standard GitHub-hosted macOS runners are acceptable. Larger paid runners are forbidden.
12. Private-repository fallback: use included GitHub quota with zero additional spending first;
    consider a self-hosted Mac only if later justified and explicitly approved.
13. Initial manual CI time budgets: `static` 5 minutes, `build` 15 minutes,
    `build-and-tests` 30 minutes, and `full` 60 minutes.
14. Codex Review remains advisory and user-triggered at every score, including 95-100 percent.
15. A material new push invalidates the previous review recommendation and requires recalculation;
    the user decides whether to request another review for the new SHA.
16. Only the user approves HIGH/CRITICAL exceptions and emergency bypasses in the solo workflow.
17. A normal temporary exception expires after 30 days unless the user renews it.
18. Review compact metrics monthly or after every 10 PRs, whichever comes first.
19. New-project adoption remains explicit opt-in until at least two different pilots validate the system.
20. Stable engine releases use signed tags and checksums starting with the first stable release.

## User Manual Actions

Completed:

- [x] approve the Stage 0 decisions;
- [x] create the public executable repository and authorize its initial Stage 4 push;
- [x] choose public visibility for `MArtem/AIZenflowQualityControl`.
- [x] approve and complete the bounded Stage 5 Swift vertical slice.
- [x] authorize and complete the bounded Stage 6A verifier-contract tests and local package test.
- [x] authorize and complete the bounded Stage 6B path/symlink adversarial tests and local package
  test.
- [x] authorize and complete the bounded Stage 6C static-policy/bounded-scan tests and corrective
  local package test.
- [x] authorize and complete the bounded Stage 6D high-volume ceiling contracts, contained package
  test, Manual Static Quality Check, Codex Review, and PR merge.
- [x] authorize and complete the bounded Stage 6E1 cooperative timeout contracts, contained package
  test, Manual Static Quality Check, Codex Review, and PR merge.
- [x] authorize and complete the bounded Stage 6F immutable policy-floor contracts, contained
  package test, Manual Static Quality Check, Codex Review, and PR merge.
- [x] authorize and complete the bounded Stage 6G1 committed static fixture contracts, contained
  package test, Manual Static Quality Check, Codex Review, and PR merge.
- [x] complete the bounded Stage 6G2 public failing workflow, corrective review push, PR merge,
  same-SHA green normal static run, and red `EXPECTED_FAIL_VERIFIED` canary run.
- [x] create and authorize the public `MArtem/AIZenflowQualityControlCanary`, enable GitHub Actions
  and Codex Review access, complete manual static/build validation, and merge corrective PR #1.

Remaining:

- [ ] configure a zero-spend Actions policy if a future private repository is used;
- [ ] approve the first and second pilot repositories;
- [ ] choose per-project test and CI modes;
- [ ] manually click `Run workflow` for manual checks;
- [ ] manually request `@codex review` when recommended;
- [ ] approve or reject HIGH/CRITICAL exceptions and emergency bypasses;
- [ ] only after a future explicit request for a real release/production project, review and
  optionally enable branch protection;
- [ ] periodically review compact quality metrics and approve trust-level changes.

Most files, profiles, schemas, scripts, workflows, and documentation can be prepared by Codex after
the user approves the corresponding bounded implementation block.

## Explicit Non-Goals

- No giant app-guessing `verify.sh`.
- No separate evolving verifier fork in every project.
- No automatic test writing or execution that bypasses user permission.
- No paid GitHub runner, OpenAI API, or external quality service by default.
- No local JSON, environment variable, comment, skipped job, or stale review treated as authoritative proof.
- No exhaustive Codex Review or full advanced gate matrix for every trivial change.
- No claim that automated checks eliminate targeted human review for HIGH/CRITICAL changes.
- No reduction in manual code reading before representative pilot evidence exists.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
