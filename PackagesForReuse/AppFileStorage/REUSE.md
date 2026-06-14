# AppFileStorage Reuse Notes

## Current TchopApp state

`AppFileStorage` is preserved in `./PackagesForReuse` as a standalone source package. It is **not connected to the current app yet**.

## Why it is vault-only now

The current app already has product-specific file storage flows for composer media, feed media previews, share-extension app-group transfer, networking downloads, and offline queues. Replacing those paths safely requires a focused storage migration plan because existing persisted feed cards reference durable media paths and app-group files.

Do not wire this package into `TchopApp` as a broad mechanical replacement. Adopt it only in a dedicated file-storage migration block with compatibility checks for existing media references, app-group data, and feed-card persistence.

## When to adopt

Use this package when a project needs generic app-owned file storage with:

- component-based relative paths;
- privacy-safe diagnostics;
- actor-isolated file operations;
- atomic replacement writes;
- symlink escape protection;
- cleanup and size accounting.

## SwiftPM usage

Copy `AppFileStorage` into a project package area, then link the product:

```swift
.package(path: "Packages/AppFileStorage")
```

```swift
.product(name: "AppFileStorage", package: "AppFileStorage")
```

Run package verification before adoption:

```zsh
cd ./Packages/AppFileStorage
./Scripts/verify_package.sh
```

## Source-only usage

For current disk-light source-only mode, copy this folder into `./PackagesInUse/AppFileStorage` only when a concrete app migration is approved, then add `Sources/AppFileStorage/**/*.swift` to the app target and run project verification.
