# ``TchopOnDeviceAI``

@Metadata {
    @DisplayName("TchopOnDeviceAI")
}

## Overview

Availability, translation, and text transformation support.

## Ownership

`TchopOnDeviceAI` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Concrete prompts and product-specific wording stay outside generic core.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
