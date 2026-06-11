# AppFeatureFlags Package Contract

## Standalone guarantee

`AppFeatureFlags` must remain a single-folder standalone package.

It must not contain:

- sibling path dependencies;
- imports of other SDK packages;
- product-specific feature keys;
- UI strings;
- analytics/networking/configuration dependencies.

## Public responsibility

This package owns only generic feature flag evaluation primitives:

- keys;
- values;
- snapshots;
- local overrides;
- percentage rollout;
- weighted variants;
- evaluation diagnostics.
- validation of snapshots before runtime activation;
- UserDefaults-backed persistence for snapshots and local overrides.

## Integration policy

Remote configuration, analytics, logging, diagnostics, and session-specific flag contexts must be connected through optional integration helpers or app-level composition.

## Privacy policy

Evaluation diagnostics must not include raw user data. `FeatureFlagContext.stableIdentifier` is used only as an input for stable bucketing and should not be exported from this package.

## Validation policy

- Empty keys are rejected for local overrides and snapshots.
- Snapshot dictionary keys must match their contained `FeatureFlag.key`.
- Rollout percentages outside `0...100` are rejected instead of silently clamped.
- Host apps must provide a stable identifier when anonymous users should be distributed across rollout cohorts.


## Iteration Standards Hardening

This package follows the hardened single-folder standalone rules:

- DocC is source-owned: `Sources/AppFeatureFlags/Documentation.docc/`.
- Verification uses an external SwiftPM scratch path and must not create `.build` or `.swiftpm` inside the package folder.
- The package has no sibling path dependencies and no imports of sibling SDK modules.
- Multi-target package layouts are allowed only when every target, test, fixture, script, and documentation file remains inside this package folder.
- Swift source and package metadata must not contain unresolved template placeholders.
