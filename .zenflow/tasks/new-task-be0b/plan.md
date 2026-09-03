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

- [ ] Complete the remaining permission-aware mode orchestration without synthesizing composite
  `PASS`; keep `PASS`, `FAIL`, `BLOCKED`, `NOT_APPLICABLE`, `NOT_RUN_BY_USER_DECISION`, `SKIPPED`,
  and `BYPASSED` consistent across local and manual GitHub paths.
- [ ] Implement the next staged deterministic catalog adapter only after inspecting its current
  producer/consumer surface. Each adapter needs stable ID, bounded scope/resources, applicability,
  remediation, positive/negative/boundary fixtures, and evidence identity binding.
- [ ] Keep architecture/literal/complexity checks as review candidates unless a narrow project
  contract proves a deterministic unsafe subset. Keep SwiftLint/SwiftFormat staged until immutable
  tool versions and fixtures demonstrate net value.
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
- [ ] Add a deterministic regression guard for quality-gate contract drift: when a project contract
  is Swift 6, a gate must not require `SWIFT_VERSION = 5.0`; the guard must identify the affected
  profile/target/configuration and remediation. Use a positive and negative fixture; do not weaken
  the gate or add a broad filename heuristic.

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

Inspect `AIZenflowQualityControl` at its current trusted branch/remote state and select the first
still-staged deterministic adapter or orchestration defect. Before editing, write its compact change
contract and keep the implementation patch within the normal three-source-file boundary. Run only
the relevant static/fixture evidence permitted for that block; do not broaden into app runtime or
tests unless the block explicitly reopens that permission.
