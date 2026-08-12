# New Project Start Contract

## Purpose
Every new project, task, or worktree starts from the highest available engineering baseline unless the user explicitly approves a narrower local exception.

This contract is a preflight gate. Complete it before project creation, first implementation, documentation migration, package adoption, or task handoff.

## Codex App Bootstrap Responsibility
When a new task, project, worktree, Xcode project, or app is created from Codex app, the assistant must create and maintain the documentation structure automatically. The user does not need to explicitly say "create plan/handoff/app-specific docs" each time.

Required behavior:
- create or update the task plan and handoff under `./.zenflow/tasks/<TaskId>/` when the current worktree owns the task state;
- create or update the durable task recovery area under `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/` when the task needs durable recovery outside the current worktree;
- create or update the app-specific vault root under `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/` for every app or Xcode project that has its own product decisions, architecture, history, ADRs, local rules, or exceptions;
- keep reusable rules in `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/` and never mix app-specific decisions into reusable docs without explicit promotion approval;
- continue maintaining the relevant plan, handoff, app-specific docs, and task recovery notes throughout the project lifecycle.

If one task creates or modifies multiple Xcode projects/apps, each project/app must have a separate app-specific documentation boundary. Do not merge their product plans, histories, ADRs, local exceptions, bundle decisions, architecture decisions, or runtime assumptions into one shared app folder merely because the work happened in one Codex task.

## Required Fields
- Project/App name:
- Task ID:
- Worktree path:
- Repository URL or local-only reason:
- Global documentation repository: `https://github.com/MArtem/AIZenflowDocumentation`
- Global documentation local checkout: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- App-specific vault path: `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/`
- Task vault path: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/`
- Reusable baseline path: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/`
- If multiple Xcode projects/apps are in scope: separate app-specific vault path for each project/app:
- Secret storage root or local-only reason for no secrets: prefer `/Users/Artem/.zenflow-secrets/<ProjectName>/`
- Secret placeholder/example config path:
- `.gitignore` secret baseline applied: yes/no
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
4. Read `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` and select only task-relevant bootstrap, app, package, prompt, skill, and deep-reference docs.
5. Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md`.
6. Apply `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md`.
7. Confirm `.gitignore` covers local secret files, signing material, private configs, sensitive logs, traces, and exports.
8. Confirm real secrets are stored outside the AI-readable workspace or intentionally deferred with a documented reason.
9. Confirm app-specific docs are not copied from another app.
10. Confirm local exceptions are recorded only in app/task docs.
11. Confirm task plan/handoff docs exist or are intentionally deferred with a reason.
12. Confirm every Xcode project/app in scope has its own app-specific docs boundary.
13. Confirm reusable/global documentation changes are committed and pushed to `MArtem/AIZenflowDocumentation`.
14. Install or explicitly reference the reusable `IOS_PR_REVIEW_TEMPLATE.md` risk card in the
    project's PR/review workflow, and record any equivalent local form as a documented overlay.

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
- task-specific docs were selected through `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` instead of loading unrelated library material;
- secret handling standard is applied;
- `.gitignore` or equivalent secret ignore baseline exists;
- real secrets are outside normal AI-readable workspace files or documented as an explicit security-intake/remediation risk;
- task plan/handoff exists and points to the correct docs, or the intentional deferral is recorded;
- app-specific vault area exists for every app/Xcode project in scope, or the intentional deferral is recorded;
- any reusable/global docs touched during bootstrap are pushed to `MArtem/AIZenflowDocumentation`.
