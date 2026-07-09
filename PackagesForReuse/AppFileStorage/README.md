# AppFileStorage

## Summary

Safe local file storage domains and file copy/write helpers.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids raw FileManager paths scattered through UI/features.
- Centralizes storage domains, replacement and cleanup behavior.
- Makes local file identity and sandbox location explicit.

## What It Does

- Storage domain and file reference models.
- Local copy/write/remove operations.
- App-group/local-container friendly path handling.

## When To Use It

- features import/copy user files, media or generated artifacts.
- file location durability matters.

## When Not To Use It

- you need secret/token storage; use secure storage.
- the file is a bundled read-only resource.

## Ownership Boundary

Package owns file mechanics; host apps own domains, retention, backup policy, privacy classification and UI-facing error copy.

## Products And Targets

- **Library products**: `AppFileStorage`
- **SwiftPM targets**: `AppFileStorage`
- **Repository path**: `./PackagesForReuse/AppFileStorage`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppFileStorage")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppFileStorage"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppFileStorage`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppFileStorage.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppFileStorage"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppFileStorage`.
2. Copy/sync it into `./PackagesInUse/AppFileStorage`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppFileStorage

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
