# AppConfiguration

`AppConfiguration` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `AppConfiguration`

## Structure

```text
AppConfiguration/
  Package.swift
  README.md
  Sources/
  Tests/
```

The package is self-contained and keeps its tests beside its source.

## Verification

Run from this folder:

```bash
swift test
```

## vNext2 runtime metadata

`UIConfigurationManager` now exposes `runtimeMetadata()` for diagnostics and observability. It reports where the current snapshot came from (`fallback`, `cache`, or `remote`) and tracks the last successful or failed refresh attempt.

```swift
let metadata = await manager.runtimeMetadata()
print(metadata.currentSource)
print(metadata.lastSuccessfulFetchAt)
print(metadata.lastFailedFetchAt)
```

This keeps the payload generic while giving product apps enough information to build debug screens, support logs, or non-invasive telemetry.

## Portability

Required sibling packages: **None**

Copy modes:
- **Standalone copy mode:** supported.
- **Local path dependency mode:** supported when this folder is copied with its required siblings using the same relative layout.
- **Git URL dependency mode:** supported after replacing local `.package(path:)` declarations with package URLs.
- **Bundle copy mode:** supported by copying the whole `Packages/` directory.

This package can be copied as a single folder. Use bundle copy mode if you want all packages and scripts together.


## vNext3 sanitized diagnostics

Refresh failures are exposed through `UIConfigurationFailureDescriptor` instead of raw
`String(describing: error)` values. This prevents support/diagnostic metadata from leaking URLs,
backend text, file paths, or token-like values. `lastFailureDescription` remains available as a
sanitized compatibility code; prefer `lastFailure` for new integrations.

After a successful remote refresh, the active failure descriptor is cleared while historical
`lastFailedFetchAt` can remain available for diagnostics.
