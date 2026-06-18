# AppUploads Reuse Notes

## Current TchopApp state

`AppUploads` is preserved in `./PackagesForReuse` as a vault-only package.

It is not copied into `./PackagesInUse` in this block because current `TchopApp` has no product-level generic upload feature to migrate. The active `./PackagesInUse/AppNetworking` package already owns API-oriented file upload behavior for networking clients. Connecting `AppUploads` now would duplicate mechanisms and risk weakening existing endpoint/DTO/auth/retry contracts.

## When to adopt

Use this package when a project needs app-independent bounded upload primitives with:

- secure-by-default `https` request validation;
- safe upload field and file names;
- redacted URL/file/field descriptions;
- in-memory data, file, and multipart payload modeling;
- actor-isolated file reads/multipart preparation;
- injectable retry sleep for deterministic tests;
- explicit host-owned transport boundary for auth, streaming, background uploads, and telemetry;
- package-owned tests and strict-concurrency verification.

The default body worker prepares payload bytes in memory before transport. Use it for bounded uploads with `maximumPayloadBytes`. Streaming, resumable, background, authenticated, retried, or offline-queued uploads should use a host-owned transport or dedicated package/integration layer.

## SwiftPM usage

Copy `AppUploads` into a project package area, then link the product:

```swift
.package(path: "Packages/AppUploads")
```

```swift
.product(name: "AppUploads", package: "AppUploads")
```

Run package verification before adoption:

```zsh
cd ./Packages/AppUploads
./Scripts/verify_package.sh
```

## Source-only usage

For the current disk-light source-only mode, copy this folder into `./PackagesInUse/AppUploads` only when a concrete app integration is approved, then add `Sources/AppUploads/**/*.swift` to relevant Xcode targets and run project verification.
