# ``AppPermissions``

Normalize permission state and permission request flows in a standalone, app-independent package.

## Overview

`AppPermissions` gives host apps a stable model for checking and requesting permissions without coupling that logic to a specific product, feature, screen, analytics system, or navigation flow.

Use `PermissionManaging` for app code, `ManualPermissionManager` for tests/previews, and `SystemPermissionManagerFactory` when native Apple permission providers are available.

## Topics

### Core Types

- ``PermissionKind``
- ``PermissionState``
- ``PermissionSnapshot``
- ``PermissionRequestOutcome``
- ``PermissionManaging``
- ``PermissionProviding``

### Managers

- ``ManualPermissionManager``
- ``StaticPermissionManager``
- ``CompositePermissionManager``

### Readiness

- ``PermissionReadinessEvaluator``
- ``PermissionReadinessDecision``
- ``PermissionRequestPolicy``

### Info.plist Support

- ``PermissionUsageDescriptions``
- ``PermissionUsageDescriptionRequirement``
