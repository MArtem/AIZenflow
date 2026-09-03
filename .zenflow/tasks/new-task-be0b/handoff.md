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
- No new app builds, tests, Simulator, signing, or runtime checks are authorized in this continuation
  without a block-specific permission; existing migration evidence remains unchanged.

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

- Continue the saved Universal iOS/Xcode Quality-Control plan from the first still-staged
  deterministic engine adapter or orchestration defect. Inspect the current `origin/main` engine
  surface first, keep the next patch within three source files, and do not merge stale superseded
  branches or recreate replaced artifacts. The Swift 6 quality-gate contract-drift guard remains
  planned and must use an explicit project-contract fixture rather than a filename heuristic.

## Must not do

- Never inspect `/Users/Artem/.zenflow/secrets/` or edit user-owned `AGENTS.md`.
- Do not copy external-environment snapshots by default, mass-delete archives, or rewrite app-local
  policy as reusable policy.
- Do not weaken sandbox, permissions, strict concurrency, tests/build ownership, or semantic review.
