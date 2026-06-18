# AppDownloads

`AppDownloads` is a standalone InfrastructureSDK package for app-independent download primitives.

It is intentionally not a networking architecture, not a cache package, not a logging package, and not a diagnostics package. It only provides the mechanism needed to describe, validate, download, persist, inspect, and clean downloaded files.

## What is included

- `DownloadRequest` with URL validation and optional response size limit.
- `SafeDownloadFileName` for portable, traversal-safe destination names.
- `DownloadDirectoryRole` and `DownloadDirectory` for host-provided storage locations.
- `DownloadDirectoryResolver` for standard directories and platform guarded shared containers.
- `FoundationDownloadTransport` as the default transport.
- `DownloadFileSystemWorker` actor for file writes, metadata, and removal.
- `DownloadCleanupWorker` actor for age and total-size cleanup policies.
- `DownloadService` actor combining transport and persistence.
- Source-owned DocC at `Sources/AppDownloads/Documentation.docc/AppDownloads.md`.
- Fail-fast `Scripts/verify_package.sh`.

## Standalone guarantees

This root package has:

- no `.package(path:)` dependencies;
- no `.package(url:)` dependencies;
- no imports of sibling InfrastructureSDK packages;
- no app/product/domain-specific entities;
- no dependency on AppFileStorage, AppImagePipeline, AppRemoteAssets, AppLogging, AppDiagnostics, AppConnectivity, or AppSession.

The folder can be copied into another repository and opened as a Swift Package by itself.

## Privacy and diagnostics baseline

Diagnostics and textual representations avoid revealing raw identifiers, full URLs, query strings, fragments, full paths, file names, or shared container identifiers.

The package stores operational values where required to perform work, but public `description` values are redacted by default.

`DownloadRequest` accepts `https` URLs by default. Insecure `http` must be explicitly allowed by the host, for example for local development fixtures.

## Concurrency boundary

File system operations can block. This package does not hide those operations inside decorative async wrappers on a caller executor. Potentially blocking file I/O is isolated behind dedicated actors:

- `DownloadFileSystemWorker`
- `DownloadCleanupWorker`

`DownloadService` is also an actor and delegates persistence to the file system worker.

The default Foundation transport is an in-memory data transport. It is appropriate for bounded app downloads where `maximumAllowedBytes` is set by the host. Large streaming/background downloads should use a host-owned transport or a future dedicated streaming/background package.

## Basic example

```swift
import AppDownloads
import Foundation

let request = try DownloadRequest(url: URL(string: "https://example.com/manual.pdf")!)
let directory = try DownloadDirectoryResolver.standard(.caches)
let fileName = try SafeDownloadFileName("manual.pdf")
let destination = DownloadDestination(directory: directory, fileName: fileName)
let service = DownloadService()
let receipt = try await service.download(request, to: destination)
print(receipt)
```

## Verification

Run:

```bash
cd AppDownloads
./Scripts/verify_package.sh
```

The verifier copies the package into a worktree-local scratch directory outside the package folder, runs package checks there, and removes the scratch directory afterwards.
