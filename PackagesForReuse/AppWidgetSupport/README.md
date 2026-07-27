# AppWidgetSupport

## Summary

Widget snapshot storage and generic widget data handoff support.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Avoids app-specific payloads inside reusable widget package.
- Centralizes UserDefaults/app-group snapshot storage.
- Makes widget data writes and clears testable.

## What It Does

- Generic widget snapshot store.
- UserDefaults/app-group storage helpers.
- Save/load/clear operations.

## When To Use It

- an app/widget extension shares snapshots through app group storage.
- widget payload needs generic storage mechanics.

## When Not To Use It

- you need widget UI/timeline policy; keep it in widget/app code.
- there is no widget extension.

## Ownership Boundary

Package owns widget storage mechanics; host apps own snapshot payload type, timeline reload policy, widget UI and app-group identifier.

## Products And Targets

- **Library products**: `AppWidgetSupport`
- **SwiftPM targets**: `AppWidgetSupport`
- **Repository path**: `./PackagesForReuse/AppWidgetSupport`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppWidgetSupport")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppWidgetSupport"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppWidgetSupport`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppWidgetSupport.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppWidgetSupport"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppWidgetSupport`.
2. Copy/sync it into `./PackagesInUse/AppWidgetSupport`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppWidgetSupport

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
