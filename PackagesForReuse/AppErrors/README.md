# AppErrors

## Summary

Generic app error contracts, mapping and user-facing/reporting boundaries.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Prevents raw errors from leaking into UI.
- Provides consistent support diagnostics and localized-message boundaries.
- Separates generic error mapping from feature-specific recovery.

## What It Does

- App error model.
- Error mapper/manager contracts.
- User message/reporting surfaces.

## When To Use It

- you need consistent error mapping across modules.
- UI should receive safe user-facing messages.

## When Not To Use It

- you need backend-specific parsing; use an adapter package or app layer.
- you want to log raw sensitive errors.

## Ownership Boundary

Package owns generic error mechanics; host apps own localized copy, support IDs, redaction, telemetry policy and feature recovery behavior.

## Products And Targets

- **Library products**: `AppErrorsCore`, `AppErrors`
- **SwiftPM targets**: `AppErrorsCore`, `AppErrors`
- **Repository path**: `./PackagesForReuse/AppErrors`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppErrors")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppErrorsCore"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppErrors`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppErrors.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppErrorsCore"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppErrors`.
2. Copy/sync it into `./PackagesInUse/AppErrors`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppErrorsCore

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
- `./USAGE.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
