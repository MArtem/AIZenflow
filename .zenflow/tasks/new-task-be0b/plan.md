# Universal iOS/Xcode Quality-Control — Luna High Execution Plan

## Outcome

Every current and future Git repository containing an iOS/Xcode project receives the same governed,
versioned quality system. Runtime and external AI checks remain user-triggered, but missing, stale,
skipped, unauthorized, or unverifiable evidence can never be reported as success.

## Temporary Detour — Swift Strict Concurrency Audit

This bounded detour preserves the plan below and returns to it after the concurrency baseline is
verified. The user explicitly authorizes build/run verification on the current Luna high route,
while retaining PR merge and GitHub `workflow_dispatch` control.

- [ ] Inventory canonical active Git repositories and Xcode projects; exclude fixtures, archived
  snapshots, and task-created duplicates from mutation.
- [ ] Inspect effective `SWIFT_STRICT_CONCURRENCY` for every target/configuration/xcconfig and
  record projects that already equal `targeted`.
- [ ] Apply only missing/incorrect `SWIFT_STRICT_CONCURRENCY = targeted` settings in bounded,
  reviewable repository patches; preserve unrelated dirty files.
- [ ] Build and launch each changed project with task-local DerivedData/logs; fix only proven
  concurrency/compiler/runtime failures and repeat the affected verification.
- [ ] Review exact diffs/SHAs, prepare and push PRs where needed, then report for user merge and
  manual workflow dispatch; record evidence and return to the main plan.

Canonical ownership stays split:

- `AIZenflowDocumentation`: policy, routing, templates, bootstrap contract, interpretation.
- `AIZenflowQualityControl`: schemas, commands, Xcode adapters, evidence, fixtures, workflows.
- App repositories: project facts, permissions, applicability, thin launcher, workflow wiring, local
  exceptions. They do not redefine global policy.

## Locked Decisions And Execution Rules

- [x] Scope is Xcode-managed iOS repositories; no generic multi-language engine is required.
- [x] GitHub verification remains manual `workflow_dispatch`; branch protection is not required.
- [x] External PR Codex Review and whole-project/feature review run only when the user requests them.
- [x] After the user authorizes PR creation, the agent always performs internal Exhaustive review of
  the entire PR range before push/PR creation.
- [x] Builds, tests, Simulator/device, archive, signing, and release operations remain independently
  permission-bound. Existing permission covers the current engine package tests/build and public
  canary builds, not unrelated application runtime work.
- [x] All caches, DerivedData, clones, logs, and temporary artifacts stay under
  `/Users/Artem/.zenflow`; secrets are never inspected.
- [x] Luna high executes this route without model switching. It loads only Level 0, current
  plan/handoff, and the route needed for the active batch. A failure triggers bounded diagnosis,
  not a broad context refresh or weaker gate.
- [x] Keep implementation batches self-contained and normally within three source files. If a
  necessary batch materially exceeds that boundary or changes authority, stop for approval.
- [x] Preserve all user-owned dirty files. In particular, never edit or stage
  `AIZenflowQualityControl/AGENTS.md`.

## Current Trusted State

- [x] Canonical human policy and new-project governance are published in Documentation Vault.
- [x] Final engine baseline commit is `87fec01138c3c6fbd0ab17fa5717b69a1b25e7df`; current engine
  HEAD is `9f3f3676b56e41e56bc30cd9c6d155738df32f6a`. Swift sources are unchanged from the
  previously verified `c4470e5` state (162 tests in 16 suites, warnings-as-errors compile, no
  failures); subsequent commits add only bounded Python adapters, fixtures, schema/catalog, and
  documentation.
- [x] Adapter proof is recorded in
  `.zenflow/tasks/new-task-be0b/runtime/secret-adapter-proof/receipt.json`; no app runtime
  build/test was run.
- [x] Final canary commit is `388e885614f3ff6f5433599f3e4bb872ea2cfa27`; profile/workflow contain
  exactly five references to engine SHA `9f3f3676b56e41e56bc30cd9c6d155738df32f6a` and remain
  manual-only. The adapter-aware repin proof is recorded in
  `.zenflow/tasks/new-task-be0b/runtime/canary-adapter-repin-proof/receipt.json`.
- [x] Membership fix is committed: structured `SwiftCompile`/`CompileC` labels are accepted,
  `builtin-Swift*`/linker wrappers do not create false blocks, and raw compiler unresolved inputs
  still fail closed. Focused membership suite passed 8/8.

## Phase A — Validate The Current Membership Fix

- [x] Confirm the only intended engine changes are
  `XcodeBuildLogMembership.swift` and `XcodeBuildLogMembershipTests.swift`; preserve `AGENTS.md`.
- [x] Review these invariants: structured per-source sections are authoritative; driver wrappers
  cannot create false `BLOCKED`; raw compiler response files still fail closed; sources outside the
  declared roots fail; an empty/unproven compiler set cannot PASS.
- [x] Run `git diff --check`, then the focused membership suite using only task-local caches.
- [x] Run focused supervisor/verifier/coordinator suites to catch producer-consumer regressions.
- [x] Run the full package suite and warnings-as-errors compile: 159 tests in 16 suites, 0 failures.
- [x] If any test fails, fix the smallest causal surface and repeat focused then full checks. Never
  change expected evidence semantics merely to make the test green.

Exit: current patch is compiled, regression-tested, and semantically reviewed with no P0-P2 issue.

## Phase B — Freeze The Final Engine Commit

- [x] Review the complete engine range from trusted base
  `4100c2103ba2a39c82bd782787bde4fefe501acd` through working state against the quality contract.
- [x] Search affected callers, schemas, README claims, profile-v1 compatibility, and every credible
  false-PASS or irreversible-state route. Fix P0-P2; fix or report P3; repeat one complete review.
- [x] Stage only intended engine files and amend the existing logical commit without including
  `AGENTS.md`.
- [x] Record final engine SHA, tree, exact test/build evidence, omitted checks, and residual risk.
  Verify HEAD is unchanged after the receipt.

Exit: one final local engine commit; working tree differs only by the pre-existing user file. No push.

## Phase C — Re-pin And Freeze The Canary Consumer

- [x] Update only the canary profile engine revision and workflow checkout/expected revision to the
  final engine SHA; keep the project app-neutral and manual-only.
- [x] Validate profile JSON, pbxproj, shared scheme XML, workflow YAML, ignored runtime directory,
  and `git diff --check`.
- [x] Run engine profile validation. Before a real build, the only acceptable blocker is the
  documented need for authoritative Xcode graph evidence; no schema or contract error may appear.
- [x] Review the complete canary range from
  `af85bef43a6981832459651fadfa021fe69458f7`, amend its single logical commit, and record final
  canary SHA. Confirm the canary worktree is clean.

Exit: final engine and canary commits mutually pin exact immutable SHAs. No push.

## Phase D — Recreate Trusted Clean Inputs

- [x] Retire only task-created obsolete detached worktrees through `git worktree remove`; do not
  delete repositories or user files.
- [x] Create fresh detached engine and positive-source worktrees at the final SHAs under the task
  runtime directory. Verify HEAD, clean status, canonical origin, and ignored runtime output.
- [x] Build the engine with warnings-as-errors and task-local SwiftPM/scratch/cache paths; final
  ad-hoc binary CDHash is `94253be3aeae4194f1f8b1f0e7212215296d630b`.
- [x] Extract and validate the engine binary CDHash and bind it to the final engine SHA. Earlier
  binaries, CDHashes, result bundles, and receipts were treated as obsolete.

Exit: clean immutable source inputs plus a freshly authenticated engine binary.

## Phase E — Positive Public Build-Evidence Canary

- [x] Invoke only the public `quality build-evidence` boundary against the clean canary SHA/profile,
  with the declared local execution context and sandboxed result/cache paths.
- [x] Require exit 0, top-level/report `PASS`, non-null evidence, verification `READY`, and no
  verification issues.
- [x] Verify binding to exact source SHA, engine SHA/CDHash, tracked profile hash, Xcode/Swift
  toolchain, scheme/configuration/destination/action, authority, timeout, and artifact hashes.
- [x] Confirm the structured build result proves `Sources/main.swift` membership for both compiled
  architectures, zero build errors/warnings, and clean source/engine worktrees.
- [ ] If result is `BLOCKED` or `FAIL`, inspect that exact stage/result bundle. Fix only a proven
  producer/verifier defect; do not reinterpret the result as PASS or broaden scope.

Exit: the real successful Xcode build produces authenticated exact-SHA PASS evidence.

## Phase F — Negative Public Canary

- [x] Create a disposable local clone from the final canary commit inside task runtime, preserve the
  canonical origin identity, add one deliberate Swift compile error, and commit it only in that
  disposable clone. Keep the official canary branch untouched.
- [x] Run the same public boundary against the negative exact SHA and final engine.
- [x] Require non-zero exit, top-level/report `FAIL`, null evidence/verification, and stable check
  `QC.BUILD_EVIDENCE.BUILD_FAILED`; confirm there is no false PASS and the negative checkout stays
  clean after execution.
- [x] Remove the disposable clone during cleanup after its compact receipt is recorded.

Exit: success and failure paths are both proven through the same public interface.

## Phase G — Close Remaining Engine Contract

Proceed capability-by-capability; first prove whether each item already exists, then implement only
the missing surface.

- [x] Audit confirms profile-v2 representation/compatibility already covers multiple schemes,
  configurations, destinations, test plans, applicability, permissions, authoritative membership,
  portable sandbox paths, and engine pins.
- [x] Add bounded in-memory evidence aggregation with authenticated shared identity, conservative
  deduplication/ordering, explicit empty/limit/mismatch rejection, and normal verifier reuse; the
  aggregate API is covered by focused tests.
- [x] Expose `aggregate-evidence` as a bounded CLI over public execution receipts and an explicit
  caller-owned trusted expectation; add strict receipt/expectation loaders and versioned result
  schemas. Empty, malformed, duplicate, oversized, or unverifiable inputs remain evidence-free
  `BLOCKED`.
- [ ] Complete `doctor`, static evidence, build, permitted-test, and manual-mode orchestration with
  one status vocabulary: `PASS`, `FAIL`, `BLOCKED`, `NOT_APPLICABLE`, `NOT_RUN_BY_USER_DECISION`,
  `SKIPPED`, `BYPASSED`.
  - [x] Manual mode execution envelope now sequences authenticated static/build boundaries and
    preserves child evidence without synthesizing a composite PASS.
- [x] Audit confirms static/build evidence binds source/engine/profile/toolchain/permission/
  command/artifact identity; timeout and repeated-read facts are enforced by the supervisors.
- [x] Audit confirms bounded fixtures cover malformed/unknown profiles, stale SHA, dirty trees,
  timeout, traversal, symlink escape, forged/tampered evidence, changed permission, wrong selection,
  missing runtime, and deliberate failures.
- [x] Existing reusable defaults are app-neutral and fail closed; no app name, bundle ID, scheme,
  destination, absolute user path, or unqualified Xcode default.

Exit: no absent or untrusted evidence can produce PASS, and v1 consumers remain compatible.

## Phase H — Bootstrap, Manual Modes, And Deterministic Catalog

- [x] Implement reversible `inventory -> dry run -> explicit apply -> post-check -> rollback` for
  new and existing repositories, with exact/overlay/local/conflict classification and idempotent
  second dry run.
  - [x] Read-only declarative inventory/dry-run foundation added with bounded closed plan schema,
    conflict/symlink/traversal fail-closed behavior, deterministic classification, and idempotent
    reports. Explicit apply, post-check, and rollback are implemented with a bounded journal.
  - [x] Explicit authorized apply, journal-bound post-check, and hash-guarded rollback are now
    implemented; conflicts/overlays remain review-only and changed rollback targets are preserved.
- [ ] Generate only app-owned facts and thin consumers: profile, launcher, manual workflow, PR risk
  card, applicability/adoption record. Never overwrite conflicts or copy engine logic.
  - [x] Existing canary profile/workflow repinned to the current immutable engine SHA with five
    exact references; no runtime build or push was performed.
  - [x] Authorized pilot consumers now contain only app-owned schema-v2 profiles and thin
    manual-only workflows. MVVMExample commit `38e9f3990e6bea1f0cdd8c5003b7946927f9d507` and
    Tchop commit `a5a93dacdb9613920212dc07a67194f8074b4230` both pin engine
    `9f3f3676b56e41e56bc30cd9c6d155738df32f6a`; no app source or test files changed.
  - [x] Consumer adoption for `QC.GENERATED.OWNERSHIP` is prepared as three bounded PRs. MVVMExample
    PR #11 (`c8e10316ce55de17f442225d4fefe840ed639868`), AIZenflow PR #19
    (`3991e468bbb2272d31892d2f57924fe46ef522f4`), and canary PR #3
    (`07110bb9792e03a231d3e675deef47de5e480838`) pin merged engine
    `cd6f575a99e606496651292e6ee8d43c6c22f8c9`, add explicit manifests, and run the new gate
    before static/build checks. All three are merged; manual static runs #25/#4/#4 are green,
    including the generated-ownership step. Canary build remains intentionally skipped.
- [ ] Implement `static`, `build`, `build-and-tests`, and `full` as permission-aware manual modes
  sharing one profile and evidence meaning locally and on GitHub.
  - [x] Add deterministic `quality mode-plan` contract and schema. It expands all four modes,
    preserves applicability/permission state, and never treats pre-execution
  `NOT_RUN_BY_USER_DECISION` as runtime PASS. Actual execution now covers authenticated static/build sequencing.
  - [x] Add `quality mode-execute` for authenticated static/build sequencing; unavailable test/UI/
    archive/signing/feature-flag/privacy capabilities remain explicit non-success or N/A states.
- [ ] Give each deterministic check a stable ID, scope, severity, applicability, remediation, and
  positive/negative fixture. Cover compilation, new first-party warnings, concurrency where
  supported, dependency/lock drift, format/lint, secrets, generated artifacts, localization,
  resources, privacy, configuration/signing changes, disabled tests, and tracked TODO/FIXME.
  - [x] Publish the versioned 18-entry canonical catalog/schema with stable IDs, scope, severity,
    applicability, remediation, fixture references, and explicit implemented/staged/review status.
  - [x] Implement the first executable catalog adapter `QC.SECRETS.TRACKED` with bounded clean-HEAD
    scanning, positive/negative fixtures, a closed result schema, and conservative `BLOCKED` paths.
  - [x] Implement `QC.TODO.OWNER` with comment-marker scoping, bounded metadata syntax, positive/
    negative fixtures, and a false-positive regression against workflow strings.
- [ ] Make architecture/literal/complexity patterns review candidates unless a narrow project
  contract makes them deterministic. Adopt pinned SwiftLint/SwiftFormat only if the dependency
  policy and fixtures show net value; formatting remains check-only in verification.
  - [x] Decision recorded: keep SwiftLint/SwiftFormat staged until immutable tool versions,
    bounded adapters, and positive/negative fixtures prove net value. Receipt:
    `runtime/format-lint-decision/receipt.json`.
  - [x] `QC.GENERATED.OWNERSHIP` is implemented in canonical engine PR #21 and integrated into
    the three bounded consumer PRs above. Its contract is repository-neutral, fail-closed,
    bounded, and separate from Xcode build-graph evidence; it does not infer generator ownership
    from filenames alone. GitHub execution remains manual; the three merged consumer workflows
    now provide public static PASS evidence for this adapter.
  - [x] Implement `QC.DEPENDENCY.LOCK_DRIFT` with bounded lockfile parsing, immutable Git-HEAD
    inputs, positive/negative fixtures, explicit missing-lock applicability, and test-writing
    coverage (18 Python tests). Engine PR #22 is merged at
    https://github.com/MArtem/AIZenflowQualityControl/pull/22, head
    `0972bf2033e432952fb7eed2583266ea96aeb660`; consumer wiring remains a separate post-merge block.
  - [x] Prepare post-merge consumer adoption for `QC.DEPENDENCY.LOCK_DRIFT`: repin all three
    profiles/workflows to engine merge `2757d4ad9626275d3cc4be4f8815b64e72c625c9`, add the
    required manual adapter step, and review exact consumer HEADs. Open PRs: MVVMExample #12,
    AIZenflow/Tchop #20, QualityControlCanary #4. Manual workflow execution remains pending.
  - [x] Implement `QC.LOCALIZATION.CATALOG` with bounded `.strings`, `.stringsdict`, and
    `.xcstrings` parsing, duplicate/unsupported input blocking, key parity/fallback findings,
    positive/negative fixtures, schema/catalog/docs, and 32 Python tests. Engine PR #23 is open
    at exact head `2305108f052c52071a233753dbfd05058b048472`; MVVMExample and canary smoke PASS,
    while Tchop exposes six real parity findings from its intentionally partial German rollout.
  - [x] After engine merge `096e0d0998efafaedf3ff34c2c180885bd8d2e7f`, prepare consumer adoption
    with manual-only localization steps. Open PRs: MVVMExample #13 (`1c964d4`), AIZenflow/Tchop
    #21 (`2af57fab`), and QualityControlCanary #5 (`b0f4781`). Profiles/workflows pass JSON/YAML/
    diff checks; user-reported manual workflow_dispatch results are PASS for MVVMExample and
    canary, and the expected FAIL for Tchop. Tchop exposes the existing six parity findings; no
    exception or app-source change was added.
  - [x] Implement `QC.RESOURCES.ASSETS` with bounded Xcode asset-catalog metadata parsing,
    filename ownership, orphan/duplicate/missing-resource detection, forbidden compiled-output
    detection, high-confidence literal reference checks, positive/negative fixtures, schema/
    catalog/docs, and 13 Python tests. Engine commit `46bb0cda22e4f8776dd4303eacbc846a6befe0db`
    is based on `2305108f052c52071a233753dbfd05058b048472`; engine PR #24 merged as
    `6ebf4b6e41e501fb630da386cc5490bf1495d580`; receipt:
    `runtime/resources-assets-adapter/receipt.json`. Consumer smoke for MVVMExample, Tchop, and
    QualityControlCanary is PASS; app builds, tests, Simulator, and runtime bundle membership are
    intentionally not claimed. Post-merge consumer wiring is complete in MVVMExample #14,
    AIZenflow/Tchop #22, and QualityControlCanary #6. User-run workflows recorded MVVMExample
    #28 (`33653619069`) PASS with the resources step PASS, Canary #7 (`33653665358`) PASS with
    the resources step PASS and build skipped by static mode, and Tchop #7 (`33653647456`)
    FAIL at the pre-existing `QC.LOCALIZATION.CATALOG` gate; its resources step was correctly
    skipped by fail-fast ordering. Receipt: `runtime/resources-assets-adapter/receipt.json`.
- [ ] Keep GitHub workflows manual, least-privilege, action-pinned, concurrency/time bounded, and
  free of paid AI calls.
  - [x] Canary workflow audit passes these constraints and runs the implemented deterministic
    adapters before static/build. Receipt: `runtime/workflow-governance-audit/receipt.json`.

Exit: safe adoption and identical local/manual-GitHub semantics without duplicated policy.

## Phase I — Review, Flags, And Release Safety

- [ ] Encode the internal pre-PR contract: after `делай PR`, refresh target, record merge-base,
  review the full range, run Exhaustive review, fix P0-P2, repeat full review, commit/review exact
  HEAD, then push/create only with explicit repository authorization. Any material commit
  invalidates the receipt. Never trigger external Codex Review automatically.
  - [x] Audit confirms the canonical reusable `IOS_PR_REVIEW_TEMPLATE.md` already encodes the full
    user-authorized PR gate, complete-range review, repeat-after-fix, exact-HEAD receipt, and
    external-review prohibition. Receipt: `runtime/pre-pr-contract-audit/receipt.json`.
- [ ] Require every app profile to state feature-flag applicability. Where applicable, use app-owned
  keys, safe defaults, kill switch, owner/expiry, staged rollout, rollback, analytics integrity, and
  cleanup; otherwise require a reasoned `NOT_APPLICABLE`.
  - [x] Audit confirms profile-v2 requires all eight capability applicability records, including
    `featureFlags`; the canary records explicit `notApplicable` reasons without becoming an app default.
- [ ] Record release applicability for signing/entitlements, versions, privacy manifests/labels,
  required-reason APIs, archives, dSYMs/crash reporting, smoke flows, migrations, offline/session
  behavior, staged distribution, rollback, accessibility, performance, and operations. Unrun items
  remain residual risk.
  - [x] Audit confirms the canonical `IOS_RELEASE_CHECKLIST.md` covers the release surfaces and
    requires explicit residual-risk statuses for unrun/unavailable evidence. Receipt:
    `runtime/applicability-release-audit/receipt.json`.

Exit: review and release safety are enforceable contracts, not silent checklist omissions.

## Phase J — Pilots, Publication, And Rollout

- [ ] Pilot bootstrap on the disposable canary, then migration on two explicitly authorized,
  structurally different iOS repositories: one small app and one multi-target app with
  extension/package/test boundaries.
  - [x] Read-only discovery identified `MVVMExample` and the Tchop multi-target worktree as clean,
    structurally distinct candidates with bootstrap markers. Profile facts and migration remain
    pending explicit pilot authorization. Receipt: `runtime/pilot-discovery/receipt.json`.
  - [x] Read-only inventory/dry-run preserved both existing `AGENTS.md` overlays as
    `OVERLAY_PRESENT`/`REVIEW_REQUIRED`. Receipt: `runtime/pilot-bootstrap-boundary/receipt.json`.
  - [x] Explicit pilot apply completed as bounded consumer changes: MVVM's PR trigger was removed
    to restore manual-only policy, and Tchop received a new manual-only workflow. Existing overlays,
    source, tests, and deferred app adoption records were not overwritten.
  - [x] Full reviewed branches were pushed and opened against `main`: MVVMExample PR #7
    (`b692a47718ce3a231bff091f40668eb647f8ebc9`) and Tchop PR #16
    (`a9fcafb4589bd4530170fd3cd74bc1c8f8b13ef0`). External Codex Review was intentionally not
    triggered by user decision.
  - [x] After merge, MVVM workflow run #21 exposed an integration defect: nested engine checkout
    made the consumer tree unclean and caused deterministic checks to return `BLOCKED`. Corrective
    workflow-only PRs were opened: MVVMExample #9 (`8027224`) and Tchop #17 (`92cd7a12`), and
    subsequently merged. MVVM PR #8 was merged before this final path correction and is superseded.
  - [x] The corrective runs then exposed the intended schema-v2 Xcode graph boundary: ordinary
    `static` correctly remained `BLOCKED` without authenticated source-membership evidence. The
    canonical engine now provides an explicit, disclosed `--scope explicit-source-paths` mode
    while preserving strict default/static-evidence behavior. Engine commit `9ac4cca4` is pushed;
    engine PR #20, MVVMExample PR #10, and Tchop PR #18 are open. Both pilot branches pin that
    exact SHA and run only the bounded source-path scan.
  - [x] After PR merge, the user manually ran MVVMExample `Static quality` and Tchop
    `Manual Quality Check` and reports both workflows green. This proves the bounded scoped static
    workflow path only; Xcode build-graph, app build/test/runtime, and release evidence remain
    pending by authorization and contract.
- [ ] For each pilot prove dry-run safety, apply, idempotence, rollback, exact-SHA static evidence,
  one authorized runtime mode, deliberate failure, local/GitHub parity, and pre-PR receipt.
  - [ ] Remaining pilot evidence is intentionally pending: no app build/test/runtime mode was
    authorized and no deliberate-failure branch was created. MVVMExample and Canary provide public
    static/resource PASS evidence; Tchop is blocked by its existing localization-catalog FAIL and
    therefore did not reach the resource step. Xcode build-graph, app runtime, and release claims
    remain unproven.
- [ ] Stop promotion for any false PASS, destructive migration, permission bypass, unbounded
  process/artifact, or project-specific reusable default.
- [ ] Publish compatible Documentation and engine revisions only after semantic review, schemas,
  migration/rollback notes, checksums, secret/diff/index/routing/boundary checks, and release
  rollback rehearsal. Documentation Vault may be committed/pushed under its standing authority;
  engine/canary/consumer pushes remain explicitly authorized actions.
- [ ] Adopt current repositories by canonical repository/default branch in bounded clean batches;
  dirty/conflicting repositories are preserved and recorded as deferred with owner/revisit trigger.
- [ ] Make bootstrap admission mandatory for every future iOS/Xcode Git repository, including one
  created outside Codex and first opened later. Add periodic read-only drift inventory; never
  rewrite projects automatically.

Exit: every eligible repository is adopted or explicitly deferred, and new repositories discover
and apply the same pinned system automatically.

## Final Closure

- [ ] Review exact final diffs and authority/consumer claims for Documentation, engine, canary, and
  each authorized pilot; P0-P2 block publication, push, promotion, and PR.
- [ ] Record compact receipts with bases/HEADs, toolchains, permissions, checks, omitted/reused
  evidence, findings, residual risks, remote parity where pushed, and rollback path.
- [ ] Remove only task-created worktrees, clones, result bundles, caches, and scratch builds using
  explicit paths. Preserve canonical local commits and every user-owned change.
- [ ] Update plan/handoff within the compact task-state limit and mark only evidence-backed items
  complete.

Completion means: policy is canonical and published; engine is versioned and fail-closed; adoption
is reversible; manual modes have identical evidence meaning; canary and two pilots pass; all current
repositories are adopted/deferred; future repositories are admission-gated; internal Exhaustive
review always precedes assistant-created PRs; external reviews remain user-controlled; no skipped or
unavailable evidence is represented as PASS.
