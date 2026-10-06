# Figma and visual resources to iOS — curated copy-only route

Use after the project's local design and implementation rules. A design file is visual evidence,
not authority to invent navigation, API, persistence or other product behavior. This route does
not fetch assets, edit a project, run a simulator or claim visual fidelity by itself.

## Intake

- Identify the exact accessible file/frame/node, intended screen/component, supported devices,
  orientations and fidelity choice (`pixel-perfect`, `native-adaptive`, or `design-system-first`).
  If the design cannot be inspected, state that limitation before implementation claims.
- Record visible states/variants, component hierarchy, spacing, typography, colors, effects,
  safe-area behavior, assets and fonts. Ask about behavior-changing gaps such as unspecified
  control actions or missing states; do not infer them from pixels.
- Compare project-local semantic tokens and components. Reuse when the meaning matches; keep
  one-off exact values local. Create a new shared token/component only for demonstrated reuse or
  ownership need, not decorative abstraction.

## Native implementation review

- Translate design descriptions to native iOS layout and state ownership. Keep presentation
  separate from API/database behavior. Verify each visual resource's target and bundle owner,
  including app versus extension/package consumers; use the structural route for graph changes.
- Check layout across the supported size range and content states, Dynamic Type, VoiceOver labels,
  traits and focus order, contrast, tap targets, Reduce Motion, localization expansion and RTL
  where relevant. A screenshot alone cannot prove assistive-technology behavior.
- Preserve supplied design intent while recording intentional platform adaptations. Do not add
  unseen UI, speculative fallbacks or business actions.
- For shared components, inspect their public input/state contract and token owner at actual
  consumers. When both UIKit and SwiftUI variants exist, compare state and accessibility
  semantics as well as appearance; recommend an authorized visual-regression comparison
  against the selected design states when it would expose drift.
- For theme/token changes, inspect scoped updates, dark/high-contrast variants and invalidation
  cost without global mutable styling. Check typography baselines/wrapping and symbol availability,
  rendering modes, RTL meaning and asset size against the supported environment. Keep component
  variants/API small; a shared component must not absorb feature-specific business decisions.
- For forms, distinguish field from whole-form validation, timing, stale async results and error
  focus/announcements. Empty/offline/error components need honest state meaning, localized copy
  and a prioritized recoverable action. Standardization must not erase those distinctions.
  For a shared visual/API migration, account for usages and compatibility before removing old
  tokens; aliases are an option only for a demonstrated transition need, not an automatic layer.

## Evidence

Review the complete Swift/UI, asset, localization and project-file diff. A visual-match claim
requires an actual authorized comparison against the exact design state; supported-size and
accessibility claims require corresponding evidence. If design access, asset provenance,
simulator/device interaction or screenshots are unavailable, report `INSUFFICIENT_EVIDENCE`
for those claims. Build, export, screenshot, visual QA and Git actions remain separately
authorized by the user and project.
