# TchopProductLocalizationResources

`TchopProductLocalizationResources` is a standalone Swift package intended to move into another project as one complete folder.

## Ownership

- **Package owns**: reusable mechanisms, public contracts, documentation, and package-owned tests for the products listed below.
- **App owns**: product-specific policy, concrete feature behavior, user-facing copy, backend-specific decisions, and app composition.

## Products

- `TchopProductLocalizationResources`

## Structure

```text
TchopProductLocalizationResources/
  Package.swift
  README.md
  Sources/
  Tests/
```

This package is intentionally product-specific. It should move with TchopApp, not into unrelated apps as reusable infrastructure.

## Verification

Run from this folder:

```bash
swift test
```
