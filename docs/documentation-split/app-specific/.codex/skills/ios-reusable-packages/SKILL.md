---
name: ios-reusable-packages
description: Use this skill whenever the task touches source-app packages, managers, SyncCore, database/runtime ownership, package extraction, package integration, or app-vs-package responsibility decisions. Trigger even if the user only mentions managers, package cleanup, wrappers, adapters, sync, persistence, or reusable infrastructure.
---

# source-app Packages

Use this skill for `source-app` work involving:
- package boundaries
- manager ownership
- package-first cleanup
- SyncCore integration
- database runtime decisions

## Read Order
1. [references/package-rules.md](./references/package-rules.md)
2. `./docs/PACKAGES_AND_MANAGERS.md`
3. `./PROJECT_HEALTH.md`
4. `./PackagesInUse/README.md`
5. `./PackagesForReuse/README.md`

## Working Rules
- Start from the reusable package contract.
- Do not add app-local wrappers if the package already fits.
- Move generic behavior downward into the package when possible.
- Keep only project-specific policy and mapping in app code.
- Treat `AppSyncCore` / sync package mechanics as the root sync foundation when active in the current package mode.
- Treat `SwiftData` as the active persistence runtime unless explicitly told otherwise.

## Important Areas
- `./PackagesInUse` for active source-only package code compiled into app/share/widget targets
- `./PackagesForReuse` for validated reusable package vault code
- `./Packages` for SDK/package creation docs/templates only
- `./source-app/Repositories/AppContentRepository.swift`
- `./source-app/Persistence/AppDatabase.swift`
- `./source-app/Repositories/UserRepository.swift`

## Output Expectation
When changing this area:
- reduce redundant seams
- preserve real seams
- keep package/app ownership explicit
- avoid decorative abstractions
