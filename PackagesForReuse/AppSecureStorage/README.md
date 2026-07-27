# AppSecureStorage

## Summary

Secure storage/keychain-style boundary for tokens and secret-like values.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids storing sensitive values in UserDefaults/files.
- Centralizes secure-store operations and failure handling.
- Makes secret storage testable.

## What It Does

- Secure value identifiers.
- Store/read/remove contracts.
- Keychain-friendly provider surfaces.

## When To Use It

- auth tokens, refresh tokens or secrets need durable secure storage.
- features need a package-level secure storage boundary.

## When Not To Use It

- data is non-sensitive cache/configuration.
- the app has no clear keychain/access-group policy.

## Ownership Boundary

Package owns secure storage mechanics; host apps own access groups, migration, logout wipe policy, biometric/access-control decisions and error UX.

## Products And Targets

- **Library products**: `AppSecureStorage`
- **SwiftPM targets**: `AppSecureStorage`
- **Repository path**: `./PackagesForReuse/AppSecureStorage`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppSecureStorage")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppSecureStorage"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppSecureStorage`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppSecureStorage.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppSecureStorage"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppSecureStorage`.
2. Copy/sync it into `./PackagesInUse/AppSecureStorage`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppSecureStorage

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
