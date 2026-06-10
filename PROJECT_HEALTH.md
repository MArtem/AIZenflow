# Project Health

## Purpose
This document is the package and manager ownership map for `TchopApp`.

Read it when you need to answer:
- what is reusable
- what must stay app-specific
- where new behavior should live

## Root Rule
- If behavior is reusable and entity-agnostic, the package/manager should own it.
- App code should keep only project-specific mapping, domain rules, endpoint semantics, persistence schema choices, and UI composition.
- Do not add extra shim or protocol layers on top of a good reusable package unless there is a real seam requirement.

## Reusable Package Inventory
### `AppNetworking`
Owns:
- request execution
- upload/download
- retry/interceptor flow
- auth-refresh integration
- offline queue foundation
- diagnostics and metrics

Must not know about:
- app DTOs
- app localization keys
- app bundle semantics

### `AppDatabaseCore`
Owns:
- backend-neutral DB contracts
- migration primitives
- generic operation wrappers
- backend-selection types

Must not know about:
- app entities
- app migration policy

### `AppSwiftDataDatabase`
Owns:
- SwiftData-backed `DatabaseManaging` implementation

Must not know about:
- app schema
- app bootstrap policy

### `AppCoreDataDatabase`
Owns:
- Core Data-backed `DatabaseManaging` implementation

Must not know about:
- app model objects
- app migration policy

### `AppDatabaseComposition`
Owns:
- DB factory composition
- backend resolver/factory APIs

Must not know about:
- app upgrade policy
- app runtime rollback decisions

### `AppSyncCore`
Owns:
- sync state machine
- mutation queue orchestration
- push/pull cycle
- cursor handling
- sync status
- conflict contract

Must not know about:
- feed/channel/card app models
- app DTO naming
- app route or UI semantics

### `AppNavigation`
Owns:
- generic tab/router primitives
- navigation snapshot persistence contract

Must not know about:
- `AppTab`
- app route payloads
- app URL structure

### `AppLocalization`
Owns:
- localization facade
- locale override support

Must not know about:
- app copy itself

### `AppGlassUI`
Use for:
- SwiftUI Liquid Glass availability checks
- glass chrome fallback mechanics
- reusable shape-based glass styling helpers

App keeps:
- semantic color tokens
- product-specific visual roles
- screen layout and interaction decisions

### `AppBranding`
Owns:
- target-driven branding
- semantic tokens

Current note:
- keep extending semantic tokens instead of introducing one-off view-level colors

### `AppConfiguration`
Owns:
- configuration snapshot model
- refresh/store behavior

### `AppWidgetSupport`
Owns:
- widget snapshot primitives

Must not know about:
- app DI
- app navigation

### `AppPushNotifications`
Owns:
- APNs state
- token handling
- payload parsing
- persistent push state

### `AppSecureStorage`
Owns:
- product-neutral secure storage contracts
- Keychain-backed storage on Apple platforms
- actor-backed in-memory secure storage for tests/previews
- key validation, value-size limits, and sanitized secure-storage errors

Must not know about:
- app auth/session policy
- app-specific token key names
- token refresh/logout behavior
- product localization or analytics routing

### `AppAnalytics`
Owns:
- reusable analytics/event primitives

### `AppAppleAuthentication`
Owns:
- Apple auth integration primitives

## What Must Stay In `TchopApp`
- app DTO to domain mapping policy
- app persistence schema and records
- feature-specific repository composition
- feed and composer domain contracts
- app routing and deep-link semantics
- target-specific UI composition
- app-specific user/session flows

## Current Runtime Notes
- App runtime is `SwiftData`-first
- Legacy `Core Data` path exists only as fallback material, not active architecture direction
- `AppSyncCore` is now part of the active sync foundation and should absorb reusable sync behavior instead of duplicating sync logic in app repositories

## Placement Rule
If a new package or manager rule changes ownership boundaries, update this file.
If it changes only the current task behavior, update task docs instead.

For hands-on integration guidance and reuse notes, use:
- [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
