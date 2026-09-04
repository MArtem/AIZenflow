# Documentation Audit Handoff

## Identifiers

- Worktree/task: `/Users/Artem/.zenflow/worktrees/new-task-be0b`, `new-task-be0b`
- Canonical vault: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Current mode/model: **эконом / GPT-5.6 luna**; switch not required.
- Scope: Universal iOS/Xcode Quality-Control implementation after the completed documentation
  integrity audit; app product source remains out of scope unless a bounded quality-control
  consumer change requires it.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Current state

- Canonical vault was synchronized from the reviewed active documentation audit. Sync commit
  `2be69b6c946dd0562138da62c6efe36d71eec738` was pushed to `origin/main` and its remote SHA matched.
- Receipt finalization commit `e8dd3219010c50970c030c04f82736033c9df9dd` was pushed as well.
- Active worktree baseline mirrors are synchronized: 175 exact mirrors, zero drift.
- Existing validators pass: manifest/index/router/consistency/boundary/bootstrap/remote-state.
- Context-cost report previously exposed oversized dynamic task state; active `plan.md` and
  `handoff.md` are now compact and keep the detailed history in Git/archive.
- MVVMExample static verification exposed and repaired a stale Swift 5 build-contract expectation
  and a missing required task-type router. The gate now passes with Swift 6/complete strict
  concurrency, zero blocking/advisory findings; commit `bc7c65dd4994ca5ea0d63d176e7dfdff277887d8`
  is published to both `Development` and `main` with exact remote-SHA parity.
- AIZenflow documentation/task-state receipt is published to both `development` and `main`; final
  local/remote SHA parity was verified after the last receipt correction.
- The compact Universal execution plan now records the remaining engine/adoption phases and three
  approved pre-resume improvements: read-only repository-integrity receipt, retention/deletion
  safety policy, and a Swift 6 quality-gate contract-drift regression guard.
- The read-only repository-integrity checker is implemented at `scripts/check_repository_integrity.py`.
  Its first allowlisted receipt records local SHA/cleanliness/deletion facts for AIZenflow,
  MVVMExample, Documentation Vault, QualityControl, and QualityControlCanary. Remote parity is
  intentionally `BLOCKED` in the current DNS/network sandbox; no remote success is claimed.
- Canonical retention/deletion policy is synchronized and pushed in Documentation Vault commit
  `caa64d9`; it preserves unique refs and potentially user-owned `xcuserdata`, and permits deletion
  only for exact task-created disposable paths or proven generated outputs.
- The post-resume QualityControl adapters are complete through `QC.TESTS.DISABLED`, including
  `QC.RESOURCES.ASSETS`, the structural `QC.PRIVACY.MANIFEST` boundary, and the exact-baseline
  `QC.CONFIGURATION.SIGNING`
  change detector. The formatter hardening remains at `ce8ec843`; the
  expectation-validation fixture correction is `4cb9cd6` and the privacy adapter correction is
  `cb81e49`; the subsequent catalog-contract correction is `0d3045921727720b357590f94488a57ce687c363`
  (`origin/main` exact SHA). Privacy checks read exact
  clean Git `HEAD`, validate `PrivacyInfo.xcprivacy` plist shape, keys, types, duplicates, and
  bounds, and emit `BLOCKED` for malformed/unsupported input. Positive, duplicate-key, and
  filename-boundary fixture smoke returned the expected `PASS` / `BLOCKED` results. Configuration/
  signing compares a clean `HEAD` with a caller-supplied trusted ancestor and exact tracked path
  policy; positive, changed-path, and traversal fixture smoke returned `PASS` / `FAIL` / `BLOCKED`.
  It does not claim signing, provisioning, entitlements, target membership, or App Store correctness.
  `QC.TESTS.DISABLED` is published at `839b600c8401deca8fb72d73c72429603e7df65a` on
  `origin/main`; its explicit-scope fixture smoke returned `PASS`/`FAIL`, Python contract tests
  returned `45/45`, and the Swift package suite returned `164/164`. The adapter does not infer
  target membership or conditional skips. SwiftLint, build warnings, and concurrency diagnostics
  remain staged; app project tests/builds were not run. QualityControl `origin/main` is now exact
  at `839b600c`.
- AIZenflow static gate verification on `460c27ce` passed docs index/consistency, iOS framework,
  secrets, large-file, and diff checks, but remains `FAIL` on 22 pre-existing shipped-source
  blockers (three synchronous PDF/media loads and nineteen `Data(contentsOf:)` reads in Tchop and
  reusable packages). They are recorded as production remediation residuals; no suppression or
  false PASS was introduced.
- Consumer workflow wiring is published and now pins the corrected catalog revision `0d304592`:
  AIZenflow `7b2d3e40` in development/main and MVVMExample `100b883` in Development/main. Both
  add a manual-only privacy-manifest step after the resource gate and assert the exact check
  ID/status. No GitHub dispatch or app runtime result is claimed; dispatch remains user-controlled.
- The next orchestration block is also published on QualityControl `origin/main`: commit
  `0429c48b871c19457433155e814909451dd25e9a` preserves deferred-vs-not-applicable semantics and
  blocks prohibited actions during mode planning; commit
  `f1548d6621c89ae57f281b0b7013156ec17ffd39` aligns `mode-plan` status precedence with
  `mode-execute`. Both commits are source-only and have parse/diff/schema static evidence.
- Capability coverage is now explicit for `build-and-tests`/`full`: snapshot tests, observability,
  and platform capabilities are represented as bounded non-success/N/A steps until their dedicated
  boundaries exist. QualityControl commit `1d224ad66673bd9cd6e65587f0139a6139b18e53` is published
  on `origin/main`; no unsupported evidence is synthesized.
- `mode-execute` now preserves the caller-selected mode in invalid-argument and bounded-output
  failure envelopes instead of emitting a misleading static-mode result. QualityControl commit
  `b529226c5313f96be1f1aaecfc3a65e3429f9b42` is published on `origin/main`; Swift parse,
  assertions, and diff-check passed.
- SwiftFormat adapter hardening is published in QualityControl commit
  `ce8ec84355afd6d7f6d7b5b994c055c0ecb7b53f`: the tracked configuration is resolved from the
  authenticated repository root rather than caller CWD. Python compile, cross-CWD positive fixture
  smoke, and diff-check passed; prior negative smoke evidence is reused unchanged.
- Permission-aware mode orchestration is complete for the currently implemented boundaries:
  status vocabulary and precedence are aligned, deferred/N/A/prohibited capability states are
  truthful, all eight profile capabilities are represented, and unsupported dedicated boundaries
  never synthesize PASS. The next work is staged-adapter implementation, not app migration.
- The Swift 6 gate-contract drift guard is complete at `scripts/check_swift6_gate_contract.py`.
  It requires an explicit closed project contract, detects only AST-bound `SWIFT_VERSION = 5.0`
  pairs/maps/comparisons, and reports project/target/configuration/remediation. Positive/negative
  fixture smoke returned `PASS`/`FAIL` with exits `0`/`1`; no app tests/builds were run.
- No new app builds, tests, Simulator, signing, or runtime checks are authorized in this continuation
  without a block-specific permission; existing migration evidence remains unchanged.
- The user-owned `AGENTS.md` from `mvvmexample-static-quality-gate` was copied byte-for-byte to
  `.zenflow/tasks/new-task-be0b/runtime/preserved-user-files/MVVMExample-static-quality-gate-AGENTS.md`
  (SHA-256 `43413a0f...8f013bce`). The original worktree and file remain untouched until the user
  decides its cleanup.
- The explicitly authorized concurrency-test migration is complete. AIZenflow commit `f4054aac`
  and MVVMExample commit `739a7ea` replace test-only unchecked references with checked
  queue-owned state (`DispatchQueue` + `DispatchSpecificKey`) where the minimum deployment target
  is macOS 12, use the existing checked `OSAllocatedUnfairLock` where the iOS 17 target permits it,
  and remove invalid `FileManager` sendability claims. Full tracked-Swift scans in both repositories
  now find no `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency`; parser and
  diff-check evidence passed. Project tests/builds remain intentionally unrun.
- After that migration, AIZenflow `development` and `main` both point to `f4054aac`, and
  MVVMExample `Development` and `main` both point to `739a7ea`; these are the current remote tips
  and include the workflow/task-state history above.
- Branch audit after explicit consolidation authorization found no code unique to the stale
  AIZenflow/MVVMExample migration/gate refs: AIFieldbook gate, Tchop share import/localization,
  actor/concurrency changes, and MVVM Swift 6 changes are already present in current development
  and main trees. Remaining branch-only differences are older task-state/documentation removals or
  weakened metadata and were not merged or deleted. QualityControl's explicitly requested
  expectation-validation experiment contributed only its missing fixture/cleanup correction as
  `4cb9cd6`; its already-present core validation was not duplicated.
- After the user deleted the six stale app branches, a read-only recovery audit found no files
  present only in their retained tip commits; no code restoration was required. The six worktrees
  were detached before deletion, and three dirty user-owned `AGENTS.md` files were preserved
  byte-for-byte. AIZenflow still has two remote-tracking codex refs until the user removes them;
  GitHub remote freshness is currently blocked by DNS, so no remote deletion or parity claim is made.
- The parity SHAs in the preceding historical checkpoint predate the privacy-adapter correction,
  consumer workflow wiring, and subsequent task-state receipts; they are retained as historical
  evidence and must not be read as the current branch tips. The current state was re-queried during
  this continuation: AIZenflow `development` and `main` both point to the privacy workflow/task-state
  publication, MVVMExample `Development` and `main` point to the same privacy workflow publication,
  QualityControl `origin/main` points to the corrected privacy adapter, and Documentation Vault
  `origin/main` contains the synchronized task-state copy. The QC source worktree remains dirty only
  in the user-owned `AGENTS.md`; no task-created linked checkout or generated build artifact remains.
  - Cleanup after publication removed the task-local QualityControl contract checkout and two clean,
  superseded MVVMExample linked checkouts; their branch refs and commit history remain preserved.
  Dirty checkouts containing user-owned `AGENTS.md`, and all linked worktrees owned by the separate
  `AIZenflowRelease` repository, were intentionally left untouched.

## Completed canonical repair

1. Restored canonical `reusable/agent-prompts/FIGMA_TASK_ROUTER.md`, aligned Figma prompt routing,
   and regenerated both manifests.
2. Made external skill snapshots recovery-only and explicit-transfer gated.
3. Promoted newer portable snapshot, code-documentation skill, SDK documentation, strict
   concurrency guidance, and corrected baseline package links.
4. Removed stale AIFieldbook model/mode pinning and undefined M16 claims.
5. Preserved Tchop task rules as tracked canonical historical recovery material; active saved-prompt
   and source-app links now identify them as non-authoritative.

## Next safe steps

- Continue the saved Universal iOS/Xcode Quality-Control plan from the next still-staged
  deterministic adapter with a closed contract. Inspect current `origin/main` first, keep the next
  patch within three source files, and do not merge stale superseded branches. SwiftLint is deferred
  until a caller-pinned immutable tool/version is available; build-warning and concurrency adapters
  need an authorized authenticated build-report producer. The exact disposable linked checkouts
  used for the three orchestration commits were removed after publication.

## Must not do

- Never inspect `/Users/Artem/.zenflow/secrets/` or edit user-owned `AGENTS.md`.
- Do not copy external-environment snapshots by default, mass-delete archives, or rewrite app-local
  policy as reusable policy.
- Do not weaken sandbox, permissions, strict concurrency, tests/build ownership, or semantic review.
