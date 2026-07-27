# AppFeatureFlags

Evaluate feature flags, rollout percentages, local overrides, and weighted variants without depending on any app-specific feature names.

## Overview

`AppFeatureFlags` is a single-folder standalone package. It provides generic feature flag contracts and a default actor-based manager.

Use it for:

- runtime feature toggles;
- kill switches;
- local debug overrides;
- percentage rollouts;
- weighted variants;
- testable feature-flag evaluation.
- UserDefaults-backed persistence for snapshots and local overrides.
- validation for rollout percentages and snapshot key consistency.

Do not put product-specific keys or copy inside this package. Define app flags in the host app layer.
