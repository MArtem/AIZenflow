# iOS Project Developer Onboarding Guide

## Purpose
This is the stable onboarding document for iOS work in this worktree.

Read this file for:
- app shape
- architecture boundaries
- runtime baselines
- documentation entry points
- top-level folder ownership

Do not use this file for:
- current task history
- temporary debugging notes
- app-specific implementation logs

For the full documentation map, use [docs/README.md](./docs/README.md).

## First Read For Agents
Use `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`. This app onboarding document is loaded for project/code/package orientation; it is not an always-read startup document.

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Universal Architecture Baseline
Every iOS app created or changed in this worktree must start from a production-shaped baseline, even when the app is internal, educational, test-only, prototype, or small.

Required baseline:
- physical project structure that separates `App`, `Navigation`, `Core`, `Features`, `Resources`, and reusable package code when present;
- app composition root that owns long-lived services, repositories, feature models, and app-wide state;
- coordinator/router layer for tab selection, per-tab navigation stacks, modal presentation, deep links, and cross-feature routing;
- feature state owners created above views and injected downward;
- explicit ViewModel intent methods instead of generic `send(_:)`, `dispatch(_:)`, or UI action enums by default;
- routes carry stable identifiers or value objects, not DTOs, database records, views, or ViewModels;
- SwiftUI views render state and forward user intents; they do not construct repositories, own global services, perform synchronous file/media work in render paths, or hide failure states.

## Non-Negotiable Quality Bar
Do not defer coordinator, routing, feature state ownership, file structure, model/state boundaries, accessibility, localization, error handling, or verification because the app is currently simple.

Small scope may reduce feature count and verification cost. It must not reduce code quality, architecture correctness, ownership clarity, or maintainability.

## Stable Runtime Baselines
- Current deployment target is project-specific and must be recorded in task/app docs.
- UI-facing state owners should prefer `Observation` (`@Observable`, `@Bindable`) where supported.
- Type-level `@MainActor` belongs on UI state owners, not on repositories, services, API clients, or reusable packages by default.
- Persistence choice is app-specific, but schema ownership, migration/data-loss behavior, and storage privacy must be explicit before implementation.
- Use `.task` over `.onAppear` for async loading when lifecycle correctness matters.
- Do not assume deallocation immediately after navigation pop.
- Feature view models are created above views and injected downward.
- Implement only explicitly requested behavior; do not add speculative UI or business logic.
- Prefer the simplest correct design that satisfies the full quality bar.

## Reusable Infrastructure
Reusable package code lives in:
- `./PackagesInUse` for active source-only packages compiled into app targets;
- `./PackagesForReuse` for the reusable package vault;
- `./Packages` for SDK/package creation docs, templates, reports, and optional copy-file helpers only.

Reusable packages own generic mechanisms. App targets own product policy, composition, routing, UI, DTO/domain mapping, persistence schema choices, and feature behavior.

Do not use source-app branding in reusable docs, package names, skill names, prompts, or shared rules. Historical app-specific snapshots belong only in app-specific vault folders.

## Documentation Boundary
Apply [docs/DOCUMENT_BOUNDARY_STANDARD.md](./docs/DOCUMENT_BOUNDARY_STANDARD.md) before moving, copying, promoting, or editing documentation that may be reusable or app-specific.

Reusable/global knowledge must stay app-neutral. App-specific plans, local rules, exceptions, compromises, histories, ADRs, and task decisions must stay under the corresponding app/task area. A local exception can become a reusable rule only after explicit promotion approval and app-neutral rewriting.

## Current Active App Overlay
The current independent learning app in this worktree is `AI Fieldbook` under `./AIFieldbook`.

Its current baseline:
- internal-only, local-first iOS learning app;
- no backend, cloud provider, paid service, or third-party cloud data path approved;
- Iteration 1 app shell/user features exist; App Intents and AI begin only after the Iteration 1 acceptance gate;
- architecture baseline is `AppComposition` plus `AppCoordinator`, typed per-tab routers, route IDs, feature models injected into views, and source-only `PackagesInUse/AppNavigation`;
- tests remain prohibited until the user explicitly opens a test-writing phase.

## Top-Level Structure Pattern
New app projects should use this shape unless a documented ADR chooses another one:

```text
AppName/
  App/
  Navigation/
  Core/
    DesignSystem/
    Persistence/
    Search/
    Services/
  Features/
    FeatureName/
  Resources/
```

Reusable package source remains outside the app target folder under `./PackagesInUse/<PackageName>` and is grouped logically in Xcode.

## Canonical Companion Documents
- [docs/README.md](./docs/README.md): documentation map and placement policy
- [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md): current task/user overrides
- [docs/AGENT_RULES.md](./docs/AGENT_RULES.md): short mandatory implementation guardrails
- [docs/NEW_PROJECT_START_CONTRACT.md](./docs/NEW_PROJECT_START_CONTRACT.md): required bootstrap contract for new projects/tasks/worktrees
- [docs/SOURCE_OF_TRUTH_MAP.md](./docs/SOURCE_OF_TRUTH_MAP.md): canonical location map for durable knowledge
- [docs/AGENT_PREFLIGHT_CHECKLIST.md](./docs/AGENT_PREFLIGHT_CHECKLIST.md): preflight checklist before non-trivial work
- [docs/COMPLETION_REPORT_CONTRACT.md](./docs/COMPLETION_REPORT_CONTRACT.md): evidence-based completion report shape
- [docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md](./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md): local exception ADR format
- [docs/TASK_STATE_DOCUMENTATION_STANDARD.md](./docs/TASK_STATE_DOCUMENTATION_STANDARD.md): plan/handoff/task archive boundaries
- [PROJECT_HEALTH.md](./PROJECT_HEALTH.md): reusable package and ownership boundaries
- [docs/PACKAGES_AND_MANAGERS.md](./docs/PACKAGES_AND_MANAGERS.md): reusable package and manager usage guide
- [docs/WORK_CONTINUITY.md](./docs/WORK_CONTINUITY.md): durable resume state and transition prompt
- [docs/DOCUMENT_BOUNDARY_STANDARD.md](./docs/DOCUMENT_BOUNDARY_STANDARD.md): reusable/app-specific/task documentation boundary
- [docs/knowledge/global/README.md](./docs/knowledge/global/README.md): reusable cross-project knowledge
- [TESTING_INSTRUCTIONS.md](./TESTING_INSTRUCTIONS.md): verification and testing workflow
- [handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md): current task resume state
- [plan.md](./.zenflow/tasks/new-task-be0b/plan.md): current task plan only

## What To Update When Things Change
- Stable architecture or runtime policy: update this file.
- Package or manager ownership: update [PROJECT_HEALTH.md](./PROJECT_HEALTH.md).
- Verification workflow: update [TESTING_INSTRUCTIONS.md](./TESTING_INSTRUCTIONS.md).
- Current user/task override: update [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md).
- Current task state: update [handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md).
- Current task plan: update [plan.md](./.zenflow/tasks/new-task-be0b/plan.md).

## Archive Policy
Verbose historical versions are kept only for fallback reference:
- `docs/archive/`
- `.zenflow/tasks/new-task-be0b/archive/`

They are not part of the default read path.
