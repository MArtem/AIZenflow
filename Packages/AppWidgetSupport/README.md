# AppWidgetSupport

`AppWidgetSupport` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `AppWidgetSupport`

## Structure

```text
AppWidgetSupport/
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

## Portability

Required sibling packages: **None**

Copy modes:
- **Standalone copy mode:** supported.
- **Local path dependency mode:** supported when this folder is copied with its required siblings using the same relative layout.
- **Git URL dependency mode:** supported after replacing local `.package(path:)` declarations with package URLs.
- **Bundle copy mode:** supported by copying the whole `Packages/` directory.

This package can be copied as a single folder. Use bundle copy mode if you want all packages and scripts together.


## Usage guide

See `./USAGE.md` for package/app boundary rules and host integration guidance.
