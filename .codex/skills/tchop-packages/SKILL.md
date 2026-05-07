---
name: tchop-packages
description: Use this skill whenever the task touches TchopApp packages, managers, SyncCore, database/runtime ownership, package extraction, package integration, or app-vs-package responsibility decisions. Trigger even if the user only mentions managers, package cleanup, wrappers, adapters, sync, persistence, or reusable infrastructure.
---

# Tchop Packages

Use this skill for `TchopApp` work involving:
- package boundaries
- manager ownership
- package-first cleanup
- SyncCore integration
- database runtime decisions

## Read Order
1. [references/package-rules.md](./references/package-rules.md)
2. [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
3. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)

## Working Rules
- Start from the reusable package contract.
- Do not add app-local wrappers if the package already fits.
- Move generic behavior downward into the package when possible.
- Keep only project-specific policy and mapping in app code.
- Treat `SyncCore` as the root sync foundation.
- Treat `SwiftData` as the active persistence runtime unless explicitly told otherwise.

## Important Areas
- [Packages/TchopInfrastructure](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [AppDatabase.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Persistence/AppDatabase.swift)
- [UserRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/UserRepository.swift)

## Output Expectation
When changing this area:
- reduce redundant seams
- preserve real seams
- keep package/app ownership explicit
- avoid decorative abstractions
