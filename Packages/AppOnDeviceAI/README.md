# AppOnDeviceAI

`AppOnDeviceAI` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `AppOnDeviceAI`

## Structure

```text
AppOnDeviceAI/
  Package.swift
  README.md
  Sources/
  Tests/
```

The package owns the AI manager contract and neutral runtime adapters. Prompt wording must stay app-neutral; app-specific prompt policy belongs in the app.

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
