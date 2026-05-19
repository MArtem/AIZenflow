# iOS Engineering Rules

## Purpose
This file contains project-specific iOS overlay rules for this worktree.

It is not the global iOS policy.
Global assistant iOS/model-routing rules live in:
- [/Users/Artem/.zenflow/assistant/AGENTS.md](/Users/Artem/.zenflow/assistant/AGENTS.md)
- [/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md](/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md)
- [/Users/Artem/.zenflow/assistant/docs/ios-agent-policy.md](/Users/Artem/.zenflow/assistant/docs/ios-agent-policy.md)

## Read Together With
- [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

## Project-Specific Rules
- For coding-task responses in this task thread, include the active model header at the top:
  - `Model: GPT-5.3-codex` / `Model: GPT-5.4` / `Model: GPT-5.5`
  - Follow the canonical model-selection policy in `/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md`.
- Current user override for this worktree/task: use and report `GPT-5.5` for all work unless the user explicitly changes the model again. This task-local override wins over cheaper-model defaults in the general model-routing policy.
- Do not add speculative UI, speculative logic, or fallback flows that were not explicitly requested.
- Prefer the minimum working implementation that matches the clarified product contract.
- Optimize for final product correctness over implementation speed. If requirements, state behavior, lifecycle, platform behavior, or ownership are unclear, stop and ask instead of guessing.
- Treat architecture as the highest-cost decision layer. A wrong structural decision is more dangerous than a temporary UI flaw or a local implementation detail because it propagates into multiple dependent layers and becomes expensive to unwind.
- If architecture, ownership, extension boundaries, persistence shape, or long-lived state flow are unclear, stop and resolve that first. Do not patch over architectural uncertainty with implementation glue.
- After architecture, the next constant rule is to avoid overengineering. Do not build abstractions, flows, or flexibility that are not justified by the current product contract.
- Re-check for simplification constantly. If something can be made materially simpler without reducing correctness, maintainability, or product fit, prefer the simpler design.
- Treat temporary/prototype code as temporary. Before any feature is treated as production-ready, run a separate production-hardening pass instead of silently carrying prototype assumptions forward.
- View models must use one consistent model-level interaction pattern across the project:
  - `@MainActor`
  - `@Observable`
  - one explicit source-of-truth state container per model, either `state: SomeState` or one clearly grouped state object for very small models
  - public API exposed as explicit intent methods like `refresh()`, `publish()`, `selectChannel(id:)`, `toggleLike(...)`
  - do not use a project-wide generic `send(action)` dispatcher pattern as the default
  - action enums are allowed only when they are part of a real domain contract or internal state machine, not as mandatory UI event buses
- Keep warning baseline at zero.
- Preserve accessibility semantics for interactive UI and hide decorative-only elements from accessibility.
- Keep previews updated when a renderable SwiftUI view API or UI contract changes.
- Do not create view models inside feature view initializers.
- Inside SwiftUI `View` types, do not create convenience `View` subtrees as:
  - `private var foo: some View`
  - `@ViewBuilder private func foo(...) -> some View`
- Extract a dedicated `View` type instead.
- If screen or component assembly becomes complex, use a dedicated `Builder` or `Factory` type instead of stacking local view-returning helpers.
- Treat unnecessary SwiftUI invalidation/redraw risk as a high-priority concern. Prefer explicit extracted subviews with narrow inputs and clear state ownership so render boundaries stay visible and reviewable.

## Documentation Rule
When asked to add a new rule or document, first propose placement using:
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

Then write it to the canonical location instead of duplicating it across multiple files.

## Archive
Verbose historical versions of this rules file are kept only in:
- [.zenflow/tasks/new-task-be0b/archive/ios-engineering-rules.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/ios-engineering-rules.legacy.md)
