# TchopApp Knowledge Base

## Purpose
Project-specific rules, contracts, paths, entities, and task context for `TchopApp`.

Anything in this folder may mention concrete app files, app models, current worktree paths, feed/composer contracts, Tchop-specific design tokens, persistence assumptions, or current task/user overrides.

## Current Active Sources
This folder indexes the current active TchopApp docs rather than replacing them immediately. Existing links remain stable.

### Project / Task Rules
- `../../CURRENT_USER_OVERRIDES.md`
- `../../AGENT_RULES.md`
- `../../WORK_CONTINUITY.md`
- `../../../.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `../../../.zenflow/tasks/new-task-be0b/services-engineering-rules.md`

### TchopApp Product / Architecture Docs
- `../../../PROJECT_DOCUMENTATION.md`
- `../../../PROJECT_HEALTH.md`
- `../../LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `../../../.codex/skills/tchop-feed-cards/references/feed-card-contract.md`
- `../../UI_PIXEL_PERFECT_WORKFLOW.md`

### Current Task State
- `../../../.zenflow/tasks/new-task-be0b/handoff.md`
- `../../../.zenflow/tasks/new-task-be0b/plan.md`

## Placement Rule
Put new TchopApp-specific information here or in the canonical active doc referenced here when it mentions:
- concrete TchopApp file paths
- app models/entities such as feed cards, channels, composer drafts, media content
- TchopApp-specific UI values or screenshot-derived dimensions
- SwiftData/feed persistence decisions for this app
- current worktree/task/user overrides

Do not put reusable cross-project prompt presets here; those belong in `../global/`.
