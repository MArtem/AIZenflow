# AppRemoteAssets Reuse Notes

## Current TchopApp state

`AppRemoteAssets` is preserved in `./PackagesForReuse` as a vault-only package.

It is not copied into `./PackagesInUse` in this block because current `TchopApp` has no product-level remote asset manifest runtime to migrate. Feed/composer media currently uses local persisted card media and app-owned file references; connecting a remote asset manifest planner now would add unused infrastructure.

## When to adopt

Use this package when a project needs app-independent remote asset coordination with:

- secure-by-default `https` manifest and asset URL validation;
- safe asset identifiers and versions;
- checksum validation with algorithm-specific hex length;
- privacy-safe URL and failure diagnostics;
- manifest decoding and duplicate asset detection;
- host-owned transport boundary for manifest loading;
- fetch planning against host-owned local records;
- no file storage, byte transfer, image decoding, logging, analytics, or background scheduling inside the root package.

The package plans what should be kept, fetched, or removed. Host apps still own download execution, file storage, checksum verification after byte transfer, retry/offline policy, background scheduling, and telemetry.

## SwiftPM usage

Copy `AppRemoteAssets` into a project package area, then link the product:

```swift
.package(path: "Packages/AppRemoteAssets")
```

```swift
.product(name: "AppRemoteAssets", package: "AppRemoteAssets")
```

Run package verification before adoption:

```zsh
cd ./Packages/AppRemoteAssets
./Scripts/verify_package.sh
```

## Source-only usage

For the current disk-light source-only mode, copy this folder into `./PackagesInUse/AppRemoteAssets` only when a concrete app integration is approved, then add `Sources/AppRemoteAssets/**/*.swift` to relevant Xcode targets and run project verification.
