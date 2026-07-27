# AppShareExtensionSupport

## Summary

Share extension import, app-group JSON storage and pending-item transfer support.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Keeps extension/app handoff durable.
- Handles app-group JSON item storage and corruption quarantine.
- Separates generic share import mechanics from product mapping.

## What It Does

- App-group JSON item stores.
- Share item importer helpers.
- Pending item load/remove/quarantine operations.

## When To Use It

- an app has a share extension that writes pending content for the main app.
- app-group storage must tolerate partial/corrupted items.

## When Not To Use It

- you need product-specific feed/card mapping; keep that in host app.
- there is no app-group/share-extension flow.

## Ownership Boundary

Package owns share/app-group mechanics; host apps own app-group identifier, item schema, import mapping, UX and cleanup policy.

## Products And Targets

- **Library products**: `AppShareExtensionSupport`
- **SwiftPM targets**: `AppShareExtensionSupport`
- **Repository path**: `./PackagesForReuse/AppShareExtensionSupport`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppShareExtensionSupport")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppShareExtensionSupport"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppShareExtensionSupport`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppShareExtensionSupport.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppShareExtensionSupport"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppShareExtensionSupport`.
2. Copy/sync it into `./PackagesInUse/AppShareExtensionSupport`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppShareExtensionSupport

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
