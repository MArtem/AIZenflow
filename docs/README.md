# Documentation Map

## Purpose
Entry point for project docs: what to read first and where to place new information.

- Read active docs first.
- Use archives only when active docs are insufficient.

## Default Read Order
1. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
2. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
3. [docs/AGENT_RULES.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/AGENT_RULES.md)
4. [docs/WORK_CONTINUITY.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/WORK_CONTINUITY.md)
5. Task docs: [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md), [plan.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/plan.md), task rules
6. Optional by task scope:
   - [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
   - [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
   - [docs/IOS_ARCHITECTURE_REFERENCE.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/IOS_ARCHITECTURE_REFERENCE.md)
   - [docs/SHARE_EXTENSION_VALIDATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/SHARE_EXTENSION_VALIDATION.md)

## One-Time Bootstrap After Chat Reset
On new chat/context reset, read once:
1. this file
2. `PROJECT_DOCUMENTATION.md`
3. `PROJECT_HEALTH.md`
4. `docs/WORK_CONTINUITY.md`
5. current task docs (`handoff.md`, `plan.md`, task rules)

Re-read full stack only if architecture/rules/phase changed or continuity is unclear.

## Canonical Document Roles
- **PROJECT_DOCUMENTATION.md**: stable app architecture and runtime baseline.
- **PROJECT_HEALTH.md**: package/manager ownership boundaries.
- **TESTING_INSTRUCTIONS.md**: verification workflow and levels.
- **docs/AGENT_RULES.md**: short mandatory implementation guardrails.
- **docs/IOS_ARCHITECTURE_REFERENCE.md**: architecture handbook pointer + usage notes (guidance, not mandate).
- **docs/PACKAGES_AND_MANAGERS.md**: reusable package/manager integration guide.
- **docs/WORK_CONTINUITY.md**: durable resume state and universal transition prompt.
- **docs/SHARE_EXTENSION_VALIDATION.md**: share-extension validation matrix.
- **.zenflow/tasks/.../handoff.md**: current task status/resume context.
- **.zenflow/tasks/.../plan.md**: current execution plan only.
- **task overlay rules** (`ios-engineering-rules.md`, `services-engineering-rules.md`): local constraints for this task.

## Placement Rules For New Information
- **Architecture/runtime baseline** → `PROJECT_DOCUMENTATION.md`
- **Package/manager ownership** → `PROJECT_HEALTH.md`
- **Verification workflow** → `TESTING_INSTRUCTIONS.md`
- **Short implementation guardrails** → `docs/AGENT_RULES.md`
- **Architecture-reference usage notes** → `docs/IOS_ARCHITECTURE_REFERENCE.md`
- **Package integration/reuse guide** → `docs/PACKAGES_AND_MANAGERS.md`
- **Durable continuity + transition prompt** → `docs/WORK_CONTINUITY.md`
- **Share-extension validation status** → `docs/SHARE_EXTENSION_VALIDATION.md`
- **Current task state** → `handoff.md`
- **Current task plan/steps** → `plan.md`
- **Obsolete history** → `docs/archive/` or `.zenflow/tasks/.../archive/`

## Hierarchy Of Truth
1. Global assistant policy
2. Canonical project docs
3. Task overlay rules
4. Current task docs
5. Archives
