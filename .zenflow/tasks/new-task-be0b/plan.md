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

### [x] AI Fieldbook production audit remediation pass
- Fix data lifecycle and Spotlight privacy/delete-all behavior.
- Add explicit local storage/privacy documentation and code contracts.
- Reduce main-actor search/repository hot-path risk.
- Replace synchronous PDF document loading in UI update path.
- Bound cached detail view model lifetime and avoid broad reloads.
- Complete localization/InfoPlist localization coverage.
- Keep App Intents and AI out of this pass.

### [x] AI Fieldbook task/data/rendering hardening pass
- Move search and Spotlight snapshots to a background SwiftData `ModelActor`.
- Add cancellable search task ownership and stale-result protection.
- Harden delete-all to clear records, files, exports, Spotlight, routes, and runtime detail caches.
- Keep generated exports temporary by replacing older export folders.
- Review SwiftUI render paths for sync file/media/database work and keep remaining async tasks tied to a user action, `.task(id:)`, model-owned cancellation, or app-lifetime maintenance.

### [x] Static quality gate scope hardening
- Make Swift/static gate scripts respect explicit file/directory scope arguments.
- Add shared scope resolution that refuses paths outside the repository root.
- Classify output as `blocking`, `warning`, or `review-candidate` instead of mixing all findings as failures.
- Keep SwiftUI hot-path task findings non-blocking review candidates while forbidden patterns, localization gaps, secrets, and large files remain blocking.
- Update `run_static_quality_gates.sh` to pass scope arguments through to scoped checks.

### [x] AI Fieldbook project-wide code documentation pass
- Add contract-level documentation to every significant executable AIFieldbook app target file.
- Include the active `PackagesInUse/AppNavigation` source compiled into the app target.
- Add script-level documentation to project quality-gate scripts that affect AIFieldbook work.
- Keep comments focused on ownership, lifecycle, side effects, concurrency, privacy, persistence, and runtime invariants.

### [x] Figma design implementation intake rule
- Add a reusable Figma Design Intake Gate before any Figma-to-SwiftUI implementation.
- Require exact node/frame, fidelity mode, states/variants, assets/fonts policy, interaction behavior, and accessibility/localization expectations when they are not inferable from Figma.
- Add app-neutral `UI_PIXEL_PERFECT_WORKFLOW.md` to the reusable baseline so future projects start with the same Figma intake rule.
- Keep legacy app-specific Figma snapshots untouched.

### [x] Codex app project/task documentation bootstrap rule
- Record that Codex app-created tasks/projects/worktrees/Xcode projects/apps must receive task `plan.md`, task `handoff.md`, and the correct app-specific documentation boundary automatically.
- Require the assistant to maintain those docs throughout the project lifecycle without waiting for the user to request them every time.
- Require separate app-specific docs for each Xcode project/app, even when multiple projects are created or modified inside one task.
- Update reusable bootstrap docs/templates and local active rule copies.

### [x] Secret handling and security intake standard
- Add reusable rules for keeping real secrets out of chat, git, app bundles, and normal AI-readable workspace files.
- Add a reusable `.gitignore` secret baseline template for local secrets, private configs, signing material, service credentials, logs, traces, and exports.
- Define the preferred local secret root as `/Users/Artem/.zenflow-secrets/<ProjectName>/`, with the assistant receiving only logical placeholder names, env var names, build setting names, or config keys — never secret values or accessible real paths to secret files.
- Add an explicit security intake/remediation workflow for imported projects that may already contain secrets, with redacted reporting and mandatory rotation/revocation guidance for exposed secrets.
- Wire the standard into new-project bootstrap, security/privacy gate, agent rules, docs index, and reusable templates.

### [x] Documentation routing and context-load optimization
Goal: reduce context/limit cost without lowering the project quality bar by routing agents to the right documents instead of expanding the always-read set.

Completed sequence:
1. Ran a read-only audit of current mandatory read paths, task docs, reusable docs, prompts, skills, and duplicated rules.
2. Classified docs into levels:
   - Level 0: always-read minimal operating baseline.
   - Level 1: task routers and source-of-truth maps.
   - Level 2: task-specific standards such as Figma/UI, AI/App Intents, concurrency, persistence, navigation, security/privacy, accessibility, localization, testing, release, and code documentation.
   - Level 3: deep references such as production matrices, architecture catalog, full audits, and playbooks.
   - Archive: legacy/history/recovery material not read without a specific reason.
3. Added `TASK_TYPE_DOCUMENTATION_ROUTER.md` that maps task types to the exact docs/prompts/skills/deep references to read.
4. Replaced repeated long rules in startup docs with canonical summaries and links to the source-of-truth document.
5. Moved nonessential documents out of mandatory startup read paths and into routed read paths.
6. Kept global reusable routing rules in `AIZenflowDocumentation`; kept local task/app state in the current task/app docs only.
7. Added `check_task_type_documentation_router.py` and validated missing router paths, docs links, app-specific leakage, and secret safety.
8. Adopted a short reporting convention for future work:
   - `Docs route: Level 0 + <task-specific route>`
   - `Deep references skipped/applied: <reason>`

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
