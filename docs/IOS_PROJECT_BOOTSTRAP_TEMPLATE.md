# iOS Project Bootstrap Template

## Purpose
How to install the governed iOS/Xcode consumer layer into a new project without copying or forking
reusable policy.

## Required Project Decisions
Before coding, define:
- app purpose and critical user journeys
- supported iOS versions/devices
- architecture style and module boundaries
- environment model: dev/staging/prod
- persistence/source-of-truth model
- API/backend contract ownership
- observability/crash/analytics tools
- security/privacy classification
- release/signing/TestFlight process
- QA/manual validation process
- risk/debt ownership

## Required Consumer Surface

- repository-root `AGENTS.md` that activates the canonical global bootstrap;
- governed root `GLOBAL_RULES_PORTABLE_SNAPSHOT.md` fallback;
- project/app documentation boundary and task state where applicable;
- versioned project quality profile with authoritative Xcode project/workspace, shared schemes,
  targets, source membership, configurations, destinations, test plans, permissions, and
  applicability facts;
- thin local quality launcher and a `workflow_dispatch`-only GitHub workflow that invoke the same
  pinned canonical engine/profile contract;
- project-local copy or documented reference to `./docs/IOS_PR_REVIEW_TEMPLATE.md`; and
- `./docs/STATIC_GATE_ADOPTION.md` completed as the quality-control adoption record.

Do not copy reusable policy, engine implementation, prompts, skills, or generic scripts into the
project merely to make them available. Route to canonical documentation first; the portable snapshot
is only the governed fallback when canonical documentation is unavailable.

Apply `./docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md` to each non-trivial implementation and pre-PR
review through the active global baseline.

## Project-Specific Layer
Create a project-specific docs area for:
- product contracts
- app architecture
- API endpoints
- persistence schemas
- feature flags
- localization/design tokens
- release runbooks
- known risks/debt
- Quality-control adoption: authoritative source membership, profile/engine pin, launcher/workflow,
  automatic-trigger exception when present, deterministic project risks, rule IDs/scope/remediation,
  PR form, and conditional applicability;
  or an explicit deferral with owner, reason, and revisit date.

Create `./docs/STATIC_GATE_ADOPTION.md` from the reusable template and fill it before claiming the
bootstrap contract passes. The bootstrap checker blocks an empty template record.

The workflow is user-triggered by default. Do not add `pull_request`, `push`, `schedule`, merge-queue,
or release triggers without an explicit local exception. Tests, snapshots/UI tests, archive/signing,
feature flags, privacy, observability, and platform capabilities must each be marked applicable,
not applicable, or deferred with an owner and revisit condition.

Do not put project-specific facts into the generic global framework.
