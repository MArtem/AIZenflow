# Services Engineering Rules

## Purpose
This file contains project-specific services, persistence, sync, and package overlay rules for this worktree.

Use it together with:
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

## Project-Specific Rules
- Reusable packages/managers are the foundation. App code adapts to package contracts.
- Package/app architecture decisions take priority over implementation speed. If a boundary is wrong, fix the boundary before adding more code on top of it.
- Avoid engineering for its own sake. If a simpler package/app shape solves the real problem without reducing quality, prefer the simpler shape.
- Do not add decorative protocols, shims, adapters, or facades when the package surface already fits the job.
- `SyncCore` is the root sync foundation. App code should keep only project-specific mapping, endpoint semantics, local schema application, and UI-facing policy.
- Package changes should move reusable behavior into the package instead of duplicating that behavior in the app layer.
- App repositories should coordinate app semantics, not reimplement generic package behavior.
- When introducing extensions, shared storage, sync bridges, or new managers, resolve ownership and runtime boundaries first. Do not let app code, package code, and extension code drift into an accidental structure that will be expensive to unwind later.
- Re-check reusable infrastructure for unnecessary complexity frequently, ideally by default. Simpler foundations are preferred unless extra structure is clearly justified by real reuse, platform constraints, or correctness needs.

## Documentation Rule
When asked to add a new services/package rule, first propose placement using:
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

Then write it to the canonical location instead of duplicating it.

## Archive
Verbose historical versions of this file are kept only in:
- [.zenflow/tasks/new-task-be0b/archive/services-engineering-rules.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/services-engineering-rules.legacy.md)
