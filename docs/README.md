# Documentation Map

## Purpose
This file is the documentation entry point for `TchopApp`.

Use it to answer two questions quickly:
- what should be read first
- where new information should be stored

Do not read archived files by default.
Use archives only when current docs are insufficient.

## Default Read Order
For normal coding work, read in this order:

1. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
2. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
3. [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md) if testing or verification is relevant
4. [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md) if task-resume context is relevant
5. [ios-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md) and [services-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/services-engineering-rules.md) for project overlays
6. [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md) only when package integration, extraction, or reuse guidance is relevant
7. [docs/WORK_CONTINUITY.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/WORK_CONTINUITY.md) when work must survive loss of the current Zenflow task/thread
8. [docs/SHARE_EXTENSION_VALIDATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/SHARE_EXTENSION_VALIDATION.md) when validating or continuing share-extension rollout

Global assistant policies live outside the repo and are not duplicated here:
- [/Users/Artem/.zenflow/assistant/AGENTS.md](/Users/Artem/.zenflow/assistant/AGENTS.md)
- [/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md](/Users/Artem/.zenflow/assistant/docs/model-routing-policy.md)
- [/Users/Artem/.zenflow/assistant/docs/ios-agent-policy.md](/Users/Artem/.zenflow/assistant/docs/ios-agent-policy.md)

Project-local optional skills live in:
- [.codex/skills/tchop-feed-cards/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-feed-cards/SKILL.md)
- [.codex/skills/tchop-packages/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-packages/SKILL.md)

These are not part of the always-on read path. Use them only when the task matches their domain.

## Canonical Document Roles
### [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
Stable repo-level onboarding and architecture baseline.

Put here:
- what the app is
- how it is structured
- stable runtime rules
- stable architecture and ownership boundaries

Do not put here:
- long task history
- step-by-step implementation logs
- temporary debugging notes

### [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
Package and manager inventory.

Put here:
- reusable package ownership
- app-vs-package boundaries
- extraction policy
- package-root rules

### [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
Operational testing and verification policy.

Put here:
- verification levels
- trace commands
- when to use build/test/UI/runtime checks
- test reporting format

### [APPLE_SIGN_IN_SETUP.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/APPLE_SIGN_IN_SETUP.md)
External service setup guide.

Use dedicated root-level setup docs like this for:
- third-party auth setup
- entitlement/capability setup
- environment configuration that developers may need outside normal coding flow

### [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
Reusable package and manager usage guide.

Put here:
- what each reusable package/manager is for
- how it should be integrated
- what belongs in package vs app
- reuse notes for other projects

Do not put here:
- current task progress
- global assistant behavior
- transient debugging notes

### [docs/WORK_CONTINUITY.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/WORK_CONTINUITY.md)
Durable repo-level continuity state for long-running work that must survive loss of the current Zenflow task/thread.

Put here:
- the current long-running epic state
- what is already restored or completed
- the current functional contract that must not be rediscovered
- the next high-value continuation points
- the key files to reopen first

Do not put here:
- every small intermediate step
- temporary speculation
- global assistant rules

### [docs/SHARE_EXTENSION_VALIDATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/SHARE_EXTENSION_VALIDATION.md)
Runtime validation matrix for share-extension rollout.

Put here:
- share flow scenario coverage
- manual validation checklist
- explicit unsupported or rejected cases
- remaining share-extension runtime validation

### [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md)
Current task resume state.

Put here:
- current task status
- what is done
- what remains
- current risks
- next recommended steps

### [plan.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/plan.md)
Current active execution plan only.

Put here:
- the next few concrete steps for the current task

Do not use it as:
- a permanent history file
- an architectural encyclopedia

### [ios-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md)
Project-specific iOS overlay rules.

Put here:
- local iOS constraints that are narrower than the global assistant policy
- project-specific SwiftUI, UX, and code-organization constraints

### [services-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/services-engineering-rules.md)
Project-specific services and infrastructure overlay rules.

Put here:
- local package, sync, and persistence rules that are narrower than repo-wide docs
- service-layer constraints for this project

## Placement Rules For New Information
Before adding a new rule, skill note, or document, classify it first:

- stable repo architecture or runtime baseline:
  place it in [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- package or manager ownership rule:
  place it in [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- verification or testing workflow:
  place it in [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
- external setup or integration steps:
  create or update a dedicated root-level setup document
- reusable package or manager usage guide:
  place it in [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
- continuity-critical state that must survive loss of the current Zenflow task:
  place it in [docs/WORK_CONTINUITY.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/WORK_CONTINUITY.md)
- share-extension runtime validation status:
  place it in [docs/SHARE_EXTENSION_VALIDATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/SHARE_EXTENSION_VALIDATION.md)
- current task status or resume context:
  place it in [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md)
- current task next steps:
  place it in [plan.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/plan.md)
- project-specific iOS coding constraint:
  place it in [ios-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/ios-engineering-rules.md)
- project-specific services or package constraint:
  place it in [services-engineering-rules.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/services-engineering-rules.md)
- long obsolete history that should not be read by default:
  place it under `docs/archive/` or `.zenflow/tasks/new-task-be0b/archive/`

## Hierarchy Of Truth
If multiple sources overlap or conflict, prefer them in this order:

1. global assistant policy
2. canonical project docs
3. project overlay rules
4. current task docs
5. archives

## Working Rule
When you ask to add a new rule, skill note, or document, I should first propose the correct placement using this map, then write it there after alignment.
