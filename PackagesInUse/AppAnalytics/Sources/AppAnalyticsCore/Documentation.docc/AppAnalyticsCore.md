# ``AppAnalyticsCore``

@Metadata {
    @DisplayName("AppAnalyticsCore")
}

## Overview

Event, domain, collector, and in-memory/no-op analytics contracts without navigation, networking, or push dependencies.

## Ownership

`AppAnalyticsCore` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Adapters depend on core, never the reverse.
- Attributes must remain stable and privacy-safe.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
