# source-app Knowledge Base

## Purpose
Project-specific rules, contracts, paths, entities, and task context for `source-app`.

Anything in this folder may mention concrete app files, app models, current worktree paths, feed/composer contracts, source-app-specific design tokens, persistence assumptions, or current task/user overrides.

## Current Active Sources
This folder indexes the current active source-app docs rather than replacing them immediately. Existing links remain stable.

### Project / Task Rules
- `../../CURRENT_USER_OVERRIDES.md`
- `../../AGENT_RULES.md`
- `../../WORK_CONTINUITY.md`
- `../../../.zenflow/tasks/new-task-be0b/handoff.md`
- `../../../.zenflow/tasks/new-task-be0b/plan.md`

### Preserved Historical Rules
The former task-specific iOS and services overlays remain byte-identical in the recovery area.
They are non-authoritative historical material; current work follows the routed baseline and task
state above.

- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/Tchop/legacy-reference/TchopApp/baseline/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/Tchop/legacy-reference/TchopApp/baseline/.zenflow/tasks/new-task-be0b/services-engineering-rules.md`

### Current Replacements
Their reusable semantics are now covered by the active routed standards rather than a duplicate
task overlay:

- iOS architecture, ViewModel intents, and SwiftUI rendering:
  `../../AGENT_RULES.md`, `../../IOS_MVVM_INTENT_API_STANDARD.md`, and
  `../../IOS_UI_STATE_RENDERING_STANDARD.md`.
- Services, persistence, and package ownership:
  `../../../PROJECT_HEALTH.md`, `../../PACKAGES_AND_MANAGERS.md`, and
  `../../IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`.

### source-app Product / Architecture Docs
- `../../../PROJECT_DOCUMENTATION.md`
- `../../../PROJECT_HEALTH.md`
- `../../LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `../../../.codex/skills/ios-content-cards/references/feed-card-contract.md`
- `../../UI_PIXEL_PERFECT_WORKFLOW.md`

## Placement Rule
Put new source-app-specific information here or in the canonical active doc referenced here when it mentions:
- concrete source-app file paths
- app models/entities such as feed cards, channels, composer drafts, media content
- source-app-specific UI values or screenshot-derived dimensions
- SwiftData/feed persistence decisions for this app
- current worktree/task/user overrides

Do not put reusable cross-project prompt presets here; those belong in `../global/`.
