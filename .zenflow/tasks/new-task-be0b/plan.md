# Universal iOS/Xcode Quality-Control — Active Execution Plan

## Outcome

Every eligible Git repository containing an iOS/Xcode project receives one governed, versioned,
fail-closed quality system. Policy remains canonical in Documentation Vault, executable behavior in
`AIZenflowQualityControl`, and project facts/permissions in each app repository. Missing, stale,
skipped, unauthorized, or unverifiable evidence must never become `PASS`.

The detailed historical execution plan remains recoverable in Git history (including the prior
Universal plan revisions); this file is the compact executable state required for continuation.

## Current authority and restrictions

- Mode/model: **эконом / GPT-5.6 luna**; no switch is required for the current bounded route.
- All work, caches, logs, DerivedData, and temporary artifacts stay under
  `/Users/Artem/.zenflow`; never inspect `/Users/Artem/.zenflow/secrets/`.
- Do not edit or stage user-owned `AGENTS.md`; do not modify tests unless the active adapter block
  explicitly reopens test-writing. User controls PR merges, GitHub `workflow_dispatch`, external
  Codex Review, and app/runtime verification unless explicitly reopened.
- Strict Swift concurrency remains mandatory: no `@unchecked Sendable`, `nonisolated(unsafe)`,
  `@preconcurrency`, warning suppression, or fake/blanket `@MainActor`.
- Every non-trivial change uses the engineering change contract, complete final-diff review, and
  exact-SHA receipt before an authorized push.

## Completed baseline

- [x] Canonical documentation, routing, manifests, boundaries, baseline mirrors, and task-state
  integrity repaired and synchronized; final Documentation Vault receipt is pushed and clean.
- [x] Swift strict-concurrency and Swift 6 language-mode migrations are complete for all 80
  authoritative tracked Xcode projects; production forbidden escapes were removed with real
  ownership/isolation boundaries. Build/install/launch evidence and residual limits are recorded
  under `.zenflow/tasks/new-task-be0b/runtime/concurrency-audit/`.
- [x] QualityControl engine foundation, evidence identity/aggregation, reversible bootstrap,
  permission-aware mode planning/execution, and catalog schema are implemented and fail closed.
- [x] Executable adapters through `QC.RESOURCES.ASSETS` are implemented with bounded fixtures and
  documented evidence. Consumer wiring for the completed adapters is merged where authorized.
- [x] Manual-only workflow governance, PR contract, applicability/release audits, and pilot
  discovery/bootstrap boundary are recorded. Stale branches and replaced artifacts were not merged
  or deleted when that could lose history.

## Remaining implementation route

### Phase H — executable quality-control contract

- [x] Complete permission-aware mode orchestration without synthesizing composite `PASS`; keep
  `PASS`, `FAIL`, `BLOCKED`, `NOT_APPLICABLE`, `NOT_RUN_BY_USER_DECISION`, `SKIPPED`, and
  `BYPASSED` consistent across local and manual GitHub paths. Unsupported dedicated evidence
  boundaries remain explicit terminal non-success/N/A states.
  - [x] Mode planning preserves profile `deferred` as `NOT_RUN_BY_USER_DECISION`, keeps factual
    `notApplicable` as `NOT_APPLICABLE`, blocks prohibited actions before execution, and emits
    capability-specific remediation. QualityControl commit `0429c48b871c19457433155e814909451dd25e9a`.
  - [x] `mode-plan` and `mode-execute` use the same conservative top-level status precedence;
    QualityControl commit `f1548d6621c89ae57f281b0b7013156ec17ffd39` is published on `main`.
  - [x] `build-and-tests`/`full` expose every profile-governed capability, including snapshot tests,
    observability, and platform capabilities, without synthesizing unsupported evidence;
    QualityControl commit `1d224ad66673bd9cd6e65587f0139a6139b18e53` is published on `main`.
  - [x] `mode-execute` preserves the requested mode in invalid-argument and bounded-output failure
    envelopes instead of hardcoding `static`; QualityControl commit
    `b529226c5313f96be1f1aaecfc3a65e3429f9b42` is published on `main`.
- [ ] Implement the next staged deterministic catalog adapter only after inspecting its current
  producer/consumer surface. Each adapter needs stable ID, bounded scope/resources, applicability,
  remediation, positive/negative/boundary fixtures, and evidence identity binding.
  - [x] `QC.FORMAT.SWIFTFORMAT` is implemented in QualityControl commit `342d4358efa9309f8cf417d35152e70a183a107e`.
    It requires caller-pinned `swift-format` path/version and a tracked configuration, scans clean
    Git-HEAD Swift bytes through stdin, records tool/configuration digests, and never writes files.
    Positive/negative fixtures returned `PASS`/`FAIL` with exit codes `0`/`1`; app tests/builds remain
    unrun.
  - [x] SwiftFormat tracked configuration resolution is pinned to the authenticated repository
    root, independent of caller CWD; commit `ce8ec84355afd6d7f6d7b5b994c055c0ecb7b53f` is
    published on `main` and a cross-CWD positive smoke returned `PASS`.
  - [x] `QC.PRIVACY.MANIFEST` is implemented in QualityControl commit `cb81e49662d90c06c8618747bc7f8a760d79fae6`.
    It scans exact clean Git `HEAD` manifests, enforces the required `PrivacyInfo.xcprivacy` name,
    validates bounded plist structure, duplicate keys/categories, allowed Apple manifest keys,
    value types, and non-empty arrays, and returns `BLOCKED` for malformed or unsupported input.
    Positive, duplicate-key, and filename-boundary fixture smoke produced the expected `PASS` /
    `BLOCKED` results. It does not claim target membership, actual API/data use, SDK coverage,
    required-reason approval, runtime lifecycle, or App Store acceptance.
  - [x] Manual-only consumer workflows pin the corrected engine and run the privacy gate after
    resources: AIZenflow `4677bc8d42367ed4395a77b922e03d0b8d9954e0` and MVVMExample
    `0e2e4f5016b28aca311d8e683bc679f97d3799b0`, both published to their development/default and
    `main` branches. Workflow dispatch remains user-controlled; no GitHub run is claimed here.
- [ ] Keep architecture/literal/complexity checks as review candidates unless a narrow project
  contract proves a deterministic unsafe subset. Keep SwiftLint staged until an immutable tool
  version and fixtures demonstrate net value.
- [ ] Keep workflows manual-only, least-privilege, action-pinned, bounded, and free of paid AI.

### Agreed pre-resume improvements

- [x] Add one explicit, read-only repository-integrity receipt/check for an allowlisted repository
  set. It must validate the complete trusted target ref, local/remote branch parity, current
  tracked deletion diff, and clean/dirty state without treating ignored files as committed evidence.
  It must not guess repositories, schemes, or destinations and must not mutate anything. The
  read-only implementation is `scripts/check_repository_integrity.py`; its first five-repository
  receipt is `.zenflow/tasks/new-task-be0b/runtime/repository-integrity-receipt.json`. Local SHA,
  cleanliness, and deletion facts were captured; all remote parity queries were `BLOCKED` by the
  current DNS/network sandbox, so no remote PASS is claimed.
- [x] Add a short canonical policy note for retention/deletion safety: preserve branches and refs
  when they may contain unique history; delete only exact task-created disposable worktrees/clones
  or proven generated outputs; preserve potentially user-owned `xcuserdata` unless explicitly
  confirmed disposable. Keep this policy in Documentation Vault, not in app product code. Canonical
  policy commit `caa64d9` is pushed to `AIZenflowDocumentation/main`.
- [x] Add a deterministic regression guard for quality-gate contract drift: when a project contract
  is Swift 6, a gate must not require `SWIFT_VERSION = 5.0`; the guard must identify the affected
  profile/target/configuration and remediation. Use a positive and negative fixture; do not weaken
  the gate or add a broad filename heuristic. `scripts/check_swift6_gate_contract.py` uses an
  explicit closed contract plus AST-bound structural checks; its fixtures returned `PASS`/`FAIL`
  with exits `0`/`1` and reported target/configuration remediation.

### Phase I — review, flags, and release safety

- [x] Canonical PR template, feature-flag applicability, and release-applicability coverage are
  audited and require explicit residual-risk states.
- [ ] Apply the internal pre-PR contract to each new engine/consumer change: target freshness,
  merge-base, complete range review, adversarial failure-route review, exact committed HEAD, and
  remote parity after authorized push.

### Phase J — pilots, publication, and rollout

- [x] Pilot discovery, bounded inventory/dry-run, and consumer boundary preservation are recorded.
- [ ] Prove for each authorized pilot: dry-run safety, apply, idempotence, rollback, exact-SHA static
  evidence, one authorized runtime mode, deliberate failure, local/GitHub parity, and pre-PR receipt.
  Unrun app build/test/runtime/release evidence remains an explicit residual risk.
- [ ] Stop promotion for false `PASS`, destructive migration, permission bypass, unbounded process/
  artifact, or project-specific reusable default.
- [ ] Adopt current repositories in bounded clean batches; preserve and record dirty/conflicting
  repositories as deferred with owner/revisit trigger. Make future-repository admission and
  periodic read-only drift inventory mandatory without automatic project rewriting.

## Final closure

- [ ] Review exact final diffs and authority/consumer claims for Documentation, engine, canary, and
  authorized pilots; resolve P0–P2 and fix or report P3.
- [ ] Record compact receipts with trusted bases/HEADs, toolchains, permissions, checks, omitted or
  reused evidence, findings, residual risks, remote parity, and rollback path.
- [ ] Remove only explicitly task-created worktrees, clones, result bundles, caches, and scratch
  builds; preserve canonical commits, historical refs, user files, and user-owned `AGENTS.md`.
- [ ] Update this plan and `handoff.md` within the task-state budget with only evidence-backed
  completion claims, then synchronize the canonical task recovery copy.

## Next bounded block

Inspect `AIZenflowQualityControl` at the current trusted `origin/main` and select the next
still-staged deterministic adapter with a closed producer/consumer contract. SwiftLint remains
staged until an immutable executable/version and fixtures are available; build-warning and
concurrency adapters require an authorized authenticated build-report producer. Privacy-manifest
structure is implemented, but its runtime/data-use and bundle-membership limits remain explicit.
Before editing, write the compact change contract and keep the patch within the normal
three-source-file boundary. Run only relevant static/fixture evidence permitted for that block;
do not broaden into app runtime or tests unless the block explicitly reopens that permission.
