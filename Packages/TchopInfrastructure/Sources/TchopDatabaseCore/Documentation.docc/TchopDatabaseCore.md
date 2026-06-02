# ``TchopDatabaseCore``

@Metadata {
    @DisplayName("TchopDatabaseCore")
}

## Overview

Database backend/configuration/operation contracts shared by database adapters.

## Ownership

`TchopDatabaseCore` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Feature repositories own queries and mapping.
- Avoid hidden umbrella dependencies.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
