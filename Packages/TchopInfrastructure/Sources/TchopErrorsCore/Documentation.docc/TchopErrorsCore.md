# ``TchopErrorsCore``

@Metadata {
    @DisplayName("TchopErrorsCore")
}

## Overview

Reusable error descriptors, categories, severity, reporting, message catalogs, and manager contracts without networking dependencies.

## Ownership

`TchopErrorsCore` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Use adapter modules for source-specific error mapping.
- UI should consume presentable error descriptors, not raw transport errors.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
