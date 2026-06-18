# iOS Agent Policy

Apply this policy for production iOS work using Swift, SwiftUI, and layered architecture.

Model selection and the required response header are defined canonically in:
- [model-routing-policy.md](/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md)

## Primary Goal
- Preserve existing project conventions
- Minimize total delivery cost, not just per-call cost
- Prefer reliable implementation over impressive but unnecessary redesign

## Preserve Existing Project Patterns
Keep the existing project's:
- feature/module structure
- naming conventions
- DTO / Domain / Entity / ViewState boundaries
- dependency injection style
- navigation/coordinator pattern
- state ownership pattern
- async/concurrency conventions
- testing style

## iOS Escalation Signals
Even if the general routing baseline would allow a cheaper model, bias upward for iOS work when the task involves:
- `@MainActor` correctness
- actor isolation
- `Task` cancellation
- repository/database threading rules
- pagination strategy
- cache invalidation
- sync conflict handling
- complex screen state
- reusable screen/component architecture
- DTO/Entity leakage risk into UI

## Figma Rule
- If the screen maps directly to the existing design system and established patterns, prefer `GPT-5.4`
- If the screen requires interpretation, decomposition, token extraction, or architecture decisions, prefer `GPT-5.5`

## Working Rules
- Inspect only relevant files
- Avoid whole-project scanning unless needed
- Make focused changes
- Avoid broad refactors unless requested
- Run the smallest useful build/test
- Inspect only relevant compiler/test errors
- Do not repeat the same build-fix loop blindly
- After 2 failed fix attempts, escalate internally or flag for human review
- Inside SwiftUI `View` types, do not create convenience `View` subtrees as:
  - `private var foo: some View`
  - `@ViewBuilder private func foo(...) -> some View`
- If a screen needs a reusable subtree or renderer branch, extract a dedicated `View` type instead.
- If composition becomes more complex than one extracted `View` can comfortably express, use a dedicated `Builder`/`Factory`/renderer type rather than stacking view-returning helpers inside the screen.
- Treat unnecessary view invalidation/redraw risk as a high-priority concern. Prefer explicit extracted subviews with narrow state/input surfaces so render boundaries are visible and reviewable.
