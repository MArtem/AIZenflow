# Single-Folder Standalone Isolation Report

## Goal

Make every root package under `Packages/` copyable as a complete standalone Swift Package:

```text
PackageName/
  Package.swift
  README.md
  Sources/
  Tests/
```

No root package should require sibling packages from the current repository.

## Definition

A package is considered 100% single-folder standalone when:

1. `Package.swift` has no `.package(path: "../...")` sibling dependency.
2. `Sources/` and `Tests/` do not import modules owned by sibling root packages.
3. Package-owned tests live inside the same folder.
4. The README documents standalone copy mode.
5. Cross-package adapters are outside root packages and must be copied intentionally into host apps/integration targets.

## Summary of vNext4 changes

### AppAnalytics

Before:

- `AppAnalytics` depended on `AppNavigation`, `AppNetworking`, and `AppPushNotifications`.
- The package contained adapter products:
  - `AppNavigationAnalytics`
  - `AppNetworkingAnalytics`
  - `AppPushNotificationAnalytics`

After:

- `AppAnalytics` has no sibling dependencies.
- It now ships only:
  - `AppAnalytics`
  - `AppAnalytics`
- Cross-package adapters were moved to optional helper files:
  - `IntegrationHelpers/AppAnalyticsNavigationIntegration.swift`
  - `IntegrationHelpers/AppAnalyticsNetworkingIntegration.swift`
  - `IntegrationHelpers/AppAnalyticsPushNotificationsIntegration.swift`

Reason:

Analytics primitives are reusable mechanisms. Mapping navigation/networking/push events into analytics is app-level composition.

### AppErrors

Before:

- `AppErrors` depended on `AppNetworking`.
- The package contained `AppNetworkingErrorAdapter` and the umbrella product exported it.

After:

- `AppErrors` has no sibling dependencies.
- It now ships only:
  - `AppErrors`
  - `AppErrors`
- Networking mapping moved to:
  - `IntegrationHelpers/AppErrorsNetworkingIntegration.swift`

Reason:

Error semantics are reusable. Mapping concrete networking errors into app-facing semantics is integration-layer behavior.

### TchopProductLocalizationResources

Before:

- The product resources package depended on `AppLocalization` to create a `LocalizationManager`.

After:

- The package has no sibling dependencies.
- It exposes:
  - `bundle`
  - `localized(_:tableName:localeIdentifier:fallback:)`
- `AppLocalization` integration moved to:
  - `IntegrationHelpers/TchopProductLocalizationResourcesAppLocalizationIntegration.swift`

Reason:

Product resources should remain copyable as one folder. A generic localization manager is useful, but it should be composed by the host app.

### Retired compatibility bundle

The historical `TchopInfrastructure` compatibility bundle is no longer part of the active package baseline in this worktree. Use the standalone `App*` root packages and optional `IntegrationHelpers` instead.

## Integration helpers moved out of root packages

| Helper | Requires | Purpose |
|---|---|---|
| `AppAnalyticsNavigationIntegration.swift` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into analytics events. |
| `AppAnalyticsNetworkingIntegration.swift` | `AppAnalytics`, `AppNetworking` | Maps networking metrics into analytics events. |
| `AppAnalyticsPushNotificationsIntegration.swift` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics events. |
| `AppErrorsNetworkingIntegration.swift` | `AppErrors`, `AppNetworking` | Maps networking failures into app-facing errors. |
| `TchopProductLocalizationResourcesAppLocalizationIntegration.swift` | `TchopProductLocalizationResources`, `AppLocalization` | Builds an `AppLocalization.LocalizationManager` from product resources. |

## Verification added

New script:

```bash
./Packages/verify_single_folder_standalone.sh
```

It checks:

- required package files;
- missing `Tests/`;
- sibling `.package(path: "../...")` declarations;
- sibling module imports in `Sources/` and `Tests/`.

## Verification performed in this environment

The structural standalone gate passed:

```text
All root packages satisfy the single-folder standalone structural contract.
```

The following portable packages were also compiled/tested successfully in this Linux environment:

- `AppCache` — 11 tests
- `AppWidgetSupport` — 3 tests
- `AppConfiguration` — 13 tests
- `AppPushNotifications` — 6 tests
- `AppLocalization` — 6 tests
- `AppNetworking` — 27 tests
- `AppErrors` — 3 tests
- `AppAnalytics` — 3 tests
- `TchopProductLocalizationResources` — 2 tests
- `AppOnDeviceAI` — 2 tests

Strict concurrency was also spot-checked for the packages changed in this isolation pass:

- `AppErrors`
- `AppAnalytics`
- `TchopProductLocalizationResources`

## Apple-only verification still required on macOS/Xcode

Run:

```bash
./Packages/verify_apple_packages_macos.sh
./Packages/verify_strict_concurrency_macos.sh
```

Apple-only packages cannot be honestly compiled in this Linux environment.

## Result

The root packages now satisfy the intended single-folder standalone architecture. Cross-package convenience code exists only as optional integration helpers.

## Optional helper compile smoke test

A temporary host package was created in this environment to compile the portable integration helpers that do not require Apple-only frameworks:

- `AppAnalyticsNetworkingIntegration.swift`
- `AppAnalyticsPushNotificationsIntegration.swift`
- `AppErrorsNetworkingIntegration.swift`
- `TchopProductLocalizationResourcesAppLocalizationIntegration.swift`

Result: passed.

`AppAnalyticsNavigationIntegration.swift` still requires macOS/Xcode because `AppNavigation` is an Apple-platform package in this toolkit.
