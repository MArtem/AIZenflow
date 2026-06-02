# ``TchopAppleAuthentication``

@Metadata {
    @DisplayName("TchopAppleAuthentication")
}

## Overview

Normalized Sign in with Apple authorization and credential-state contracts.

## Ownership

`TchopAppleAuthentication` is reusable infrastructure. It must expose mechanisms and stable contracts, not app-specific product decisions.

## Boundary Rules

- Server verification and app session policy stay in the app/auth layer.

## Testing

Package-level tests for this module or its adapters must live under `Tests/` in the same Swift package so the module can be moved with its test coverage.
