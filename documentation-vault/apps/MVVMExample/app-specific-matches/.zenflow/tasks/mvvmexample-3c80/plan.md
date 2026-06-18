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
- User request: remove all local package folders from `MVVMExample` because reusable package source is now centralized in TchopApp `./PackagesForReuse`.
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
- Updated project docs to state that this worktree intentionally has no local `./Packages` folder and should copy packages from TchopApp `./PackagesForReuse` only when package-mode adoption is explicitly desired.
- Verification: `plutil -lint ./MVVMExample.xcodeproj/project.pbxproj`, `python3 ./scripts/check_docs_index.py`, `git diff --check`, `xcodebuild -list -project ./MVVMExample.xcodeproj`, and `xcodebuild -project ./MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build` succeeded; build log warning/error grep was clean.
