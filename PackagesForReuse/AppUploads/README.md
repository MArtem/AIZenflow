# AppUploads

`AppUploads` is a standalone Swift package with app-independent primitives for preparing and sending uploads from iOS, macOS, tvOS, and watchOS apps.

The package is intentionally infrastructure-only. It does not depend on sibling SDK packages and does not include product-specific upload flows, analytics, diagnostics, logging, cache, or persistence code.

## Goals

- Validate upload URLs and identifiers.
- Model upload payloads as in-memory data, file references, or multipart forms.
- Provide safe upload names for field names and file names.
- Keep potentially blocking file reads behind an explicit actor boundary.
- Provide a small transport abstraction for host apps and tests.
- Provide a Foundation-backed transport for basic `POST`, `PUT`, and `PATCH` uploads.
- Keep descriptions and diagnostics redacted by default.
- Preserve Swift task cancellation instead of mapping it to generic transport failure.

## Non-goals

- Background transfer session lifecycle management.
- Authentication or credential injection.
- Logging, analytics, crash reporting, or diagnostics integration.
- Cross-package composition with AppFileStorage, AppDownloads, AppDiagnostics, or AppLogging.
- Large-file streaming APIs. This package prepares payload data before transport; host apps that need streaming should provide a custom `UploadTransport`.

`UploadRequest` accepts `https` URLs by default. Insecure `http` must be explicitly allowed by the host, for example for local development fixtures.

The default body worker prepares upload payload bytes in memory before transport. Host apps must set `maximumPayloadBytes` for untrusted files or user-selected media. Large streaming, resumable, or background uploads require a host-owned transport or a future dedicated package.

## Basic usage

```swift
import AppUploads
import Foundation

let request = try UploadRequest(
    id: try UploadID("avatar-upload"),
    url: URL(string: "https://example.com/upload")!,
    method: .post,
    payload: .data(Data([1, 2, 3]), mediaType: .binary),
    maximumPayloadBytes: 10_000_000,
    maximumResponseBytes: 64_000
)

let service = UploadService()
let response = try await service.upload(request) { progress in
    print(progress.fractionCompleted ?? 0)
}
```

## File upload

```swift
let file = try UploadFileReference(
    fileURL: localFileURL,
    fieldName: try SafeUploadName("file"),
    fileName: try SafeUploadName("avatar.jpg"),
    mediaType: try UploadMediaType("image/jpeg")
)

let request = try UploadRequest(
    id: try UploadID("avatar-upload"),
    url: uploadURL,
    payload: .file(file)
)
```

## Multipart upload

```swift
let form = try UploadMultipartForm(
    fields: [
        try UploadFormField(name: try SafeUploadName("kind"), value: "avatar")
    ],
    files: [file]
)

let request = try UploadRequest(
    id: try UploadID("multipart-avatar"),
    url: uploadURL,
    payload: .multipart(form)
)
```

## Privacy baseline

- `description` values do not reveal upload identifiers, full file paths, field values, or file names.
- URL query and fragment are removed from redacted URL output.
- The package does not store credential-bearing fields.
- Host apps that need authenticated requests should provide an app-owned `UploadTransport` boundary.

## Verification

Run from the package root:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppUploads
```

It removes that scratch path after verification and fails fast if package-local build artifacts are left behind.
