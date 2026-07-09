# AppErrorsNetworkingIntegration

## Summary

Integration helper mapping AppNetworking failures into AppErrors surfaces.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

> This is an integration helper, not a root domain package. Use it only when both connected packages are intentionally present.

## What Problem It Solves

- Keeps error core independent from networking core.
- Provides optional reusable network-error translation.

## What It Does

- Networking error to app error adapter.
- Status/failure category mapping.

## When To Use It

- an app uses AppNetworking and AppErrors and wants consistent error mapping.

## When Not To Use It

- backend-specific error parsing belongs in the app.
- you need to expose raw response bodies.

## Ownership Boundary

Helper owns generic network-error mapping; host apps own backend-specific messages, support copy and redaction.

## Products And Targets

- **Library products**: `AppErrorsNetworkingIntegration`
- **SwiftPM targets**: `AppErrorsNetworkingIntegration`
- **Repository path**: `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppErrorsNetworkingIntegration"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppErrorsNetworkingIntegration.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppErrorsNetworkingIntegration"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/IntegrationHelpers/AppErrorsNetworkingIntegration`.
2. Copy/sync it into `./PackagesInUse/IntegrationHelpers/AppErrorsNetworkingIntegration`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/IntegrationHelpers/AppErrorsNetworkingIntegration` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppErrorsNetworkingIntegration

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
- `./REUSE.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
