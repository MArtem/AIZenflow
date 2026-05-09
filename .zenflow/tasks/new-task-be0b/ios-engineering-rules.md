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
- Do not add speculative UI, speculative logic, or fallback flows that were not explicitly requested.
- Prefer the minimum working implementation that matches the clarified product contract.
- Optimize for final product correctness over implementation speed. If requirements, state behavior, lifecycle, platform behavior, or ownership are unclear, stop and ask instead of guessing.
- Treat architecture as the highest-cost decision layer. A wrong structural decision is more dangerous than a temporary UI flaw or a local implementation detail because it propagates into multiple dependent layers and becomes expensive to unwind.
- If architecture, ownership, extension boundaries, persistence shape, or long-lived state flow are unclear, stop and resolve that first. Do not patch over architectural uncertainty with implementation glue.
- Treat temporary/prototype code as temporary. Before any feature is treated as production-ready, run a separate production-hardening pass instead of silently carrying prototype assumptions forward.
- Keep warning baseline at zero.
- Preserve accessibility semantics for interactive UI and hide decorative-only elements from accessibility.
- Keep previews updated when a renderable SwiftUI view API or UI contract changes.
- Do not create view models inside feature view initializers.
- Do not use local helper/computed properties or local `@ViewBuilder` functions that return `View`/`some View` inside screens as a convenience abstraction.
- If screen or component assembly becomes complex, use a dedicated `Builder` or `Factory` type instead of stacking local view-returning helpers.

## Documentation Rule
When asked to add a new rule or document, first propose placement using:
- [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)

Then write it to the canonical location instead of duplicating it across multiple files.

## Archive
Verbose historical versions of this rules file are kept only in:
- [.zenflow/tasks/new-task-be0b/archive/ios-engineering-rules.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/ios-engineering-rules.legacy.md)
