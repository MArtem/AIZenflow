# AppUploads

Prepare and send app-independent uploads through standalone Swift primitives.

## Overview

`AppUploads` provides a small infrastructure layer for upload requests. It models upload IDs, URLs, payloads, file references, multipart forms, progress, responses, retry policy, transport, and an explicit worker boundary for file reading.

The package is standalone and has no dependency on other SDK packages.

`UploadRequest` is `https`-only by default. Hosts may explicitly allow `http` for concrete local-development or fixture needs.

The default body worker prepares upload payload bytes in memory before transport. Use `maximumPayloadBytes` for untrusted files or user-selected media. Streaming, resumable, or background uploads should be implemented through a host-owned transport or a dedicated future package.

Swift task cancellation is preserved as cancellation and is not retried or collapsed into generic transport failure.

## Topics

### Request Modeling

- ``UploadRequest``
- ``UploadID``
- ``UploadHTTPMethod``
- ``UploadPayload``
- ``UploadRetryPolicy``

### Payloads

- ``UploadFileReference``
- ``UploadFormField``
- ``UploadMultipartForm``
- ``SafeUploadName``
- ``UploadMediaType``

### Execution

- ``UploadService``
- ``UploadTransport``
- ``FoundationUploadTransport``
- ``UploadBodyLoadWorker``
- ``PreparedUpload``

### Results

- ``UploadProgress``
- ``UploadResponse``
- ``UploadFailure``
- ``UploadURLRedactor``
