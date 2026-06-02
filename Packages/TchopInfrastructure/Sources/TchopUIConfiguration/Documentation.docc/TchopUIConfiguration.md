# ``TchopUIConfiguration``

@Metadata {
    @DisplayName("TchopUIConfiguration")
}

## Overview

Generic configuration snapshot, store, remote provider, and manager for app-owned payloads.

## Ownership

`TchopUIConfiguration` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Payload types stay in the app or feature layer.
- Stores must document concurrency and persistence behavior.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
