# Documentation Audit Handoff

## Identifiers

- Worktree/task: `/Users/Artem/.zenflow/worktrees/new-task-be0b`, `new-task-be0b`
- Canonical vault: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Current mode/model: **эконом / GPT-5.6 luna**; switch not required.
- Scope: documentation integrity and context economy only; no app source or tests.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Current state

- Canonical vault was synchronized from the reviewed active documentation audit. Sync commit
  `2be69b6c946dd0562138da62c6efe36d71eec738` was pushed to `origin/main` and its remote SHA matched.
- Receipt finalization commit `e8dd3219010c50970c030c04f82736033c9df9dd` was pushed as well.
- Active worktree baseline mirrors are synchronized: 175 exact mirrors, zero drift.
- Existing validators pass: manifest/index/router/consistency/boundary/bootstrap/remote-state.
- Context-cost report previously exposed oversized dynamic task state; active `plan.md` and
  `handoff.md` are now compact and keep the detailed history in Git/archive.
- No builds, tests, Simulator, signing, or runtime checks were run or changed.

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

- Resume the saved Universal iOS/Xcode Quality-Control plan. Do not commit/push the AIZenflow
  project worktree in this documentation-only block.

## Must not do

- Never inspect `/Users/Artem/.zenflow/secrets/` or edit user-owned `AGENTS.md`.
- Do not copy external-environment snapshots by default, mass-delete archives, or rewrite app-local
  policy as reusable policy.
- Do not weaken sandbox, permissions, strict concurrency, tests/build ownership, or semantic review.
