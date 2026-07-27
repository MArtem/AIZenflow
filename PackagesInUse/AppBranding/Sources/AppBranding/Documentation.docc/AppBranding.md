# ``AppBranding``

@Metadata {
    @DisplayName("AppBranding")
}

## Overview

Brand theme and token contracts for UI composition.

## Ownership

`AppBranding` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Product-specific brand variants should move to app/feature packages when promoted.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
