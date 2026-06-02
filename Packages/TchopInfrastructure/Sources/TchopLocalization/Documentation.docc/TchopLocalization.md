# ``TchopLocalization``

@Metadata {
    @DisplayName("TchopLocalization")
}

## Overview

Bundle-backed localization lookup and locale fallback support.

## Ownership

`TchopLocalization` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Generic package owns lookup behavior; app/feature modules own product strings.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
