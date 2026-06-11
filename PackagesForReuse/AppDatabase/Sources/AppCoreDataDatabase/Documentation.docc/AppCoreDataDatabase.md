# ``AppCoreDataDatabase``

@Metadata {
    @DisplayName("AppCoreDataDatabase")
}

## Overview

Core Data-backed database adapter for projects that choose Core Data.

## Ownership

`AppCoreDataDatabase` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Core Data queue/context semantics must be explicit.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
