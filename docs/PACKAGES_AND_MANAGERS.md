# Packages And Managers Guide

## Purpose
This document explains the reusable package and manager layer in `TchopApp`.

Use it for:
- package integration work
- package-vs-app ownership decisions
- reuse guidance for other projects

Do not use it for:
- current task history
- global assistant behavior
- temporary debugging notes

## Core Rule
- Reusable packages and managers are the foundation.
- If behavior is generic, repeatable, and entity-agnostic, it should live in the package.
- App code should keep only project-specific mapping, endpoint semantics, persistence schema application, routing, and UI composition.
- Do not add decorative adapters or protocols when the package surface already fits the need.

## Package Inventory
### `TchopNetworking`
Use for:
- request execution
- uploads/downloads
- retry/interceptor flow
- auth-refresh integration
- reusable network diagnostics

App keeps:
- DTOs
- endpoint semantics
- mapping to app models

### `TchopDatabaseCore`
Use for:
- backend-neutral database contracts
- migration primitives
- shared database operation wrappers

App keeps:
- app schema
- app record types
- app bootstrap policy

### `TchopSwiftDataDatabase`
Use for:
- active SwiftData-backed database manager

App keeps:
- schema registration
- app seeding/bootstrap
- persistence policy

### `TchopCoreDataDatabase`
Use for:
- legacy rollback-only Core Data manager

Current rule:
- do not design new app runtime behavior around it
- keep it only as fallback material when explicitly needed

### `TchopDatabaseComposition`
Use for:
- resolver/factory composition
- backend wiring primitives

App keeps:
- current runtime choice and rollout policy

### `SyncCore`
Use for:
- sync state machine
- push/pull orchestration
- mutation queue
- cursor handling
- sync status
- conflict contract

App keeps:
- app payload mapping
- local schema application
- endpoint semantics
- feature-specific merge policy

### `TchopNavigation`
Use for:
- reusable router/tab primitives
- navigation snapshot persistence contract

App keeps:
- `AppTab`
- route payloads
- deep-link semantics

### `TchopLocalization`
Use for:
- localization facade
- locale override support

App keeps:
- actual product copy

### `TchopBranding`
Use for:
- semantic brand tokens
- target-driven branding behavior

Working rule:
- extend semantic tokens instead of inventing one-off view colors

### `TchopUIConfiguration`
Use for:
- UI configuration snapshot model
- refresh/store behavior

### `TchopWidgets`
Use for:
- widget snapshot primitives

App keeps:
- widget composition fed by app-specific data

### `TchopPushNotifications`
Use for:
- APNs token handling
- payload parsing
- persisted push state

App keeps:
- app-specific routing after payload interpretation

### `TchopAnalytics`
Use for:
- reusable analytics/event primitives

App keeps:
- app event naming policy
- app feature instrumentation decisions

### `TchopAppleAuthentication`
Use for:
- reusable Apple auth integration primitives

App keeps:
- app session flow
- feature wiring

## Integration Rules
When using a package or manager in app code:

1. Prefer the package's existing surface first.
2. If the package is missing reusable behavior, extend the package.
3. Add app-layer logic only when the behavior is truly project-specific.
4. Avoid app-local shim types unless there is a real seam such as testing, lifecycle bridging, or target composition.

## Reuse In Other Projects
When reusing these packages elsewhere:
- start from the package contract, not from `TchopApp` wrappers
- reimplement only the project-specific mapping and policies
- do not cargo-cult `TchopApp` repository shapes if the new project does not need them

## Related Sources
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- [.codex/skills/tchop-packages/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-packages/SKILL.md)
