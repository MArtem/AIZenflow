# ``AppPushNotifications``

@Metadata {
    @DisplayName("AppPushNotifications")
}

## Overview

Push token/state/payload contracts and event collector boundaries.

## Ownership

`AppPushNotifications` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Feature routing of payloads stays in the app layer.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
