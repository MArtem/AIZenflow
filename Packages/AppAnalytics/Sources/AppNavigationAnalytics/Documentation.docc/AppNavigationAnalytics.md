# ``AppNavigationAnalytics``

@Metadata {
    @DisplayName("AppNavigationAnalytics")
}

## Overview

Maps navigation events into analytics events.

## Ownership

`AppNavigationAnalytics` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Adapter-only module; it imports navigation and analytics core.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
