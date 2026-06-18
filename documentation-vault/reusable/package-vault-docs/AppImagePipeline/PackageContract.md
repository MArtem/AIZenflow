# AppImagePipeline Package Contract

## Package identity

- Package name: `AppImagePipeline`
- Root folder: `AppImagePipeline`
- Target name: `AppImagePipeline`

## Standalone contract

This package must remain 100% single-folder standalone.

Allowed:

- Swift standard library
- Foundation
- FoundationNetworking when available through compile guards

Forbidden:

- `.package(path: "../...")`
- remote package dependencies
- imports of sibling infrastructure packages
- app-specific image URLs or feature names
- raw URL/query/header/body/token values in diagnostics
- package-local `.build`, `.swiftpm`, `Package.resolved`, or generated workspace artifacts
- unbounded memory or disk cache retention
- platform-specific UI image rendering, downsampling, or SwiftUI view policy inside the package

## Documentation contract

DocC documentation must be source-owned:

```text
Sources/AppImagePipeline/Documentation.docc/
```

## Verification contract

`Scripts/verify_package.sh` must use a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppImagePipeline
```

It must not use system temporary directories or package-local build folders.

Verification output must fail on compiler `warning:` or `error:` lines.

## Cache and media contract

`AppImagePipeline` owns generic image-byte request, memory-cache, disk-cache, and prefetch mechanics only.

- `ImageMemoryCache` and `ImageDiskCache` must remain bounded by entry count and total bytes.
- Disk cache entries use deterministic internal filenames derived from cache keys, but public diagnostics must not expose raw URLs, tokens, headers, or cache-key values.
- The package does not decode bytes into `UIImage`, `NSImage`, or SwiftUI `Image`, and it does not choose product-specific placeholder/layout behavior.
- Host apps own image decoding/downsampling, memory-pressure integration, file-protection/cache-directory selection, and UI rendering policy.
