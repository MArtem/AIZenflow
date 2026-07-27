# Integration Helpers

## Summary

`./PackagesInUse/IntegrationHelpers` contains source-only helper packages that compose two active reusable packages without making either root package depend on the other.

## What Problem It Solves

- Keeps root packages independent and reusable.
- Keeps optional cross-package mapping out of app feature code.
- Makes analytics/networking/navigation/push integrations explicit and removable.

## What It Does

- Hosts active integration helpers compiled into `TchopApp` targets.
- Documents which root packages each helper requires.
- Provides a clear place for source-only helper wiring and copy-file support.

## When To Use It

- two root packages are already intentionally adopted;
- the mapping is generic and reusable across apps;
- keeping the mapping in either root package would create the wrong dependency direction.

## When Not To Use It

- the logic is product policy, feature routing, UI copy, DTO mapping or privacy policy;
- only one app feature needs a direct call;
- the helper would become an empty pass-through wrapper.

## Ownership Boundary

Integration helpers own cross-package mapping only. Host apps still own feature policy, privacy/redaction, enablement, telemetry decisions and user-facing behavior.

## Active Helpers

| Helper | Requires | Purpose |
| --- | --- | --- |
| `./AppAnalyticsNavigationIntegration` | `AppAnalytics`, `AppNavigation` | Maps navigation diagnostics into analytics events. |
| `./AppAnalyticsNetworkingIntegration` | `AppAnalytics`, `AppNetworking` | Maps networking metrics/failures into sanitized analytics events. |
| `./AppAnalyticsPushNotificationsIntegration` | `AppAnalytics`, `AppPushNotifications` | Maps push notification lifecycle events into analytics without titles/tokens. |
| `./CopyFiles` | source-only resource integration | Stores copy-file helper material for source-only package integration. |

## Local SwiftPM Usage

Each helper with a `Package.swift` can be consumed locally as a SwiftPM package:

```swift
.package(path: "../PackagesInUse/IntegrationHelpers/AppAnalyticsNavigationIntegration")
```

In current `TchopApp`, helpers are compiled source-only through the Xcode project instead of SwiftPM.

## Remote SwiftPM Usage

SwiftPM Git URL mode requires the helper folder to be published as the root of its own repository:

```swift
.package(url: "https://github.com/<org>/AppAnalyticsNavigationIntegration.git", from: "0.1.0")
```

Do not point SwiftPM at a nested helper folder inside a documentation/app repository.

## Verification

For active source-only helper changes, run:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
./scripts/verify.sh low
git diff --check
```

When a helper is verified as standalone SwiftPM, also run its package-local `./Scripts/verify_package.sh`.

## Documentation Maintenance

When adding or removing an active helper, update:

- this file;
- `./PackagesInUse/PACKAGE_CATALOG.md`;
- `./PackagesInUse/README.md`;
- `./PackagesForReuse/PACKAGE_CATALOG.md` if the helper is part of the reusable vault;
- the matching central documentation-vault mirror when shared docs are changed.
