# New Chat Handoff

## Identifiers
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`
- Task ID: `be0b925f-37c1-468e-a4b0-061fc6ae30cd`
- Active app: `AI Fieldbook`
- Active app path: `./AIFieldbook`
- Model routing: apply `./docs/MODEL_ROUTING_RULE.md`; high-risk planning/architecture/final gates require the best available high-quality model.

## Mandatory Startup Rule
Before any code, documentation, git, project, build, or task action:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Local Sandbox Rule
The user explicitly expanded the local sandbox for this task:

- Allowed root: `/Users/Artem/.zenflow`
- Current worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Do not write project artifacts, caches, logs, temporary package verification output, DerivedData, traces, or cloned package state outside `/Users/Artem/.zenflow`.
- Do not use `/tmp`, `/Users/Artem/Library`, global SwiftPM/Xcode caches, or any path outside `/Users/Artem/.zenflow` for project work.

## Mandatory Startup Read Order
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
8. `./docs/MODEL_ROUTING_RULE.md`
9. `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
10. `./.zenflow/tasks/new-task-be0b/handoff.md`
11. `./.zenflow/tasks/new-task-be0b/plan.md`
12. task-relevant package, prompt, and skill docs.

## Mandatory Working Response Header
Every working, status, readiness, planning, confirmation, or task-orientation response must start with:

- model
- active phase
- files being inspected or changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation inside `/Users/Artem/.zenflow`

## Current User Rules
- Treat every implementation/review as product-staff-level production work; demo/test/sample/prototype/pre-release labels do not lower quality.
- Even the smallest test app must have proper project structure, composition root, coordinator/router navigation, feature state ownership, model boundaries, view-state rendering, accessibility/localization posture, and verification gates.
- Do not defer those foundations until future complexity appears.
- For reviews, audits, planning, and requirement analysis, provide full unbiased analysis with priorities.
- Do not guess product decisions. Ask when behavior, ownership, state flow, or acceptance criteria are ambiguous.
- Avoid speculative UI/logic and decorative wrappers, protocols, factories, adapters, use cases, or managers.
- Reusable packages provide mechanisms; app/feature layers provide product decisions.
- ViewModels expose explicit intent methods. Do not use generic `send(_:)`, `dispatch(_:)`, or UI action enums as boilerplate without explicit approval and documented rationale.
- Do not modify app/UI/package test files unless the user explicitly allows test writing again or asks to fix a specific failing test.
- Build/simulator validation is allowed when it materially protects quality; tests remain prohibited.
- Keep `./.zenflow/tasks/new-task-be0b/plan.md` updated before finishing a work block.
- Documentation boundary rule: reusable/global docs stay under `documentation-vault/reusable`, app-specific docs stay under `documentation-vault/apps/<AppName>`, task history stays under task docs. Local exceptions do not affect reusable rules without explicit promotion approval.
- Default quality rule: any project is developed according to the highest reusable standards and best current rules unless the user explicitly approves a narrower local exception.
- Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md`, `./docs/SOURCE_OF_TRUTH_MAP.md`, `./docs/COMPLETION_REPORT_CONTRACT.md`, and `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` for non-trivial work and completion reports.

## Current Package Mode
- `./PackagesInUse` = active source-only reusable package subset compiled into app targets.
- `./PackagesForReuse` = complete reviewed reusable package vault.
- `./Packages` = SDK/package creation documentation, templates, reports, and optional copy-file helpers only.
- Do not use SwiftPM for app integration unless there is an explicit current reason.
- Do not use source-app branding in reusable package docs, skill names, prompts, or shared rules.

## Documentation Boundary State
- Current app-specific canonical target: `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook`.
- Current task canonical target: `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/new-task-be0b`.
- Reusable canonical target: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable`.
- Other app docs are reference-only unless the user explicitly asks for cross-app comparison.

## Current AI Fieldbook State
- Independent internal-only learning app with working name `AI Fieldbook`; project exists at `./AIFieldbook/AIFieldbook.xcodeproj`.
- Toolchain previously verified: Xcode 26.5 (`17F42`), iOS Simulator SDK 26.5, installed runtimes iOS 18.2 and iOS 26.5.
- No backend, cloud-provider budget, cloud data transfer, credentials, or test-writing permission is approved.
- Iteration 1 implementation blocks 1.1-1.25 are complete except that App Intents were explicitly moved to Iteration 2 block 2.0.
- Human/manual acceptance gate 1.26 remains open.
- The explicit acceptance checklist is `./.zenflow/tasks/new-task-be0b/ai-fieldbook-iteration-1-acceptance-gate.md`.
- App Intents and AI work must not start before the Iteration 1 acceptance gate is accepted.
- AI work must first read `./docs/agent-prompts/AI_iOS_MASTER_PROMPT.md`; current user/project rules override generic examples in that prompt.

## Architecture Baseline
- `AppComposition` owns services and screen/modal state.
- `AppCoordinator` owns selected tab, typed per-tab routers, modal presentation, and deep-link routing.
- Routes carry IDs/value objects.
- Feature views do not construct repositories or ViewModels.
- Physical and Xcode structure mirrors `App`, `Navigation`, `Core`, `Features`, `Resources`, plus source-only `PackagesInUse/AppNavigation`.
- This baseline is mandatory for small apps too; do not simplify it away.

## Verification Baseline
- Latest known verification: custom plist and Russian strings linted; `git diff --check` passed; generic iOS Simulator Debug build succeeded with DerivedData/TMPDIR under `./.zenflow-build`; app installed/launched on iOS 26.5; simulator recognized the custom URL scheme and displayed the system open confirmation.
- Remaining manual gate: CRUD/picker fixtures, actual mic recording/playback, URL edit/open, populated migration, VoiceOver/Dynamic Type, confirmed deep-link routing, export/delete-all, and saved-record relaunch.
- Tests remain prohibited and were not created/run.

## Must Not Do
- Do not start Iteration 2, App Intents, or AI implementation until the user accepts the Iteration 1 manual gate.
- Do not lower architecture quality because the app is internal or educational.
- Do not add speculative backend/cloud behavior.
- Do not write tests without explicit permission.
- Do not run traces or broad simulator automation unless useful and resource-justified.

## Completion Rule
After each coherent block:
1. update `./.zenflow/tasks/new-task-be0b/plan.md`;
2. run relevant static/docs verification;
3. report changed files, verification, remaining risks, and whether build/tests were intentionally skipped.
