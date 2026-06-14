# AppImagePipeline Reuse Notes

## Current TchopApp state

`AppImagePipeline` is preserved in `./PackagesForReuse` as a vault-only package.

It is not copied into `./PackagesInUse` in this block because current `TchopApp` image usage is local composer/feed media preview generation with platform-specific downsampling and stable local file references. `AppImagePipeline` owns generic remote/provided image-byte loading and bounded byte caching; adopting it now would not replace a current app path without adding speculative remote image behavior.

## When to adopt

Use this package when a project needs generic app-independent image-byte loading with:

- redacted URL/cache-key diagnostics;
- bounded actor-isolated memory cache;
- bounded actor-isolated disk cache;
- optional remote fetching through `URLSession`;
- content-type allowlisting;
- package-owned tests and strict-concurrency verification.

Do not use it as a replacement for platform image decoding/downsampling by itself. Host apps still own `UIImage`/`NSImage`/SwiftUI rendering, placeholder layout, memory-pressure policy, cache-directory/file-protection choice, and product-specific image semantics.

## SwiftPM usage

Copy `AppImagePipeline` into a project package area, then link the product:

```swift
.package(path: "Packages/AppImagePipeline")
```

```swift
.product(name: "AppImagePipeline", package: "AppImagePipeline")
```

Run package verification before adoption:

```zsh
cd ./Packages/AppImagePipeline
./Scripts/verify_package.sh
```

## Source-only usage

For the current disk-light source-only mode, copy this folder into `./PackagesInUse/AppImagePipeline` only when a concrete app integration is approved, then add `Sources/AppImagePipeline/**/*.swift` to the relevant Xcode targets and run project verification.
