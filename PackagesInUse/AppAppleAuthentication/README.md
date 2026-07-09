# AppAppleAuthentication

## Summary

Sign in with Apple request, credential and authorization helper mechanics.

## Status In This Repository

Active source-only package compiled directly into `TchopApp` targets from `./PackagesInUse`.

## What Problem It Solves

- Keeps Apple-auth integration isolated from feature UI.
- Provides testable boundaries for authorization result handling.
- Avoids duplicating Apple credential parsing across apps.

## What It Does

- Apple authorization request/result contracts.
- Credential normalization helpers.
- Cancellation/failure surface suitable for app error mapping.

## When To Use It

- an app supports Sign in with Apple and wants reusable authorization plumbing.
- you need a boundary between Apple APIs and product login/session code.

## When Not To Use It

- you need full account/session policy; keep that in the app.
- you are not using Apple authentication.

## Ownership Boundary

Package owns Apple API mechanics; host apps own account linking, token/session storage, UI copy and backend auth exchange.

## Products And Targets

- **Library products**: `AppAppleAuthentication`
- **SwiftPM targets**: `AppAppleAuthentication`
- **Repository path**: `./PackagesInUse/AppAppleAuthentication`

## Local SwiftPM Usage

Use this when the package folder is available locally and should be consumed as a SwiftPM package:

```swift
dependencies: [
    .package(path: "../PackagesInUse/AppAppleAuthentication")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppAppleAuthentication"
        ]
    )
]
```

For Xcode, use **File → Add Package Dependencies… → Add Local…** and select `./PackagesInUse/AppAppleAuthentication`.

## Remote SwiftPM Usage

SwiftPM requires a `Package.swift` at the root of the Git repository it consumes. To use this package by URL, first publish/copy this package folder as the root of its own repository, then depend on it like this:

```swift
dependencies: [
    .package(url: "https://github.com/<org>/AppAppleAuthentication.git", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            "AppAppleAuthentication"
        ]
    )
]
```

Do not point SwiftPM at a subfolder of a documentation/app repository and expect it to resolve this package automatically.

## Current TchopApp Source-Only Usage

Current `TchopApp` integration is source-only. If this package is needed by the app now:

1. Keep the reviewed package in `./PackagesForReuse/AppAppleAuthentication`.
2. Copy/sync it into `./PackagesInUse/AppAppleAuthentication`.
3. Add required `Sources/**/*.swift` and resources through `./scripts/migrate_packages_in_use_project.py` or an equivalent project edit that preserves the `PackagesInUse/<PackageName>` Xcode group.
4. Keep product-specific policy in `./TchopApp`; do not add decorative wrappers around package APIs.
5. Run app verification after project/source changes.

## Basic Usage

```swift
import AppAppleAuthentication

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
