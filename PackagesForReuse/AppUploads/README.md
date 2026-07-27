# AppUploads

## Summary

Secure generic upload service with URL, size, retry and cancellation policies.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids unsafe ad-hoc file/multipart uploads.
- Centralizes HTTPS/default limits/retry sleeper injection.
- Preserves cancellation semantics.

## What It Does

- Upload request models.
- Data/file/multipart payload policies.
- Retry and response-size validation.

## When To Use It

- you need reusable generic file/data upload behavior.
- uploads need declared-size checks and retry policy.

## When Not To Use It

- you need endpoint DTO mapping; use networking/app API layers.
- the app has no upload feature.

## Ownership Boundary

Package owns upload mechanics; host apps own endpoints, auth, progress UI, payload classification and user-facing errors.

## Products And Targets

- **Library products**: `AppUploads`
- **SwiftPM targets**: `AppUploads`
- **Repository path**: `./PackagesForReuse/AppUploads`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppUploads")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppUploads"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppUploads`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppUploads.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppUploads"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppUploads`.
2. Copy/sync it into `./PackagesInUse/AppUploads`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppUploads

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
