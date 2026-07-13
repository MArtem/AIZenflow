# New Project Start Contract

## Purpose
Every new project, task, or worktree starts from the highest available engineering baseline unless the user explicitly approves a narrower local exception.

This contract is a preflight gate. Complete it before project creation, first implementation, documentation migration, package adoption, or task handoff.

## Required Fields
- Project/App name:
- Task ID:
- Worktree path:
- Repository URL or local-only reason:
- App-specific vault path: `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/`
- Task vault path: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/`
- Reusable baseline path: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/`
- Sandbox root:
- Build/test policy:
- Model routing classification:
- Approved local exceptions:
- Explicit non-goals:

## Mandatory Startup Gates
Before implementation:

1. Run or satisfy `scripts/check_bootstrap_contract.py`.
2. Read `./docs/DOCUMENT_BOUNDARY_STANDARD.md`.
3. Read `./docs/SOURCE_OF_TRUTH_MAP.md`.
4. Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md`.
5. Confirm app-specific docs are not copied from another app.
6. Confirm local exceptions are recorded only in app/task docs.

## Highest-Quality Default
All projects use the strongest reusable engineering rules by default:

- production-shaped file structure from the first screen;
- composition root and explicit dependency ownership;
- coordinator/router navigation when the app has navigation;
- feature state owners above views;
- explicit ViewModel intent methods;
- accessibility, localization, privacy, error, loading, empty, and verification posture;
- evidence-based completion reports.

Small, internal, educational, demo, prototype, or test-only status may reduce feature scope and verification cost. It must not reduce architecture quality, state ownership, or maintainability.

## Completion
The project start contract is satisfied only when:

- bootstrap contract passes or remaining risks are recorded;
- documentation boundary is active;
- source-of-truth locations are known;
- app-specific vault area exists or is intentionally deferred;
- first task plan/handoff points to the correct docs.
