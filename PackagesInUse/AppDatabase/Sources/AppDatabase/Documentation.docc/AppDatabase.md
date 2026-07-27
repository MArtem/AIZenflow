# ``AppDatabase``

@Metadata {
    @DisplayName("AppDatabase")
}

## Overview

Compatibility umbrella for database targets only.

## Ownership

`AppDatabase` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Do not add unrelated re-exports.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
