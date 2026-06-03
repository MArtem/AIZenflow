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
