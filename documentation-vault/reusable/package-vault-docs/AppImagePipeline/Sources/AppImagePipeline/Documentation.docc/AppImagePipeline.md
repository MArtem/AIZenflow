# AppImagePipeline

A standalone, app-independent image data pipeline package for iOS infrastructure projects.

## Purpose

`AppImagePipeline` provides a small production-oriented image loading mechanism: request modeling, remote data fetching, memory cache, disk cache, prefetching, sanitized diagnostics, and actor-isolated cache operations.

`ImageMemoryCache` and `ImageDiskCache` are bounded by entry count and byte count. Disk cache filenames are deterministic internal implementation details and public diagnostics must not expose raw URL, token, header, or cache-key values.

## Non-goals

This package does not define product-specific image URLs, feed card rendering, avatar UI, image editor UI, CDN policy, analytics events, networking interceptors, or feature-level repositories.

This package returns image bytes. Host apps still own platform image decoding/downsampling, placeholder layout, memory-pressure cleanup policy, cache-directory/file-protection choice, and SwiftUI/UIKit/AppKit rendering.

## Standalone contract

The package has no sibling package dependencies and can be copied as a single folder into another project.
