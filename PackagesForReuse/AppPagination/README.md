# AppPagination

## Summary

Generic pagination state and page loading/merge mechanics.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids inconsistent load-next/previous state handling.
- Keeps cursor/page/offset advancement validation explicit.
- Centralizes loading-state cleanup on failures.

## What It Does

- Pagination requests/responses.
- State controller/loader mechanics.
- Cursor/page/offset validation.

## When To Use It

- a feature consumes paginated backend/local data.
- pagination state should be independent of endpoint DTOs.

## When Not To Use It

- the feed is fully local and not paginated.
- backend cursor semantics are unusual and should remain app-owned.

## Ownership Boundary

Package owns pagination mechanics; host apps own endpoint semantics, DTO mapping, retry/auth policy and UI loading/error states.

## Products And Targets

- **Library products**: `AppPagination`
- **SwiftPM targets**: `AppPagination`
- **Repository path**: `./PackagesForReuse/AppPagination`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppPagination")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPagination"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppPagination`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppPagination.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPagination"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppPagination`.
2. Copy/sync it into `./PackagesInUse/AppPagination`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppPagination

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
