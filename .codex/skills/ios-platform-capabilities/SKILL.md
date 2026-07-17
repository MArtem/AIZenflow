---
name: ios-platform-capabilities
description: Use for iPhone/iPad capabilities and extensions involving notifications, background tasks, widgets, Live Activities, App Intents, Siri, Shortcuts, Spotlight, associated domains, App Groups, share or document extensions, entitlements, provisioning, and system-service availability.
---

# iOS Platform Capabilities

## Required Context
Read:

- `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`
- `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`
- `./docs/knowledge/global/ios/APPLE_CAPABILITIES_AND_EXTENSIONS.md`
- framework-specific official documentation for the capability

## Workflow
1. Define product behavior, supported iPhone/iPad versions, and fallback.
2. Inventory framework, target, entitlement, provisioning, identifier, associated domain, App Group, account, server, and privacy prerequisites.
3. Assign app/extension/shared-data ownership and lifecycle.
4. Classify what can be proven statically, in Simulator, on physical device, across devices/services, and after distribution.
5. Compare native capability alternatives and explain UX, scheduling, privacy, reliability, and maintenance tradeoffs.
6. Verify stale/missing data, denied permission, disabled capability, relaunch, and system-controlled scheduling.

## Guardrails
- Compiling an API does not prove capability configuration.
- Push and background scheduling are hints, not guaranteed execution.
- Extension targets must remain bounded and independently lifecycle-safe.
- External routes and payloads are untrusted input.
- Do not simulate device/service evidence and label it real.

## Output
Report prerequisites, target/data ownership, lifecycle, alternatives, capability matrix, evidence classes, and blocked external requirements.
