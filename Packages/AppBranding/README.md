# AppBranding

`AppBranding` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `AppBranding`

## Structure

```text
AppBranding/
  Package.swift
  README.md
  Sources/
  Tests/
```

The package owns generic brand-token mechanics. Product-specific brand variants must be validated before promoting this package into unrelated projects.

## Verification

Run from this folder:

```bash
swift test
```
