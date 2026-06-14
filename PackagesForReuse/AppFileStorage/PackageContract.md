# AppFileStorage Package Contract

## Identity

- Package name: `AppFileStorage`
- Root folder: `AppFileStorage`
- Product: `AppFileStorage`
- Primary target: `AppFileStorage`

## Standalone rules

`AppFileStorage` must remain a 100% single-folder standalone package.

Required:

- `Package.swift`
- `README.md`
- `PackageContract.md`
- `Sources/AppFileStorage/Documentation.docc/`
- `Tests/`
- `Scripts/verify_package.sh`

Forbidden:

- sibling path dependencies;
- remote package dependencies;
- imports of sibling infrastructure modules;
- package-local `.build` or `.swiftpm` folders;
- unresolved placeholders;
- product-specific routes, screens, resources, or copy;
- raw sensitive file paths in diagnostics or descriptions.

## Verification

The local verifier uses a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppFileStorage
```

The verifier must not create package-local SwiftPM artifacts.

## Concurrency

Public storage operations are async. `LocalFileStorage` is an actor, so file I/O is isolated behind an explicit execution boundary and does not run as direct synchronous work on caller isolation.

## Storage safety

- Relative paths are component-based and must not contain traversal markers or separators.
- Directory providers must not build filesystem paths from privacy-redacted descriptions.
- Reads and writes must validate the resolved filesystem location remains inside the configured storage directory after symlink resolution.
- Atomic replacement must not delete an existing destination before the replacement file is ready.

## Privacy

Public descriptions and diagnostics must not expose raw namespace values, raw relative paths, absolute file paths, URL query values, tokens, user IDs, or filenames that can identify private user content.

## Integration policy

If another package wants to use `AppFileStorage`, the composition must live in host app code or in optional `IntegrationHelpers`. This package must not depend on `AppDownloads`, `AppUploads`, `AppImagePipeline`, `AppDiagnostics`, `AppLogging`, or `AppErrors`.
