# Source Of Truth Map

## Purpose
This map prevents agents from storing durable knowledge in the wrong place.

## Canonical Locations
Global documentation repository: `https://github.com/MArtem/AIZenflowDocumentation`

Local checkout: `/Users/Artem/.zenflow/worktrees/documentation-vault`

| Knowledge type | Source of truth |
|---|---|
| Automatic global-rule activation | Canonical: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md`; portable fallback: governed root `GLOBAL_RULES_PORTABLE_SNAPSHOT.md` with an explicit unavailable-canonical report |
| Reusable/global rule | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/` |
| Reusable deep iOS theory | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/knowledge-global/ios/` |
| Project-distribution mirror | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/`; never an independent authority |
| Reusable baseline copied into a worktree | governed exact copies plus declared overlays in the active worktree |
| App-specific decision | `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/` |
| App-specific local operational copy | current worktree app/task docs only when needed |
| Task plan | `./.zenflow/tasks/<TaskId>/plan.md` |
| Task handoff/resume state | `./.zenflow/tasks/<TaskId>/handoff.md` |
| Task archive/recovery | `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/` |
| Reusable package contract | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/package-vault-docs/<PackageName>/` |
| Active source-only package code | `./PackagesInUse/<PackageName>/` |
| Reusable package vault source | `./PackagesForReuse/<PackageName>/` |
| Architecture catalog | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/architecture-cases/` |
| Prompt presets | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/`; active `./docs/agent-prompts/` is a distribution mirror |
| Temporary note | current task docs only; promote deliberately or delete |

## Rule
If a fact applies to more than one app, it may be reusable only after app-neutral rewriting.

If a fact is a local exception, compromise, product decision, app route, bundle ID, feature behavior, task history, or recovery note, it is not reusable.

The complete layer and mirror contract is
`/Users/Artem/.zenflow/worktrees/documentation-vault/DOCUMENTATION_ARCHITECTURE.md`.
