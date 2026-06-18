# AppImagePipeline

`AppImagePipeline` is a 100% single-folder standalone Swift package that provides app-independent image data loading and caching infrastructure.

## Includes

- `ImageRequest`
- `ImageCacheKey`
- `ImageResponse`
- `ImageDataFetching`
- `URLSessionImageDataFetcher`
- `MockImageDataFetcher`
- `ImageMemoryCache`
- `ImageDiskCache`
- `DefaultImagePipeline`
- `ImagePipelineDiagnostics`

## Design rules

- No product-specific image URLs.
- No feed/profile/news/avatar domain logic.
- No analytics/logging/networking package dependency.
- No sibling package imports.
- No raw URL, token, credential, or cache key in diagnostics/descriptions.
- Disk cache filenames are deterministic but never exposed through public diagnostics.
- Memory and disk caches are bounded by entry count and byte count.
- Content-type allowlists are enforced by the pipeline when callers provide `preferredContentTypes`.
- Error descriptions expose stable failure codes only; arbitrary diagnostic codes are sanitized before display.

## Usage

```swift
let pipeline = DefaultImagePipeline()
let request = try ImageRequest.url(URL(string: "https://example.com/image.png")!)
let response = try await pipeline.image(for: request)
```

Use a disk cache only when the host app owns an appropriate cache directory and retention policy:

```swift
let diskCache = ImageDiskCache(
    rootDirectory: cacheDirectory,
    maximumEntryCount: 500,
    maximumTotalBytes: 100 * 1024 * 1024
)
let pipeline = DefaultImagePipeline(diskCache: diskCache)
```

This package returns image bytes. Host apps remain responsible for platform-specific image decoding, downsampling, view placeholders, memory-pressure behavior, and UI rendering policy.

## Verification

```bash
cd AppImagePipeline
./Scripts/verify_package.sh
```

The verification script uses a worktree-local scratch path outside the package folder.
