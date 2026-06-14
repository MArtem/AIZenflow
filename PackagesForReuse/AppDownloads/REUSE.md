# AppDownloads Reuse Notes

## Current TchopApp state

`AppDownloads` is preserved in `./PackagesForReuse` as a vault-only package.

It is not copied into `./PackagesInUse` in this block because current `TchopApp` does not have a product-level generic download feature to migrate. The active `./PackagesInUse/AppNetworking` package already owns API-oriented request/download behavior used by networking clients. Replacing or layering that with `AppDownloads` now would duplicate mechanisms and risk weakening existing networking contracts.

## When to adopt

Use this package when a project needs app-independent small/bounded download primitives with:

- secure-by-default `https` request validation;
- safe destination file-name validation/sanitization;
- redacted request/destination/receipt descriptions;
- actor-isolated file writes and cleanup;
- replacement/unique-name destination policy;
- response size limits for bounded in-memory downloads;
- package-owned tests and strict-concurrency verification.

The default Foundation transport keeps response data in memory before persistence. Use it for bounded downloads with `maximumAllowedBytes`. Streaming, resumable, background, authenticated, retried, or offline-queued downloads should use a host-owned transport or a dedicated package/integration layer.

## SwiftPM usage

Copy `AppDownloads` into a project package area, then link the product:

```swift
.package(path: "Packages/AppDownloads")
```

```swift
.product(name: "AppDownloads", package: "AppDownloads")
```

Run package verification before adoption:

```zsh
cd ./Packages/AppDownloads
./Scripts/verify_package.sh
```

## Source-only usage

For the current disk-light source-only mode, copy this folder into `./PackagesInUse/AppDownloads` only when a concrete app integration is approved, then add `Sources/AppDownloads/**/*.swift` to relevant Xcode targets and run project verification.
