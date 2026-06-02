# ``TchopNetworking``

@Metadata {
    @DisplayName("TchopNetworking")
}

## Overview

Typed request execution, retry policy, interceptors, connectivity, upload/download helpers, offline queue primitives, and test doubles.

## Ownership

`TchopNetworking` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Keep request/DTO ownership in app or feature modules.
- Use Swift task cancellation as the primary cancellation mechanism.
- Do not log credentials or unredacted sensitive query values.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
