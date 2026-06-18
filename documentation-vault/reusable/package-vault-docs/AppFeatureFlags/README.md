# AppFeatureFlags

`AppFeatureFlags` is a 100% single-folder standalone Swift package for app-independent feature flag evaluation.

## Purpose

Use this package to evaluate:

- boolean feature toggles;
- typed flag values;
- local debug overrides;
- percentage rollouts;
- weighted experiment variants;
- diagnostic evaluation results.

## What belongs here

- Generic feature flag keys and values.
- Snapshot and override stores.
- Rollout bucketing.
- Variant selection.
- Test-friendly in-memory implementations.
- UserDefaults-backed snapshot and override persistence.
- Snapshot validation before runtime activation.

## What must not belong here

- Product-specific flag names like `news.newLayout`.
- Analytics integration.
- Remote config integration.
- Networking integration.
- UI copy or localization strings.

Cross-package composition belongs in optional `IntegrationHelpers`.

## Example

```swift
let key = FeatureFlagKey(namespace: "feed", name: "new-card")
let manager = DefaultFeatureFlagManager()

try await manager.updateSnapshot(
    FeatureFlagSnapshot(flags: [
        key: FeatureFlag(
            key: key,
            isEnabled: true,
            value: .bool(true),
            rolloutPercentage: 25
        )
    ])
)

let enabled = await manager.isEnabled(
    key,
    default: false,
    context: FeatureFlagContext(stableIdentifier: "user-123")
)
```

## Verification

```bash
./Scripts/verify_package.sh
```

The script runs regular tests and strict-concurrency checks.

## Production notes

- Invalid rollout percentages are rejected instead of silently clamped.
- Snapshot dictionary keys must match each contained flag key.
- Anonymous contexts intentionally share one `"anonymous"` rollout bucket; host apps that need per-install anonymous rollout should pass a stable app-owned identifier.
- Diagnostics and string descriptions avoid exposing raw flag string values, but host apps should still avoid sending feature keys to external telemetry unless explicitly approved.
