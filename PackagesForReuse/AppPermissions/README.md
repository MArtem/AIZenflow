# AppPermissions

## Summary

Permission status/request helper mechanics for Apple platform capabilities.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Centralizes permission state modeling.
- Keeps Info.plist/capability requirements visible.
- Avoids duplicating request/status translation.

## What It Does

- Permission identifiers/status contracts.
- Request/check helper boundaries.
- Testable permission providers.

## When To Use It

- features use camera/photos/files/notifications/location-like capabilities.
- permission UI needs consistent state.

## When Not To Use It

- the permission is one-off and native API call is clearer.
- you need product copy/education screens; keep those in app UI.

## Ownership Boundary

Package owns permission mechanics; host apps own entitlement/plist setup, educational UI, copy and fallback behavior.

## Products And Targets

- **Library products**: `AppPermissions`
- **SwiftPM targets**: `AppPermissions`
- **Repository path**: `./PackagesForReuse/AppPermissions`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppPermissions")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPermissions"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppPermissions`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppPermissions.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppPermissions"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppPermissions`.
2. Copy/sync it into `./PackagesInUse/AppPermissions`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppPermissions

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
