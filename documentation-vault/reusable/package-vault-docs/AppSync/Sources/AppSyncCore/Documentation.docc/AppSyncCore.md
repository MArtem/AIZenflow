# ``AppSyncCore``

@Metadata {
    @DisplayName("AppSyncCore")
}

## Overview

Generic sync entity, mutation, scheduler, conflict, and transport contracts.

## Ownership

`AppSyncCore` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Feature-specific local/remote stores provide concrete persistence and DTO mapping.
- UI-observable status storage belongs to `AppSyncObservation`; `AppSyncCore` exposes only the framework-neutral
  `SyncStatusReporting` contract.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
