# AppDownloads

## Summary

Secure generic download service with URL, size, cancellation and destination-file policies.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids unsafe ad-hoc file downloads.
- Centralizes HTTPS/default limits/replacement behavior.
- Keeps cancellation and cleanup semantics explicit.

## What It Does

- Download request model.
- Transport and destination policies.
- Size checks, replacement and cleanup behavior.

## When To Use It

- you need reusable product-independent file download behavior.
- downloaded files must respect limits and destination policies.

## When Not To Use It

- you need API-specific request/response mapping; use networking package.
- you only download bundled static assets.

## Ownership Boundary

Package owns download mechanics; host apps own endpoint semantics, auth, user-facing progress, file classification and retention policy.

## Products And Targets

- **Library products**: `AppDownloads`
- **SwiftPM targets**: `AppDownloads`
- **Repository path**: `./PackagesForReuse/AppDownloads`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppDownloads")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDownloads"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppDownloads`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppDownloads.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppDownloads"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppDownloads`.
2. Copy/sync it into `./PackagesInUse/AppDownloads`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppDownloads

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
