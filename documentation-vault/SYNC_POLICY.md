# Documentation Vault Sync Policy

## Invariants
1. Every durable rule/prompt/skill/template/doc used by agents must exist in at least one git-backed location.
2. Current worktrees keep their operational copies. The vault keeps durable recovery and transfer copies.
3. Reusable docs must not depend on one app's product behavior unless generalized first.
4. App-specific docs stay under `apps/<AppName>/`. A worktree should not need another app's docs in its local task folder.
5. New app tasks may copy `reusable/` first, then create their own `apps/<NewApp>/` area.

## Required Update Flow
- Edit the active worktree doc/rule first.
- Mirror the durable copy into `./documentation-vault`.
- Update manifests when paths are added or removed.
- Run vault/documentation consistency checks before declaring completion.

## Non-Goals
- Do not move active worktree docs out of their current locations.
- Do not mix TchopApp-specific and MVVMExample-specific docs in one app folder.
- Do not use this vault for generated build outputs, DerivedData, SwiftPM caches, simulator traces, or raw logs.
