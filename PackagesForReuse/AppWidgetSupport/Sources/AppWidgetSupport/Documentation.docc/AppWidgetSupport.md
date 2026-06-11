# ``AppWidgetSupport``

@Metadata {
    @DisplayName("AppWidgetSupport")
}

## Overview

Generic widget snapshot storage for app-group or UserDefaults-backed widget data.

## Ownership

`AppWidgetSupport` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Concrete widget payloads and constants stay in the app/widget target.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
