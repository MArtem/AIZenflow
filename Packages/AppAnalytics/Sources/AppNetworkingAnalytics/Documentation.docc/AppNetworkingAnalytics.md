# ``AppNetworkingAnalytics``

@Metadata {
    @DisplayName("AppNetworkingAnalytics")
}

## Overview

Maps networking metrics into analytics events.

## Ownership

`AppNetworkingAnalytics` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Adapter-only module; do not make networking depend on analytics.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
