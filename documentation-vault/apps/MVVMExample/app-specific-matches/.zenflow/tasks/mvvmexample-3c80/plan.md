# Clean Bootstrap Plan

## Goal
Keep `MVVMExample` as a clean starter project with the full reusable documentation, rules, prompts, skills, scripts, and Xcode bootstrap.

## Active Focus
- Clean SwiftUI/Xcode project baseline.
- Reusable non-app-specific documentation baseline is installed.
- No app-specific demo feature implementation is currently approved.

## Active Steps
### [x] Step: Refine test coverage plan
### [x] Step: Test coverage plan
### [x] Step: Profile save/config remediation
### [x] Step: Code documentation pass
### [x] Step: Block 1 — Documentation And Rules
### [x] Step: Block 2 — Neutral Reusable Infrastructure Package
### [x] Step: Block 3 — Network / Config / Auth
### [x] Step: Block 4 — Replace send(_ action:)
### [x] Step: Block 5 — Concurrency Lifecycle
### [x] Step: Block 6 — Feature Correctness
### [x] Step: Block 7 — Static Gates
### [x] Step: Optimization Block 1 — Package boundary cleanup
### [x] Step: Optimization Block 2 — Network/config/errors cleanup
### [x] Step: Optimization Block 3 — List performance and controlled image loading
### [x] Step: Optimization Block 4 — Localization resources
### [x] Step: Optimization Block 5 — Interaction correctness and pagination polish


### [x] Step: Test Phase 1 — Test infrastructure
- Add and verify package test targets.
- Add and verify app unit test target.
- Add and verify Xcode test plan/scheme integration.

### [x] Step: Test Phase 2 — AppInfrastructure unit tests
- Add deterministic package tests for configuration, localization, image cache, and networking contracts.
- Verify tests through the supported package/Xcode test command or document any environment blocker.

### [x] Step: Test Phase 3 — App smoke/unit coverage
- Add minimal app smoke test coverage to prove test target visibility and scheme execution.
- Keep app feature behavior tests for subsequent focused phases.


### [x] Step: Test Phase 4 — Profile feature unit tests
- Add deterministic ProfileEditViewModel tests for save success, request trimming, navigation, and user-safe error mapping.

### [x] Step: Test Phase 5 — News list feature unit tests
- Add deterministic NewsListViewModel tests for initial load, refresh failure preservation, like failure, and pagination backpressure where feasible.


### [x] Step: Test Phase 6 — Detail/profile/auth unit tests
- Add deterministic NewsDetailViewModel tests for load and favorite rollback.
- Add ProfileViewModel tests for load, edit route payload, profile update, and logout.
- Add LoginViewModel tests for demo credentials, success, failure, and trimmed username.

### [x] Step: Test Phase 7 — UI/accessibility smoke tests
- Add a dedicated `MVVMExampleUITests` target and connect it to the test plan/scheme.
- Add debug-only deterministic UI-test dependency wiring; do not use live network for UI smoke.
- Add accessibility identifiers and smoke tests for login, news card actions, profile edit fields, and logout/login return.
- Verify with targeted UI tests, app tests, and static gates.

### [x] Step: Localization/i18n and appearance polish
- Audit all user-facing SwiftUI strings and localization resources.
- Add missing localization keys and i18n-friendly formatting where needed.
- Verify/strengthen light and dark scheme support through semantic colors and previews/tests where practical.
- Add a minimal availability-gated Liquid Glass surface in an appropriate app location.
- Run build/tests and static localization/quality gates.

### [x] Step: Sync reusable AppGlassUI package and package usage docs
- Added `./Packages/AppGlassUI` as a standalone Swift Package for Liquid Glass availability/fallback mechanics.
- Replaced app-local `.glassEffect` usage in `./MVVMExample/MVVMExampleDemo/DesignSystem/AppAdaptiveCardSurface.swift` with package-owned `AppGlassUI.appGlassChrome`.
- Updated `./MVVMExample.xcodeproj/project.pbxproj` to link the new package product and weak-link `AppIntents.framework` so Xcode metadata extraction no longer emits the visible warning.
- Added `./docs/PACKAGE_USAGE_IN_MVVMEXAMPLE.md` and updated `./docs/README.md`, `./PROJECT_DOCUMENTATION.md`, and `./PROJECT_HEALTH.md` with current package ownership and stop-list rules.
- Verification: `./Packages/AppGlassUI/Scripts/verify_package.sh`, `python3 ./scripts/check_docs_index.py`, `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, `git diff --check`, and `xcodebuild -project ./MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded; final warning/error grep returned empty.


### [x] Step: Full standalone package transition without AppInfrastructure legacy
- Removed the legacy bundled `./Packages/AppInfrastructure` package from the project/package graph.
- Split reusable infrastructure into one root folder per standalone package: `./Packages/AppConfiguration`, `./Packages/AppErrors`, `./Packages/AppGlassUI`, `./Packages/AppImageLoading`, `./Packages/AppLocalization`, `./Packages/AppLogging`, and `./Packages/AppNetworking`.
- Ensured every active package folder contains `Package.swift`, `README.md`, `PackageContract.md`, `USAGE.md`, `Sources/`, `Tests/`, DocC overview documentation, and `Scripts/verify_package.sh`.
- Removed sibling package dependencies from root packages; cross-package composition now lives at the app boundary, including `APIConfiguration` to `NetworkClientConfiguration`, `NetworkErrorMapping.appAPIError`, and app-owned `AppErrorMapper`.
- Kept Liquid Glass mechanics in `./Packages/AppGlassUI` and app-level surface styling in the design system.
- Updated app/package documentation and package usage rules for the new standalone package layout.
- Verification: each package `Scripts/verify_package.sh` succeeded with no warning/error grep hits; `python3 ./scripts/check_docs_index.py` succeeded; `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj` succeeded; `git diff --check` succeeded; standalone structural grep found no `.package(path:)` or `unsafeFlags` in root package manifests; `xcodebuild -project ./MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded with `BUILD SUCCEEDED` and no warning/error grep hits.


### [x] Step: Fix news list card layout regression
- Diagnosed screenshot-reported left-shift/clipping in the news list row layout.
- Fixed image display sizing so cached/downsample target width no longer becomes the row's layout width.
- Ensured news cards fill the available list width with leading alignment.
- Did not change tests or feature behavior.
- Verification: `git diff --check` succeeded and `./scripts/verify.sh build` succeeded with sandboxed DerivedData/package cache paths.


### [x] Step: Persist session and user actions locally
- Added durable session restoration through Keychain-backed storage so relaunch does not force login when a saved session exists.
- Stored token-like session payload outside SwiftData; SwiftData is used only for non-secret local user state.
- Added SwiftData-backed article like/favorite state and profile-edit persistence so supported user actions survive relaunch.
- Merged local interaction/profile state back into server-loaded data on app/list/detail/profile load.
- Kept server mutation best-effort for the current demo backend; local state is the durable fallback when server persistence is unavailable.
- Did not add or modify tests in this block.
- Verification: `git diff --check`, `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, `./scripts/verify.sh static`, and `./scripts/verify.sh build` succeeded.


### [x] Step: Add pending mutation queue and replay sync
- Added SwiftData-backed pending mutation records for user actions that failed server persistence.
- Coalesced duplicate pending mutations through deterministic idempotency keys for article likes and profile updates.
- Added retry/backoff metadata and replay pending mutations on login/relaunch for the active user.
- Cleared acknowledged mutations after server success and retained failed mutations for later replay.
- Kept token-like session data out of SwiftData.
- Did not add or modify tests in this block.
- Verification: `git diff --check`, `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, `./scripts/verify.sh static`, and `./scripts/verify.sh build` succeeded.

### [x] Step: Sync feed row state after detail favorite changes
- Re-merge visible news-list articles from the shared interaction store when the list becomes visible again after detail navigation.
- Preserve existing pagination and banner state; do not force a network reload.
- Do not add or modify tests in this block.
- Verify with `git diff --check` and an app build.

### [x] Step: Stabilize favorite count and button feedback
- Prevent demo backend responses from double-adjusting locally optimistic like counts.
- Keep favorite UI in the final optimistic state during sync instead of showing a transient clock/disabled flicker.
- Preserve pending mutation behavior and avoid broad observer/reducer changes.
- Verify with `git diff --check` and an app build.

### [x] Step: Audit buttons lists and optimistic server acknowledgements
- Review SwiftUI buttons/transient states for flicker, duplicate taps, and stale disabled/loading behavior.
- Review list mutation paths for server-ack overwrites of locally optimistic state.
- Apply minimal fixes only for defects matching the observed favorite-count class.
- Verify with `git diff --check` and an app build.

### [x] Step: Create comprehensive app test coverage plan
- Reviewed current unit/UI test layout and approved test lanes.
- Identified stale tests that must be modified after recent optimistic-state changes.
- Planned required unit, integration-style, persistence, sync, UI smoke, accessibility, and regression coverage without modifying tests in this step.


### [x] Step: Test sync and optimistic interaction regressions
- Update stale news list/detail tests after favorite optimistic-state changes.
- Add deterministic ArticleInteractionStore and PendingMutationStore tests.
- Add ProfileLocalStore stale server acknowledgement tests.
- Run `git diff --check` and `./scripts/verify.sh test-unit`.


### [x] Step: Test session sync persistence and local store edge cases
- Add deterministic tests for Keychain/session restore safety, token exclusion from SwiftData, logout/local active-user cleanup where testable without production refactor.
- Add pending mutation replay failure/backoff/invalid-payload coverage.
- Add profile local merge/load fallback/no-local failure coverage.
- Add article interaction persistence edge-case coverage.
- Run `git diff --check` and `./scripts/verify.sh test-unit`.

### [x] Step: Test integration regressions navigation and view-state breadth
- Added AppRootCoordinator login/startup/logout dependency integration coverage where current seams exist.
- Added news list refresh, pagination merge, and pagination retry regression coverage for shared interaction state.
- Added news detail load merge and stale cancelled-load response coverage.
- Added profile edit save to profile presentation integration coverage.
- Added standalone navigation tests for `NewsRouter`, `ProfileRouter`, and `MainCoordinator` after explicit follow-up approval.
- Did not add ViewStateBuilder formatting tests in this block; they remain optional backlog unless specifically requested.
- Verification: `git diff --check` and `./scripts/verify.sh test-unit` succeeded.

### [x] Step: Validate approved UI smoke lane and sandbox result bundles
- Fixed the UI test plan identifier so Xcode can read `./MVVMExampleUI.xctestplan`.
- Updated `./scripts/verify.sh` so unit/UI result bundles are written inside `/Users/Artem/.zenflow/worktrees/.xcode-result-bundles/MVVMExample` instead of tool-default temporary locations.
- Verified existing approved UI smoke coverage for login controls, news list/detail controls, profile edit visibility, and logout/login return without live network.
- Did not add deterministic performance regression tests in this block because no concrete performance budget/acceptance threshold was defined; keep this as optional backlog.
- Verification: `git diff --check`, `./scripts/verify.sh test-unit`, and approved `./scripts/verify.sh test-ui` succeeded.

### [x] Step: Test ViewStateBuilder formatting and performance guardrails
- Added deterministic ViewStateBuilder formatting coverage for news list cards, news detail content, and profile display fallbacks/accessibility text.
- Added unit-level performance regression guardrails with explicit budgets for large news-list state building, article interaction merge, and image memory-cache insert/lookup paths.
- Kept performance tests as deterministic simulator/unit guardrails only; real-device Instruments profiling remains a separate validation lane.
- Verification: `git diff --check`, `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, and `./scripts/verify.sh test-unit` succeeded.

## Plan Maintenance Rule
This does not disable plan tracking.

For any new user-approved work:
1. add explicit root-level steps to this file before or during the work when the task benefits from a breakdown;
2. use the existing checkbox step format, for example `### [ ] Step: <title>`;
3. mark completed steps with `[x]` before reporting completion;
4. do not use the absence of current open steps as a reason to skip plan updates for new work.


## Response Header Rule
Every working, status, readiness, or task-orientation response must start with:
- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation

The answer “готов к новым задачам” must still include this header.

## Explicit Stop Rule
Do not implement `TaskDemo`, `TaskDemoViewModel`, SwiftUI demo views, behavior tests, or any other app-specific feature unless the user explicitly requests that feature work again.

## Current Baseline
- Repository should stay clean and connected only to GitHub branches `main` and `Development`.
- `.zenflow/` is local-only and ignored by git.
- Tests are not to be written or modified unless the user explicitly opens a test-writing phase.

### [x] Step: Read-only production/performance audit
- Reviewed current MVVMExample project against active rules, explicit-intent MVVM standard, reusable infrastructure baseline, production review checklist, and performance hot-path requirements.
- Ran static quality gates: docs index, production framework validation, secret scan, large-file scan, forbidden-pattern scan, localization scan, and SwiftUI hot-path scan all passed.
- Identified remaining review findings rather than code changes: profile edit result is not propagated back to profile presentation, profile edit save errors bypass user-safe error mapping, API base URL invalid-value fallback is silent, and final visual/manual/profile validation plus real performance profiling remain unverified.
- No app/source/test changes were made during this audit.

### [x] Step: Sync product-staff quality bar rule
- Added the cross-task rule that demo/test/sample/prototype/pre-production labels cannot lower quality expectations.
- Added the rule that profilers validate and compare performance but do not block statically obvious memory/rendering/hot-path fixes.
- No source/test changes were made.

### [x] Step: Sync full-scope audit/planning rule
- Added the rule that reviews/audits/plans must surface the full relevant concern set with priorities, without silent simplification or agent-owned scope decisions.
- No source/test changes were made.

### [x] Step: Remove duplicated local packages and use app-local minimal infrastructure
- User request: remove all local package folders from `MVVMExample` because reusable package source is now centralized in the central documentation vault reusable area.
- Removed SwiftPM package references/products from `./MVVMExample.xcodeproj/project.pbxproj`; the app target now has no local Swift Package dependencies.
- Removed local `./Packages` folder from the MVVMExample worktree.
- Copied only currently needed infrastructure source into `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/`:
  - configuration/session primitives;
  - app/API error taxonomy;
  - localization facade;
  - redacted logging facade;
  - network request/client primitives;
  - remote image loading/cache primitives;
  - Liquid Glass fallback helper.
- Removed `import App*` package imports from app and test sources; app/tests now use same-module local support types through `@testable import MVVMExample` where applicable.
- Updated project docs to state that this worktree intentionally has no local `./Packages` folder and should copy packages from the central documentation vault reusable area only when package-mode adoption is explicitly desired.
- Verification: `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, `python3 ./scripts/check_docs_index.py`, `git diff --check`, `xcodebuild -list -project ./MVVMExample.xcodeproj`, and `xcodebuild -project ./MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded; build log warning/error grep was clean.

### [x] Step: Sync active rules with documentation vault ownership
- Re-read current MVVMExample rules, task docs, and central documentation vault.
- Updated local docs to use the new `/Users/Artem/.zenflow` sandbox boundary, current response header, and `MODEL_ROUTING_RULE` policy.
- Updated MVVMExample ownership docs to reflect approved app-local `LocalSupport` infrastructure and central documentation-vault context.
- Synced MVVMExample and reusable documentation copies into `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault`.
- Ran docs/static checks: `git diff --check`, `./scripts/check_docs_index.py`, and documentation vault consistency check.

### [x] Step: Remediation Block 1 — Config safety and infrastructure tests
- Make production/release config fail safe instead of silently using DummyJSON fallback.
- Add deterministic tests for config, request encoding, network mapping/retry, error mapping, and image cache/pipeline contracts.
- Run `git diff --check` after the block.

### [x] Step: Remediation Block 2 — Test plan and verification script
- Split unit/UI test plan intent or make the lane naming explicit.
- Extend `./scripts/verify.sh` with static/test/all modes using sandboxed paths.
- Run `git diff --check` after the block.

### [x] Step: Remediation Block 3 — LocalSupport ownership cleanup
- Reduce app-local infrastructure API from `public` to internal where possible.
- Update stale package-oriented comments to app-local `LocalSupport` ownership.
- Decide whether transitional networking bridge wrappers remain useful or should be collapsed.
- Run `git diff --check` after the block.

### [x] Step: Remediation Block 4 — Image/feed and mapper polish
- Add explicit image session/cache/memory-pressure behavior where practical without speculative layers.
- Cache or inject expensive DTO date formatting.
- Run `git diff --check` after the block.

### [x] Step: Remediation Block 5 — Release/readiness documentation
- Document remaining release/App Store/privacy/observability readiness gaps without pretending they are solved.
- Sync durable MVVMExample docs with the documentation vault when docs are changed.
- Run docs/vault/static checks.

### [x] Step: Remediation Block 6 — Final verification and review
- Run approved build/tests/static gates with all artifacts inside `/Users/Artem/.zenflow`.
- Mark completed plan steps and report remaining risks.
