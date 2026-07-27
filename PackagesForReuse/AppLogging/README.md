# AppLogging

## Summary

Structured logging primitives and safe log-level/category contracts.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids raw print/debug logging in packages.
- Keeps log categories and privacy decisions explicit.
- Provides a reusable no-op/logger boundary.

## What It Does

- Logger contracts.
- Log level/category models.
- No-op and structured log helpers.

## When To Use It

- packages/features need logging without binding to one backend.
- you need testable logging side effects.

## When Not To Use It

- you might log secrets, tokens or raw user content.
- one local debug-only print is sufficient and non-production.

## Ownership Boundary

Package owns logging mechanics; host apps own sinks, privacy redaction, log retention and operational policy.

## Products And Targets

- **Library products**: `AppLogging`
- **SwiftPM targets**: `AppLogging`
- **Repository path**: `./PackagesForReuse/AppLogging`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppLogging")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLogging"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppLogging`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppLogging.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppLogging"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppLogging`.
2. Copy/sync it into `./PackagesInUse/AppLogging`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppLogging

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
- `./Docs/README.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
