# ``TchopShareSupport``

@Metadata {
    @DisplayName("TchopShareSupport")
}

## Overview

App-group JSON stores, share item import contracts, durable file copy helpers, and quarantine support.

## Ownership

`TchopShareSupport` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Validate imported files and keep app-specific card mapping outside the package.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
