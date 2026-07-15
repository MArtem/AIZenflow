# iOS Project Developer Onboarding Guide

## Purpose
This is the reusable onboarding baseline for iOS worktrees.

Read this file for:
- app shape;
- architecture boundaries;
- runtime baselines;
- documentation entry points;
- top-level folder ownership.

Do not use this file for current task history, temporary debugging notes, or app-specific implementation logs.

## First Read For Agents
Use `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`. This onboarding document is loaded for project/code/package orientation; it is not an always-read startup document.

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Highest-Quality Default
Every project uses the highest reusable standards and best current rules by default until the user explicitly approves a narrower local exception.

Project labels such as internal, demo, educational, test-only, prototype, or small may reduce feature scope and verification cost. They must not reduce architecture quality, state ownership, documentation boundaries, privacy posture, accessibility posture, or maintainability.

## Universal Architecture Baseline
Every iOS app created or changed from this baseline must start from a production-shaped baseline.

Required baseline:
- physical project structure that separates `App`, `Navigation`, `Core`, `Features`, `Resources`, and reusable package code when present;
- app composition root that owns long-lived services, repositories, feature models, and app-wide state;
- coordinator/router layer for tab selection, per-tab navigation stacks, modal presentation, deep links, and cross-feature routing when navigation exists;
- feature state owners created above views and injected downward;
- explicit ViewModel intent methods instead of generic `send(_:)`, `dispatch(_:)`, or UI action enums by default;
- routes carry stable identifiers or value objects, not DTOs, database records, views, or ViewModels;
- SwiftUI views render state and forward user intents; they do not construct repositories, own global services, perform synchronous file/media work in render paths, or hide failure states.

## Documentation Boundary
Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` before moving, copying, promoting, or editing documentation that may be reusable, app-specific, or task-specific.

Use `./docs/SOURCE_OF_TRUTH_MAP.md` to decide where durable knowledge belongs.

Reusable/global knowledge must stay app-neutral. App-specific plans, local rules, exceptions, compromises, histories, ADRs, and task decisions must stay under the corresponding app/task area. A local exception can become a reusable rule only after explicit promotion approval and app-neutral rewriting.

## New Project Bootstrap
Before starting implementation in a new project/task/worktree:

1. Fill or explicitly defer `./docs/NEW_PROJECT_START_CONTRACT.md`.
2. Run `python3 scripts/check_bootstrap_contract.py`.
3. Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md`.
4. Confirm app-specific documentation belongs in `documentation-vault/apps/<AppName>/`.
5. Confirm task-only state belongs in `documentation-vault/tasks/<task-id>/` or local task docs.

## Canonical Companion Documents
- `./docs/README.md`: documentation map and placement policy.
- `./docs/CURRENT_USER_OVERRIDES.md`: current task/user overrides.
- `./docs/AGENT_RULES.md`: short mandatory implementation guardrails.
- `./docs/NEW_PROJECT_START_CONTRACT.md`: required bootstrap contract for new projects/tasks/worktrees.
- `./docs/SOURCE_OF_TRUTH_MAP.md`: canonical location map for durable knowledge.
- `./docs/AGENT_PREFLIGHT_CHECKLIST.md`: preflight checklist before non-trivial work.
- `./docs/COMPLETION_REPORT_CONTRACT.md`: evidence-based completion report shape.
- `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md`: local exception ADR format.
- `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md`: plan/handoff/task archive boundaries.
- `./PROJECT_HEALTH.md`: reusable package/manager ownership boundaries.
- `./docs/WORK_CONTINUITY.md`: durable resume state and transition prompt.
- `./docs/DOCUMENT_BOUNDARY_STANDARD.md`: reusable/app-specific/task documentation boundary.
- `./TESTING_INSTRUCTIONS.md`: verification and testing workflow.
