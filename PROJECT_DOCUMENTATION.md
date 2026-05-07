# TchopApp Developer Onboarding Guide

## Purpose
This is the stable onboarding document for `TchopApp`.

Read this file for:
- app shape
- architecture boundaries
- runtime baselines
- top-level folder ownership

Do not use this file for:
- current task history
- implementation logs
- temporary debugging notes

For the full documentation map, use [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md).

## Quick Orientation
`TchopApp` is a SwiftUI iOS application with:
- coordinator-driven navigation
- app-level session and shell state
- local-first persistence
- reusable infrastructure in `Packages/TchopInfrastructure`
- widget, localization, branding, and push-notification support
- a feed/composer runtime currently being restored and extended

The primary separation is:
- `TchopApp` = product-specific composition, features, UI, app policies
- `Packages/TchopInfrastructure` = reusable managers and shared primitives

## Stable Runtime Baselines
- Current deployment target: `iOS 17`
- UI-facing state owners should prefer `Observation` (`@Observable`, `@Bindable`)
- Type-level `@MainActor` belongs on UI state owners, not on repositories/use cases/API clients by default
- Active app persistence path is `SwiftData`
- Legacy `Core Data` code is retained only as commented fallback, not as an active runtime path
- Reusable packages/managers are the root; app code adapts to them instead of wrapping them in decorative layers
- Use `.task` over `.onAppear` for async loading when lifecycle correctness matters
- Do not assume deallocation immediately after navigation pop
- Feature view models are created above views and injected downward
- Implement only explicitly requested behavior; do not add speculative UI or logic

## Dependency Map
```text
TchopApp.swift
  -> AppDIContainer
    -> AppState
      -> AppCoordinator
      -> AppShellViewModel
      -> LoginViewModel
      -> ProfileTabViewModel
      -> repositories/services/managers

AppShellViewModel
  -> NewsFeedViewModel
    -> AppContentRepository
      -> FeedAPIManager
      -> TchopDatabase
      -> SyncCore
```

Use [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md) for package boundaries and manager ownership.

## Top-Level Structure
### App
- `TchopApp/App`: app entry points, DI, app-global state, bridges, theme/localization
- `TchopApp/Models`: app-local models and feature contracts
- `TchopApp/Navigation`: coordinator, routes, deep links, navigation snapshot integration
- `TchopApp/Persistence`: app schema, bootstrap, seeding, persistence policy
- `TchopApp/Repositories`: feature-facing repository orchestration
- `TchopApp/Services`: app services and API-facing managers
- `TchopApp/ViewModels`: UI-facing state owners
- `TchopApp/Views`: SwiftUI screens and reusable view pieces

### Infrastructure Package
`Packages/TchopInfrastructure` contains reusable modules for:
- networking
- database
- sync
- navigation
- localization
- branding
- widgets
- push notifications
- analytics
- UI configuration
- Apple authentication

## Canonical Companion Documents
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md): documentation map and placement policy
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md): package inventory and ownership boundaries
- [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md): verification and testing workflow
- [APPLE_SIGN_IN_SETUP.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/APPLE_SIGN_IN_SETUP.md): Sign in with Apple setup
- [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md): current task resume state

## What To Update When Things Change
- Stable architecture or runtime policy:
  update this file
- Package or manager ownership:
  update [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- Verification workflow:
  update [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
- Current task state:
  update [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md)

## Archive Policy
Verbose historical versions are kept only for fallback reference:
- `docs/archive/`
- `.zenflow/tasks/new-task-be0b/archive/`

They are not part of the default read path.
