# AppDownloads

AppDownloads is a standalone Swift package for app-independent download primitives.

## Overview

The package provides:

- validated download requests;
- safe destination file names;
- directory role descriptors;
- atomic file persistence behind an actor boundary;
- metadata reading;
- cleanup policies;
- redacted diagnostics for URLs, paths, file names, and container identifiers;
- optional platform guarded shared container resolution.

Root package constraints:

- no sibling SDK package imports;
- no remote dependencies;
- no product-specific entities;
- no logging or analytics integration;
- all blocking file system operations live behind `DownloadFileSystemWorker` or `DownloadCleanupWorker` actors.

`DownloadRequest` is `https`-only by default. Hosts may explicitly allow `http` for concrete local-development or fixture needs.

The default Foundation transport keeps response data in memory before persistence. Use `maximumAllowedBytes` for untrusted or potentially large responses. Streaming, resumable, or background downloads should be implemented through a host-owned transport or a dedicated future package.

Swift task cancellation is preserved as cancellation and is not collapsed into a generic transport failure.

## Basic usage

```swift
let request = try DownloadRequest(url: URL(string: "https://example.com/file.pdf")!)
let directory = try DownloadDirectoryResolver.standard(.caches)
let name = try SafeDownloadFileName("file.pdf")
let destination = DownloadDestination(directory: directory, fileName: name)
let service = DownloadService()
let receipt = try await service.download(request, to: destination)
```

## Host app responsibilities

The host app owns user-facing policy: where files should live, what network permissions are needed, whether a shared container is available, how user consent is represented, and how progress is displayed.
