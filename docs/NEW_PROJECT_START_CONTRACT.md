# New Project Start Contract

## Purpose
Every new project, task, or worktree starts from the highest available engineering baseline unless the user explicitly approves a narrower local exception.

This contract is a preflight gate. Complete it before project creation, first implementation, documentation migration, package adoption, or task handoff.

## Codex App Bootstrap Responsibility
When a new task, project, worktree, Xcode project, or app is created from Codex app, the assistant must create and maintain the documentation structure automatically. The user does not need to explicitly say "create plan/handoff/app-specific docs" each time.

For every new iOS/Xcode Git repository created through Codex, bootstrap is a blocking first action,
not later cleanup. When Codex first encounters an externally created iOS/Xcode repository without
the governed bootstrap, stop project work until bootstrap completes or the user records an explicit
owned deferral with risk and revisit condition. A repository may not claim global quality adoption
merely because another worktree or repository has it.

Required behavior:
- create the repository-root `AGENTS.md` from the current template with the stable
  `AIZENFLOW_GLOBAL_RULES_BOOTSTRAP_V1` entry before any project action, so global rules load
  without a user reminder;
- install the governed root `GLOBAL_RULES_PORTABLE_SNAPSHOT.md` portable snapshot so a clean clone can
  continue under tracked rules while explicitly reporting an unavailable canonical checkout;
- create or update the task plan and handoff under `./.zenflow/tasks/<TaskId>/` when the current worktree owns the task state;
- create or update the durable task recovery area under `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/<TaskId>/` when the task needs durable recovery outside the current worktree;
- create or update the app-specific vault root under `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/<AppName>/` for every app or Xcode project that has its own product decisions, architecture, history, ADRs, local rules, or exceptions;
- keep reusable rules in `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/` and never mix app-specific decisions into reusable docs without explicit promotion approval;
- continue maintaining the relevant plan, handoff, app-specific docs, and task recovery notes throughout the project lifecycle.
- install a versioned project quality profile, thin local launcher, and `workflow_dispatch`-only
  GitHub workflow that consume the canonical quality engine without copying reusable policy;
- record quality-control adoption plus testing, feature-flag, release, privacy, and other conditional
  applicability decisions; and
- pin the quality engine by reviewed release/SHA and keep project facts and local exceptions in the
  consumer repository rather than in reusable defaults.

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
- Secret storage root or local-only reason for no secrets: prefer `/Users/Artem/.zenflow/secrets/<ProjectName>/` (agent-denied during normal work)
- Secret placeholder/example config path:
- `.gitignore` secret baseline applied: yes/no
- Sandbox root:
- Build/test policy:
- Model routing classification:
- Quality-control adoption record and compatibility path from `./docs/STATIC_GATE_ADOPTION.md`:
- Versioned project quality profile path:
- Thin local quality launcher path:
- Manual `workflow_dispatch` workflow path:
- Pinned quality-engine release/SHA:
- Test, feature-flag, release, privacy, and capability applicability records:
- Approved local exceptions:
- Explicit non-goals:

## Mandatory Startup Gates
Before implementation:

1. Confirm the repository-root `AGENTS.md` contains `AIZENFLOW_GLOBAL_RULES_BOOTSTRAP_V1` and
   directly loads
   `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md`.
2. Confirm `./GLOBAL_RULES_PORTABLE_SNAPSHOT.md` contains
   `AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1`.
3. Run or satisfy `scripts/check_bootstrap_contract.py`.
4. Read `./docs/DOCUMENT_BOUNDARY_STANDARD.md`.
5. Read `./docs/SOURCE_OF_TRUTH_MAP.md`.
6. Read `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` and select only task-relevant bootstrap, app, package, prompt, skill, and deep-reference docs.
7. Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md`.
8. Apply `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md`.
9. Confirm `.gitignore` covers local secret files, signing material, private configs, sensitive logs, traces, and exports.
10. Confirm real secrets are stored outside the AI-readable workspace or intentionally deferred with a documented reason.
11. Confirm app-specific docs are not copied from another app.
12. Confirm local exceptions are recorded only in app/task docs.
13. Confirm task plan/handoff docs exist or are intentionally deferred with a reason.
14. Confirm every Xcode project/app in scope has its own app-specific docs boundary.
15. Confirm reusable/global documentation changes are committed and pushed to `MArtem/AIZenflowDocumentation`.
16. Install or explicitly reference the reusable `IOS_PR_REVIEW_TEMPLATE.md` risk card in the
    project's PR/review workflow, and record any equivalent local form as a documented overlay.
17. Complete `./docs/STATIC_GATE_ADOPTION.md`: define the project-specific source membership and
    deterministic rules/remediation, or record an explicit deferral with owner and revisit
    condition. A copied generic gate alone is not adoption and may not claim whole-target coverage.
18. Install and validate the versioned project quality profile: project/workspace, shared schemes,
    targets, source-membership authority, configurations, destinations, test plans, permissions,
    sandbox/cache roots, applicability, and pinned engine identity.
19. Install a thin local launcher and a GitHub workflow whose reusable trigger is
    `workflow_dispatch` only. Automatic PR/push/schedule triggers require a separately approved
    local exception.
20. Confirm the local and GitHub launchers execute the same engine/profile contract and cannot
    silently substitute missing checks with PASS.
21. Record whether tests, snapshot/UI suites, feature flags, release/archive/signing, privacy,
    observability, and extensions/capabilities are applicable, deferred, or unavailable, with owner
    and revisit condition.
22. Install or reference the PR form that records explicit PR authority, mandatory internal
    Exhaustive candidate/range review, exact-SHA receipt, user-triggered GitHub check, and separate
    user-triggered external Codex Review.

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

- the repository-root `AGENTS.md` activates the canonical global bootstrap without a user prompt;
- the governed root portable snapshot exists and reports fallback use instead of current-canonical success;
- bootstrap contract passes or remaining risks are recorded;
- documentation boundary is active;
- source-of-truth locations are known;
- task-specific docs were selected through `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` instead of loading unrelated library material;
- secret handling standard is applied;
- `.gitignore` or equivalent secret ignore baseline exists;
- real secrets are outside normal AI-readable workspace files or documented as an explicit security-intake/remediation risk;
- task plan/handoff exists and points to the correct docs, or the intentional deferral is recorded;
- app-specific vault area exists for every app/Xcode project in scope, or the intentional deferral is recorded;
- the PR risk card is installed or explicitly referenced in the review workflow, or its deferral is recorded;
- `STATIC_GATE_ADOPTION.md` records completed adoption, or its explicit deferral with owner and
  revisit condition;
- the versioned profile, thin local launcher, and `workflow_dispatch`-only GitHub workflow exist and
  validate the same pinned engine contract, or an explicit owned deferral blocks adoption claims;
- conditional test, feature-flag, release, privacy, observability, and capability applicability is
  recorded rather than silently omitted;
- the PR form separates readiness, user PR authority, internal Exhaustive review, exact-SHA
  evidence, GitHub manual checks, and external user-triggered review;
- any reusable/global docs touched during bootstrap are pushed to `MArtem/AIZenflowDocumentation`.
