# AppAnalyticsPushNotificationsIntegration

## Summary

Integration helper connecting AppPushNotifications events to AppAnalytics reporting.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

> This is an integration helper, not a root domain package. Use it only when both connected packages are intentionally present.

## What Problem It Solves

- Keeps push notification core independent from analytics.
- Makes optional push telemetry reusable.

## What It Does

- Push-event-to-analytics adapter.
- Registration/failure event mapping.

## When To Use It

- an app uses push notifications and analytics together.

## When Not To Use It

- notification payloads contain sensitive data and no redaction policy exists.
- you do not report push events.

## Ownership Boundary

Helper owns generic event mapping; host apps own payload redaction, event naming and reporting policy.

## Products And Targets

- **Library products**: `AppAnalyticsPushNotificationsIntegration`
- **SwiftPM targets**: `AppAnalyticsPushNotificationsIntegration`
- **Repository path**: `./PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppAnalyticsPushNotificationsIntegration"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppAnalyticsPushNotificationsIntegration.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppAnalyticsPushNotificationsIntegration"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`.
2. Copy/sync it into `./PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppAnalyticsPushNotificationsIntegration

// Use the package APIs from the target that owns product-specific policy.
```

## Verification

From this package folder, run:

```zsh
./Scripts/verify_package.sh
```

For source-only app integration, also run the host app's required verification, usually:

```zsh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
./scripts/verify.sh low
git diff --check
```

## More Documentation

- `./PackageContract.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
