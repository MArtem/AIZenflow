# Auto

## Configuration
- **Artifacts Path**: {@artifacts_path} → `.zenflow/tasks/{task_id}`

---

## Agent Instructions

Ask the user questions when anything is unclear or needs their input. This includes:
- Ambiguous or incomplete requirements
- Technical decisions that affect architecture or user experience
- Trade-offs that require business context

Do not make assumptions on important decisions — get clarification first.

---

## Workflow Steps

### [x] Step: Implementation
<!-- chat-id: e77a8cef-de0f-455a-9ecb-2d90a1f622a9 -->

Implemented this as a standalone SwiftUI feed screen because the worktree does not contain the existing iOS app source files. The added view recreates the screenshot with a top bar, featured article card, discussion preview, floating action button, and bottom tab bar so it can be pasted into an app and refined there.
The implementation has since been expanded into a full Xcode project with the SwiftUI code split across app shell, tab, menu, and news component files so it is easier to evolve as a real iOS app.
The infrastructure layer has now been split into a local Swift package at `Packages/TchopInfrastructure` with two separate modules: `TchopNetworking` and `TchopDatabase`. The app target now links those package products, the old app-local API/database manager files were removed, public module APIs were documented, package tests were added, and both the package test suite and the main app build now pass.
After the module split, an additional refactoring and documentation pass was applied across the app layer. Core app types now contain inline documentation, and a few large stub/fallback builders were extracted into private helpers to keep runtime logic smaller and easier to maintain.
The app now also has an Xcode unit test target, `TchopAppTests`, covering `AppState`, `LoginViewModel`, and `NewsFeedViewModel`. Both the package suite and `xcodebuild test` for the app now pass, so the current baseline includes automated verification for infrastructure and app-level state logic.
The app-level test coverage was then extended to include `TabRouter`, `AppCoordinator`, `UserRepository`, and `AppContentRepository`, so the current app behavior around navigation and repository mapping is now verified. The persistence layer was also refactored behind a common `AppDatabaseManaging` adapter contract with both `SwiftDataAppDatabaseAdapter` and `CoreDataAppDatabaseAdapter`, and the DI container now selects the concrete backend through runtime policy instead of binding repositories directly to SwiftData types.
The same backend-neutral architecture is now also implemented inside the `TchopDatabase` infrastructure module. The package exposes a shared `DatabaseManaging` contract with backend selection policy, `SwiftData` and `Core Data` managers, and backend-neutral read/write operation wrappers. Package tests now validate both backends and the factory selection path, and the full app test suite still passes against the updated package.
The app layer has now been brought onto that same package contract directly. Repositories and seeders use `DatabaseManaging` from `TchopDatabase`, while `AppDatabase.swift` is reduced to app-specific container construction and hands backend choice to `DatabaseServiceFactory`. In parallel, `TchopNetworking` was extended with typed connectivity errors, an authentication interceptor, upload and download APIs with progress reporting, and an offline queue foundation. Both `swift test --package-path Packages/TchopInfrastructure` and `xcodebuild ... test` pass after these changes.

### [x] Step: Replace stub tabs with feature screens

Continue from the current coordinator-based tab architecture by replacing the generic stub views in `Mixes`, `Pinned`, and `Chat` with concrete SwiftUI feature screens that match the existing visual system and preserve independent navigation stacks.
This step was completed by introducing dedicated `MixesTabRootView`, `PinnedTabRootView`, and `ChatTabRootView` screens backed by shared `FeatureTabContent` models and a reusable `FeatureTabScaffoldView`, while keeping each tab on its own `TabRouter`.
Verification: `xcodebuild -project TchopApp.xcodeproj -scheme TchopApp -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build` succeeded, and `swift test --package-path Packages/TchopInfrastructure` still passes. `xcodebuild ... test` was attempted on both `iPhone 17 Pro` and `iPhone 16 Pro`, but the run stalled in CoreSimulator after build completion, so app test execution could not be conclusively completed in this environment.

### [x] Step: Refresh handoff state

Recorded the new tab-screen baseline in `handoff.md`, including the new view/model files, the removal of stub tab roots from active navigation, and the current verification status with the CoreSimulator issue noted for the next chat.

### [x] Step: Model usage policy for quality vs limits

Added a persistent workflow policy for model roles so implementation defaults to `GPT-5.3 Codex` and `GPT-5.4` is used as a targeted review gate instead of a mandatory every-step reviewer.
The policy includes concrete review triggers (risk areas, diff size, refactors, unstable tests, and pre-merge checks) to keep code quality high while avoiding unnecessary token spend on trivial edits.

**Debug requests, questions, and investigations:** answer or investigate first. Do not create a plan upfront — the user needs an answer, not a plan. A plan may become relevant later once the investigation reveals what needs to change.

**For all other tasks**, before writing any code, assess the scope of the actual change (not the prompt length — a one-sentence prompt can describe a large feature). Scale your approach:

- **Trivial** (typo, config tweak, single obvious change): implement directly, no plan needed.
- **Small** (a few files, clear what to do): write 2–3 sentences in `plan.md` describing what and why, then implement. No substeps.
- **Medium** (multiple components, design decisions, edge cases): write a plan in `plan.md` with requirements, affected files, key decisions, verification. Break into 3–5 steps.
- **Large** (new feature, cross-cutting, unclear scope): gather requirements and write a technical spec first (`requirements.md`, `spec.md` in `{@artifacts_path}/`). Then write `plan.md` with concrete steps referencing the spec.

**Skip planning and implement directly when** the task is trivial, or the user explicitly asks to "just do it" / gives a clear direct instruction.

To reflect the actual purpose of the first step, you can rename it to something more relevant (e.g., Planning, Investigation). Do NOT remove meta information like comments for any step.

Rule of thumb for step size: each step = a coherent unit of work (component, endpoint, test suite). Not too granular (single function), not too broad (entire feature). Unit tests are part of each step, not separate.

Update `{@artifacts_path}/plan.md`.
