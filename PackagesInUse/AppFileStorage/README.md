# AppFileStorage

`AppFileStorage` is a standalone Swift package for app-owned file storage.

It provides:

- safe relative path modeling;
- directory providers with non-colliding custom roots;
- atomic replacement writes;
- symlink escape checks;
- read, write, copy, remove, remove-all;
- file attributes;
- recursive listing;
- total size calculation;
- cleanup policies;
- privacy-safe diagnostics;
- test-friendly static directory provider.

## Basic usage

```swift
let storage = LocalFileStorage(
    root: .applicationSupport,
    namespace: FileStorageNamespace("offline-cache")
)

let path = try FileStorageRelativePath("articles", "page-1.json")
try await storage.write(data, to: path, options: .default)
try await storage.copyFile(from: sourceURL, to: path, options: .default)
let fileURL = try await storage.fileURL(for: path)
let loaded = try await storage.read(from: path, options: .default)
```

## What belongs here

Generic file system mechanisms:

- app storage directories;
- safe filenames and relative paths;
- atomic writes;
- cleanup;
- file size and metadata;
- diagnostics without raw file paths.

## What does not belong here

- product-specific directories;
- feature-specific file names;
- image loading pipelines;
- downloads/uploads;
- user-facing error copy;
- analytics/logging integrations;
- database export formats.

Those integrations should live in host app code or optional `IntegrationHelpers`.

## Storage safety contract

`FileStorageRelativePath` accepts only explicit path components and rejects empty components, traversal markers, separators, and control characters.

`LocalFileStorage` resolves every operation inside its configured storage directory and rejects symlink escapes before reading or writing. Atomic writes preserve the previous file until replacement succeeds.

Custom roots use the sanitized custom namespace value as a real directory name; the redacted `description` is never used for path construction.

## Standalone contract

This package has no sibling dependencies and no remote dependencies. It can be copied as a single folder into a new project and verified with:

```bash
./Scripts/verify_package.sh
```
