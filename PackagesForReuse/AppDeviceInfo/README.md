# AppDeviceInfo

## Summary

Device, OS and runtime information provider utilities.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Centralizes device metadata access.
- Makes diagnostics and compatibility checks testable.
- Avoids scattering UIDevice/ProcessInfo reads.

## What It Does

- Device info snapshot/provider contracts.
- Platform/version metadata helpers.
- Testable provider surfaces.

## When To Use It

- you need device metadata in diagnostics, feature gates or support payloads.
- multiple modules need consistent device info.

## When Not To Use It

- you are collecting privacy-sensitive identifiers without policy.
- one direct local check is enough.

## Ownership Boundary

Package owns generic device info mechanics; host apps own privacy policy, telemetry fields and compatibility decisions.

## Products And Targets

- **Library products**: `AppDeviceInfo`
- **SwiftPM targets**: `AppDeviceInfo`
- **Repository path**: `./PackagesForReuse/AppDeviceInfo`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppDeviceInfo")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDeviceInfo"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppDeviceInfo`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppDeviceInfo.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDeviceInfo"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppDeviceInfo`.
2. Copy/sync it into `./PackagesInUse/AppDeviceInfo`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppDeviceInfo

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
- `./Docs/README.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
