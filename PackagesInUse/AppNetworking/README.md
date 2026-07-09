# AppNetworking

## Summary

HTTP/API networking mechanics: requests, retries, interceptors, auth refresh, uploads/downloads and offline queue support.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Avoids duplicating URLSession request code.
- Centralizes retry/cancellation/auth-refresh semantics.
- Keeps API transport errors and rich HTTP failure context consistent.

## What It Does

- API request/response models.
- Network manager/runtime.
- Interceptors, auth refresh coalescing and retry sleeper injection.
- Mock/testing helpers and offline queue primitives.

## When To Use It

- you need reusable API transport behavior.
- requests need retries, cancellation, auth refresh or upload/download support.

## When Not To Use It

- you need endpoint DTO/domain mapping; keep that in app/repository layers.
- you only need one direct URLSession call.

## Ownership Boundary

Package owns transport mechanics; host apps own endpoints, DTO mapping, auth token policy, telemetry, privacy and user-facing errors.

## Products And Targets

- **Library products**: `AppNetworking`
- **SwiftPM targets**: `AppNetworking`
- **Repository path**: `./PackagesInUse/AppNetworking`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppNetworking")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppNetworking"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppNetworking`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppNetworking.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppNetworking"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppNetworking`.
2. Copy/sync it into `./PackagesInUse/AppNetworking`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppNetworking

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
- `./USAGE.md`

## Documentation Maintenance

Every new reusable package must include this level of README detail and the package must be listed in `./PackagesForReuse/PACKAGE_CATALOG.md`. If the package is copied into `./PackagesInUse`, update `./PackagesInUse/README.md` and keep both package README files consistent.
