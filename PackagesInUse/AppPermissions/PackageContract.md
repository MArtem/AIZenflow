# AppPermissions Package Contract

## Purpose

`AppPermissions` owns app-independent permission state and request abstractions.

## Standalone guarantee

This package must remain a 100% single-folder standalone Swift package.

It must not contain:

- sibling `.package(path: "../...")` dependencies;
- imports of sibling SDK packages;
- app-specific permission copy;
- product-specific feature names;
- analytics/logging/navigation side effects;
- raw platform error strings in telemetry-like models;
- unsafe Swift compiler flags.

## Public API ownership

The package owns:

- `PermissionKind`;
- `PermissionState`;
- `PermissionSnapshot`;
- `PermissionRequestOutcome`;
- `PermissionManaging`;
- `PermissionProviding`;
- `ManualPermissionManager`;
- `StaticPermissionManager`;
- `CompositePermissionManager`;
- `PermissionUsageDescriptions`;
- `PermissionReadinessEvaluator`;
- compile-gated Apple system providers.

## Integration rules

Any integration with other packages must live outside this root package, for example:

- `AppPermissionsAnalyticsIntegration`;
- `AppPermissionsLoggingIntegration`;
- `AppPermissionsDiagnosticsIntegration`;
- `AppPermissionsNavigationIntegration`.

## Privacy rules

Permission diagnostics may include stable state codes such as `authorized`, `denied`, or `notDetermined`.
They must not include user-facing copy, raw platform error text, personal data, URLs, tokens, or app-specific context.

## Platform rules

Apple framework integrations must be compile-gated with `canImport` and must not break Linux/package-server verification.


## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppPermissions/Documentation.docc/`.
- Verification uses a SwiftPM scratch path inside `/Users/Artem/.zenflow/worktrees/` and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.

## App-owned lifecycle integration

Notification providers accept an injected `UNUserNotificationCenter` so host apps keep delegate/lifecycle ownership while this package owns only permission state/request normalization.
