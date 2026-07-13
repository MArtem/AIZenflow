# Source Of Truth Map

## Purpose
This map prevents agents from storing durable knowledge in the wrong place.

## Canonical Locations
| Knowledge type | Source of truth |
|---|---|
| Reusable/global rule | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/` |
| Reusable baseline copied into a worktree | `./docs/` plus root project docs |
| App-specific decision | `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/` |
| App-specific local operational copy | current worktree app/task docs only when needed |
| Task plan | `./.zenflow/tasks/<TaskId>/plan.md` |
| Task handoff/resume state | `./.zenflow/tasks/<TaskId>/handoff.md` |
| Task archive/recovery | `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/` |
| Reusable package contract | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/package-vault-docs/<PackageName>/` |
| Active source-only package code | `./PackagesInUse/<PackageName>/` |
| Reusable package vault source | `./PackagesForReuse/<PackageName>/` |
| Architecture catalog | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/architecture-cases/` |
| Prompt presets | `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/` and active `./docs/agent-prompts/` |
| Temporary note | current task docs only; promote deliberately or delete |

## Rule
If a fact applies to more than one app, it may be reusable only after app-neutral rewriting.

If a fact is a local exception, compromise, product decision, app route, bundle ID, feature behavior, task history, or recovery note, it is not reusable.
