# ``AppCache``

@Metadata {
    @DisplayName("AppCache")
}

## Overview

Memory and file-backed generic cache support.

## Ownership

`AppCache` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Do not cache full-resolution media in UI rows.
- Cache expiry and storage policy must be explicit.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
