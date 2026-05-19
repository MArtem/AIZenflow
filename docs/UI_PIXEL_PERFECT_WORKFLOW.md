# UI Pixel-Perfect Workflow

## Purpose
Rules for implementing UI/design tasks in `TchopApp` from screenshots, Figma, PDFs, SVG, CSS export, or visual references.

## Mandatory Model Rule
- Use `GPT-5.5` for all UI/design tasks based on screenshots, Figma, PDF, SVG, CSS, or visual comparison.

## Source Of Truth
Use this priority order:
1. explicit user-provided numeric values
2. user-provided screenshot/reference
3. existing `TchopApp` design tokens and nearby app patterns
4. reasonable platform default only if not visible and not specified

If a screenshot and current design tokens conflict, follow the screenshot for that specific UI unless the user says to preserve tokens.

## When To Ask Before Coding
Ask before implementation if any of these are unclear:
- exact spacing/radius/font/size cannot be inferred confidently
- behavior differs between screenshot and existing app pattern
- a control appears in the design but its action is unspecified
- layout depends on content states not shown in the reference
- the requested UI would require adding business logic or new product behavior

## Implementation Rules
- Implement only what is visible or explicitly requested.
- Do not add extra UI states, actions, menus, or fallbacks.
- Use `AppTheme`, `AppSpacing`, `AppTypography`, `AppRadius`, and `AppLocalization` where they match the design.
- Literal values are allowed for pixel-specific tuning when the user gives exact px values or the screenshot requires local precision.
- Preserve accessibility semantics for interactive UI.
- Avoid heavy computation or formatting inside SwiftUI `body`.
- Avoid screen-level `private var some View` and `@ViewBuilder private func` helpers; extract dedicated `View` types.

## Verification Policy
- Do not run build/simulator/snapshot verification unless the user explicitly asks.
- If visual verification is requested, use the smallest path that proves the UI difference.

## Reporting
When reporting a UI change, state:
- what visual differences were targeted
- what files changed
- whether build/simulator verification was skipped or run
