# ``TchopSwiftDataDatabase``

@Metadata {
    @DisplayName("TchopSwiftDataDatabase")
}

## Overview

SwiftData-backed database adapter for projects that choose SwiftData.

## Ownership

`TchopSwiftDataDatabase` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- SwiftData-specific behavior stays isolated in this adapter.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
