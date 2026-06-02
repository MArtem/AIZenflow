# ``TchopDatabaseComposition``

@Metadata {
    @DisplayName("TchopDatabaseComposition")
}

## Overview

Backend selection and database manager resolution.

## Ownership

`TchopDatabaseComposition` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Composition must not import app navigation or feature policy.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
