# AppFileStorage Reuse Notes

## Current TchopApp state

`AppFileStorage` is preserved in `./PackagesForReuse` and is now also connected source-only through `./PackagesInUse/AppFileStorage`.

Current app adoption covers composer/feed media storage:

- composer media writes use `LocalFileStorage` under the stable `Documents/TchopComposerMedia` namespace;
- synchronous `Transferable.FileRepresentation` imports use `FileStorageSynchronousOperations` because the platform callback cannot call async actor APIs;
- feed media resolution keeps old absolute/stale-container path compatibility while using the package-owned composer media domain for fallback lookup.

## Still intentionally outside this package adoption

`AppShareExtensionSupport` and `AppNetworking` remain standalone packages with their own file mechanisms. They must not import `AppFileStorage` directly because each root package is required to remain single-folder standalone. Any cross-package composition must live in host app code or optional integration helpers.

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
