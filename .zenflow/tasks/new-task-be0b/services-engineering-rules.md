# Services Engineering Rules

## Purpose
This file contains project-specific services, persistence, sync, and package overlay rules for this worktree.

Use it together with:
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

## Project-Specific Rules
- Reusable packages/managers are the foundation. App code adapts to package contracts.
- Do not add decorative protocols, shims, adapters, or facades when the package surface already fits the job.
- `SyncCore` is the root sync foundation. App code should keep only project-specific mapping, endpoint semantics, local schema application, and UI-facing policy.
- `SwiftData` is the active app persistence runtime.
- Legacy `Core Data` material is fallback/rollback only and should not drive new runtime design.
- Package changes should move reusable behavior into the package instead of duplicating that behavior in the app layer.
- App repositories should coordinate app semantics, not reimplement generic package behavior.

## Documentation Rule
When asked to add a new services/package rule, first propose placement using:
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

Then write it to the canonical location instead of duplicating it.

## Archive
Verbose historical versions of this file are kept only in:
- [.zenflow/tasks/new-task-be0b/archive/services-engineering-rules.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/services-engineering-rules.legacy.md)
