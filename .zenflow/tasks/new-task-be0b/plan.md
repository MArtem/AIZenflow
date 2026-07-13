# Current Plan

## Goal
Build and maintain `AI Fieldbook` as an independent internal-only iOS learning app while keeping the engineering baseline production-shaped from the first screen onward.

## Active Focus
- Iteration 1 local app is implemented through block 1.25.
- Manual acceptance gate 1.26 remains open.
- Iteration 2 begins only after user acceptance of Iteration 1.
- App Intents and AI are Iteration 2 work, not Iteration 1.

## Non-Negotiable Architecture Baseline
- Every iOS app, including test/demo/internal apps, must have a proper physical project structure.
- App-level composition owns services, repositories, feature models, app-wide state, and resource-owning models.
- App coordinator/router owns tab selection, per-tab navigation stacks, modals, deep links, and cross-feature routing.
- Feature views receive state owners/callbacks; they do not construct repositories or app services.
- Routes carry stable identifiers/value objects, not DTOs, database records, views, or ViewModels.
- SwiftUI views react to explicit state and call explicit ViewModel intent methods.
- Do not postpone coordinator, routing, model/state ownership, accessibility, localization, or verification because the current app is small.

## Active Steps
### [x] Documentation cleanup: remove source-project naming from active shared docs
- Rename local package/card skills to neutral iOS names.
- Remove source-project naming from active shared docs, handoff, and current task plan.
- Update rules so future apps cannot be started as loose file collections or junior-level skeletons.
- Update docs to state that small/test apps get smaller scope, not lower quality.

### [x] Documentation boundary standard
- Add mandatory reusable/app-specific/task separation rules.
- Preserve reusable/global documentation in `documentation-vault/reusable`.
- Preserve app-specific docs in `documentation-vault/apps/<AppName>`.
- Preserve task history and local state in task docs.
- Require explicit promotion approval before any local app exception changes reusable/global rules.

### [x] Documentation boundary bootstrap propagation
- Add `./docs/DOCUMENT_BOUNDARY_STANDARD.md` to reusable project/task/worktree startup templates.
- Make reusable baseline install fail if the boundary standard is not copied.
- Update transfer/porting guides so every new project/task/worktree applies the boundary standard before implementation or documentation movement.
- Mirror updated bootstrap templates and reusable baseline rules into `documentation-vault/reusable`.

### [x] Quality governance hardening
- Add bootstrap and documentation-boundary validators.
- Add new project start contract, source-of-truth map, local exception ADR template, completion report contract, preflight checklist, and task-state documentation standard.
- Add explicit AI Fieldbook Iteration 1 acceptance gate.
- Record that every project uses the highest reusable standards and best current rules unless the user explicitly approves a narrower local exception.
- Add canonical `MArtem/AIZenflowDocumentation` push requirement, docs repo operations runbook, remote-state validator, and compact manifest summary.

### [x] Iteration 1 local app blocks 1.1-1.25
- Local-only workspace/content app exists.
- App structure now includes `App`, `Navigation`, `Core`, `Features`, and `Resources`.
- `AppComposition` owns dependencies and feature models.
- `AppCoordinator` owns selected tab, per-tab typed routers, modal presentation, and deep-link routing.
- App Intents were explicitly moved out of Iteration 1.

### [ ] Iteration 1 manual acceptance gate 1.26
Manual validation still needed:
- CRUD and picker fixtures;
- actual microphone recording/playback;
- URL edit/open;
- populated data migration/relaunch durability;
- VoiceOver and Dynamic Type;
- confirmed deep-link routing after accepting the system prompt;
- export/delete-all flows.

### [ ] Iteration 2 block 2.0: App Intents foundation
Do not start until gate 1.26 is accepted.

### [ ] Iteration 2 AI features
Do not start until gate 1.26 is accepted and App Intents foundation is planned.

## Verification Policy
- Documentation-only changes: use `rg`, docs index checks where relevant, and `git diff --check`.
- App build/simulator validation is allowed when it materially protects quality.
- Tests remain prohibited until the user explicitly opens a test-writing phase.

## Context Transfer Rule
Every handoff must include:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
