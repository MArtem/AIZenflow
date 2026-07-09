# AppStateMachine

## Summary

Generic async state-machine runtime with guarded transitions and persistence hooks.

## Status In This Repository

Reusable vault package stored under `./PackagesForReuse`; not connected to `TchopApp` unless copied into `./PackagesInUse`.

## What Problem It Solves

- Makes state transitions explicit and serializable.
- Prevents reentrancy races across awaiting guards/actions.
- Surfaces durable-store failures.

## What It Does

- State/event/transition models.
- Async guards/actions.
- Snapshot persistence and revision handling.

## When To Use It

- a domain has clear states/events and transition rules.
- side effects need ordered transition execution.

## When Not To Use It

- the app has simple UI state and a state machine would add ceremony.
- transitions are not yet product-defined.

## Ownership Boundary

Package owns state-machine mechanics; host apps own state model, transition table, side-effect idempotency and persistence policy.

## Products And Targets

- **Library products**: `AppStateMachine`
- **SwiftPM targets**: `AppStateMachine`
- **Repository path**: `./PackagesForReuse/AppStateMachine`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesForReuse/AppStateMachine")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppStateMachine"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesForReuse/AppStateMachine`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppStateMachine.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppStateMachine"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppStateMachine`.
2. Copy/sync it into `./PackagesInUse/AppStateMachine`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppStateMachine

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
