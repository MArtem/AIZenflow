# AppCache

## Summary

Generic cache storage, expiration and cleanup mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids ad-hoc cache files and inconsistent TTL cleanup.
- Makes cache limits and corruption handling explicit.
- Provides reusable cache primitives for data/image/network features.

## What It Does

- Key/value cache storage contracts.
- Expiration/removal helpers.
- Corrupt-entry cleanup behavior.

## When To Use It

- you need reusable local caching with explicit expiration semantics.
- cached data can be recomputed or re-fetched.

## When Not To Use It

- data is authoritative user data; use persistence instead.
- you need encrypted secret storage; use secure storage.

## Ownership Boundary

Package owns cache mechanics; host apps own data classification, retention policy, privacy requirements and cache domains.

## Products And Targets

- **Library products**: `AppCache`
- **SwiftPM targets**: `AppCache`
- **Repository path**: `./PackagesForReuse/AppCache`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppCache")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppCache"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppCache`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppCache.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppCache"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppCache`.
2. Copy/sync it into `./PackagesInUse/AppCache`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppCache

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
