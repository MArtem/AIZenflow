# Current Plan

## Goal
Keep `TchopApp` implementation and documentation aligned with the current product contract while minimizing unnecessary complexity, context churn, and verification cost.

## Active Focus
- Feed/composer/card runtime for `text`, `photo`, `video`, `audio`, `pdf`.
- Documentation/rules are now part of the active working baseline.
- Current user overrides are canonical for this task and live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Active Steps
### [x] Step: Full Read-Only Production Audit — setup and evidence map
- Scope: `./TchopApp`, `./TchopShareExtension`, `./TchopWidgetExtension`, `./Packages`, `./docs`, `./.codex/skills/tchop-feed-cards`.
- Explicitly exclude `./TchopAppTests`.
- Read-only only: no code/docs/rules changes during audit except updating this task plan/status after the audit report is produced.
- Reconfirm active rules before audit: docs index, project docs, user overrides, agent rules, continuity docs, task handoff/plan, feed-card contract, package rules, SwiftUI review references.
- Build/test policy during audit: no build required for read-only findings; build only after later remediation blocks.
- Output artifact target: audit findings should be written/summarized in task context before any implementation plan is executed.

### [x] Step: Full Read-Only Production Audit — Block A app state/session/auth
- Inspect app state/session/auth runtime for fake/local/demo naming, placeholder production behavior, mixed UI/domain state, and duplicate state owners.
- Candidate files: `./TchopApp/App/AppState.swift`, `./TchopApp/Services/UserSessionService.swift`, `./TchopApp/Models/AccountProfileSummary.swift`, `./TchopApp/Views/AppRootView.swift`.
- Also grep wider app/extensions/packages scope for `fake`, `demo`, `stub`, `mock`, `sample`, `placeholder`, `local`, `session`, `token`, `auth`, and user/profile fallback behavior.
- Required output per finding: severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, verification need.

### [x] Step: Full Read-Only Production Audit — Block B persistence/database ownership
- Inspect SwiftData/database lifecycle ownership, repository boundaries, fetch-all/save-all patterns, DTO leakage into UI, schema leftovers after `Local*` removal, and main-thread I/O risk.
- Candidate files: `./TchopApp/Persistence/AppDatabase.swift`, `./TchopApp/Persistence/AppContentRecord.swift`, `./TchopApp/Repositories/AppContentRepository.swift`, `./TchopApp/ViewModels/AppShellViewModel.swift`.
- Also inspect package database contracts under `./Packages/TchopInfrastructure` where app/database boundaries are involved.
- Required output per finding: severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, verification need.

### [x] Step: Full Read-Only Production Audit — Block C navigation/menu/root composition
- Inspect root composition, coordinator/deep-link ownership, tab/menu state, repeated VM creation, side effects in SwiftUI `body`, and UI implementation details leaking into navigation decisions.
- Candidate files: `./TchopApp/Views/AppRootView.swift`, `./TchopApp/Navigation/DeepLinkManager.swift`, `./TchopApp/Views/Tabs/NewsTabRootView.swift`.
- Also inspect app DI/root shell wiring where navigation and session state meet.
- Required output per finding: severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, verification need.

### [x] Step: Full Read-Only Production Audit — Block D packages/infrastructure boundaries
- Inspect whether app-specific logic leaked into packages, whether app code adds decorative wrappers over package APIs, whether package APIs force bad app patterns, and whether infrastructure has concurrency/sendability risks.
- Candidate areas: `./Packages/TchopInfrastructure/Sources/TchopShareSupport`, `./Packages/TchopInfrastructure/Sources/TchopCache`, `./Packages/TchopInfrastructure/Sources/TchopNetworking`.
- Also inspect `SyncCore`, database, localization, widgets, auth, analytics, and package references touched by app runtime.
- Required output per finding: severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, verification need.

### [x] Step: Full Read-Only Production Audit — Block E UI rendering/performance rules across project
- Inspect all SwiftUI files outside `./TchopAppTests` for hot-path work: sync file/image/media work in `body`, heavy repeated shadows/blur/masks, unstable identity, broad observable dependencies, `AnyView`, computed maps/sorts/filters in render paths, side effects in `body`, and unnecessary layout invalidation.
- Scope includes `./TchopApp/**/*.swift`, `./TchopShareExtension/**/*.swift`, `./TchopWidgetExtension/**/*.swift`, and package SwiftUI views if present.
- Special attention: repeated lists/scrolls, cards, menus, root shell, composer, share extension UI, widget rendering.
- Required output per finding: severity P0-P3, affected files, evidence, why it is a problem, target state, remediation order, verification need.

### [x] Step: Full Read-Only Production Audit — rules/checklist hardening proposal
- Completed before the audit by explicit user approval because the audit must be executed against the final rules, not rules created after the fact.
- Added `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` with mandatory review areas, forbidden-pattern stop list, severity policy, required finding format, and completion report requirements.
- Updated `./docs/AGENT_RULES.md`, `./docs/WORK_CONTINUITY.md`, `./docs/CURRENT_USER_OVERRIDES.md`, `./docs/PRODUCTION_QUALITY_GATES.md`, and `./docs/README.md` so the checklist is part of the active working baseline.
- Required audit standards now explicitly cover UI hot path, state ownership, DB access pattern, networking boundary, concurrency, memory/cache, naming/domain purity, persistence migration risk, verification scope, and no speculative abstractions.
- Stop list now explicitly blocks `Local*` domain/UI split without storage-only meaning, sync media/file work in render paths, unqualified `ForEach(Array(...))`, whole VM into repeated rows, fetch-all for single update without proof, silent stub/demo/local fallback, and production UI backed by stub JSON.

### [x] Step: Full Read-Only Production Audit — final report and remediation plan proposal
- Produce the audit report before making implementation changes.
- Report format:
  1. P0-P3 findings list.
  2. affected files.
  3. why each finding is a problem.
  4. correct target state.
  5. recommended fix order.
  6. which remediation blocks require build.
  7. which blocks require simulator UI or Instruments.
- Severity policy:
  - P0: core flow broken, data loss/corruption risk, severe jank/crash/security issue.
  - P1: architecture/runtime error that will reliably cause bugs or high rewrite cost as the app grows.
  - P2: incorrect implementation pattern that should be fixed before new feature work in the affected area.
  - P3: consistency/cleanup/docs/rules issue that should be scheduled but does not block current core behavior.
- After the user approves the remediation plan, implement fixes in coherent blocks; after each block update `./.zenflow/tasks/new-task-be0b/plan.md`, run `git diff --check`, run `plutil` if project files changed, and run build when the block is implementation-level.

## Current Working Baseline
- Apply `./docs/MODEL_ROUTING_RULE.md`: use `GPT-5.4` for approved-plan low-risk execution and `GPT-5.5` for planning, architecture, high-risk, and final-gate work.
- Before substantive work or context transfer, use the active docs index in `./docs/README.md`.
- Always include the context-transfer rule: **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.
- Do not run builds, tests, or simulator UI unless the user explicitly asks.
- Do not touch `./TchopAppTests` unless the user explicitly asks.
- Prefer the simplest correct implementation; avoid speculative UI, speculative logic, and decorative abstractions.

## Canonical Docs Added/Refreshed
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`
- `./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `./docs/agent-prompts/README.md`
- `./.codex/skills/tchop-feed-cards/references/feed-card-contract.md`
- `./docs/knowledge/global/README.md`
- `./docs/knowledge/TchopApp/README.md`
- `./PROJECT_DOCUMENTATION.md`

- Completed now: hardened `./.gitignore` for privacy/CI signing safety (added iOS build artifacts, local env files, Apple signing/provisioning files, private keys/tokens/service-account patterns, Fastlane generated secrets/output, and CI secret material; verified tracked secret-like path scan returned empty and docs remain unignored).
- Verification: static git-ignore checks only; no build run per current instruction.

- Completed now: whole-project static review pass across app/packages/extensions using updated docs/prompts; applied one minimal compile-safety fix in `./TchopShareExtension/ShareViewController.swift` to align share-extension composer publish callback with the current `FeedComposerViewModel` one-argument `publishAction` signature.
- Verification: static review/grep checks only; no build run per current instruction.

- Completed now: consistency cleanup batch from review findings:
  - made `./TchopApp/ViewModels/AppShellViewModel.swift` require an explicit `FeedCardPersisting` repository for `FeedCardStore`, preventing accidental memory-only production feed persistence.
  - removed the matching default in `./TchopApp/ViewModels/NewsFeedViewModel.swift` so feed runtime receives the same explicit store from app composition.
  - changed `./Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift` logging interceptor default logger from `print` to no-op.
  - localized visible share/widget extension strings through shared localization resources in `./Packages/TchopInfrastructure`.
- Verification: `git diff --check` only; no build/test/simulator run per current instruction.

- Completed now: local-feed runtime cleanup pass:
  - removed `PhotoCardModel`/`TextCardModel` callback plumbing from `./TchopApp/Views/News/NewsFeedView.swift` and `./TchopApp/Views/Tabs/NewsTabRootView.swift`; feed taps/actions now go through local published cards only.
  - removed unused remote-card translation/action entry points from `./TchopApp/ViewModels/NewsFeedViewModel.swift`.
  - stopped app bootstrap from resolving fixture fallback feed content in `./TchopApp/App/AppDIContainer.swift`.
  - stopped seeding JSON-backed feed snapshots in `./TchopApp/Persistence/AppDataSeeder.swift`; seeding now only creates default channels.
  - changed `./TchopApp/Services/FeedAPIManager.swift` stub feed fetches to return an empty payload until a real backend contract exists.
  - removed bundled `StubFeedResponse*.json` resources from `./TchopApp/Resources` and from `./TchopApp.xcodeproj/project.pbxproj`.
- Verification: `git diff --check` only; no build/test/simulator run per current instruction.

- Completed now: removed the now-unused remote feed loading/action dependency from `./TchopApp/ViewModels/NewsFeedViewModel.swift` and app composition:
  - `NewsFeedViewModel` no longer depends on `NewsFeedRepository`, bootstrap content, load-failure content, loading tasks, or remote photo/text action coordinators.
  - `./TchopApp/App/AppDIContainer.swift` creates the feed VM directly from channel/widget/error/local-card dependencies.
  - `./TchopApp/Repositories/AppContentRepository.swift` no longer exposes a `NewsFeedRepository` protocol surface to app composition; channel resolution remains the active repository contract.
- Verification: `git diff --check` only; no build/test/simulator run per current instruction.


- Completed now: executed requested steps 1, 2, and 4 after build-backed cleanup:
  - step 1 legacy localization/resource cleanup: removed unused `news.fallback.*`, `news.photo.pending.*`, and `news.text.pending.*` localization keys from active English/Russian resources; added active `news.feed.sourceFallback` in English/Russian/German and switched feed card source fallback to that key in `./TchopApp/Models/NewsFeedModels.swift`.
  - step 2 static UX edge-case review: verified empty-feed state, channel-scoped search filtering, source-only translation suppression, source URL tap gating, media-only spacing/action bar behavior, and action toolbar isolation from card-detail tap handling.
  - step 4 context/package cleanup: refreshed active documentation/handoff references so they no longer point at removed remote/stub feed runtime files such as `FeedAPIManager`, `PhotoActionView`, `PhotoCardView`, or `TextCardView`.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests or simulator UI run.


- Completed now: read-only feed scroll performance analysis requested by user:
  - reviewed feed card creation/persistence/display flow from composer media storage through `FeedCardStore`, SwiftData `FeedCardRepository`, `NewsFeedViewModel.visibleContent`, and `NewsFeedView` rendering.
  - identified primary scroll-jank risks: synchronous media decoding/thumbnail generation in SwiftUI row bodies, repeated derived feed/translation computation during body evaluation, broad row dependency on `NewsFeedViewModel`, per-card main-thread persistence refresh after interactions, and per-card shadows/clipping costs.
  - produced a recommended remediation plan focused on cached async media previews, stable row view models/snapshots, precomputed visible feed snapshots, incremental persistence updates, and profiler-backed validation.
- Verification: read-only/static analysis only; no build, tests, or simulator UI run for this analysis pass.


- Completed now: expanded future-proof production-quality rules beyond the current feed implementation:
  - added `./docs/PRODUCTION_QUALITY_GATES.md` with mandatory gates for architecture, SwiftUI rendering, scroll/list/grid performance, state/Observation, concurrency/threading, persistence/database, network/sync, models/mapping, memory/media/cache, visual rendering, error handling, security/privacy/logging, testing/verification, review severity, and stop-the-line rules.
  - updated `./docs/AGENT_RULES.md` so production quality gates are mandatory for non-trivial implementation, refactor, and review work.
  - updated `./docs/README.md` so the new quality gate document is part of the active documentation index and placement policy.
- Verification: `git diff --check` only; docs-only change, no build/tests/simulator UI run.


- Active now: full read-only production audit requested and confirmed by user:
  - scope: entire project except `./TchopAppTests`.
  - mode: read-only audit first; do not fix code yet.
  - user decision: strictly remove all `Local*` runtime/model/persistence naming and source-split logic in the future remediation plan; app is not released, so migration compatibility does not block renaming/remodeling.
  - severity policy: P0 through P3 findings are in scope and should be planned before new features.
  - audit focus: conceptual architecture, unified feed/card model, SwiftUI/runtime hot paths, state invalidation, persistence/database, media/cache, networking/sync/package boundaries, extensions/widgets, security/privacy/logging, and verification gaps.
  - mandatory feed scroll performance findings to preserve in the remediation plan:
    1. `./TchopApp/Views/News/NewsFeedView.swift` currently performs media decoding/thumbnail generation in SwiftUI row bodies: `UIImage(contentsOfFile:)`, synchronous `AVAssetImageGenerator.copyCGImage`, synchronous `PDFDocument(url:)`/`page.thumbnail(...)`, and repeated `FileManager` existence checks during media path resolution. These must move out of the scroll hot path into async/cached media preview preparation.
    2. `./TchopApp/ViewModels/NewsFeedViewModel.swift` exposes `visibleContent` as a computed property and `./TchopApp/Views/News/NewsFeedView.swift` reads it multiple times during body evaluation, including empty-state checks and `ForEach`; remediation must precompute or memoize visible feed snapshots.
    3. Feed rows currently receive the whole `NewsFeedViewModel` and call translation/action methods from row bodies, broadening the SwiftUI dependency graph; remediation must pass narrow immutable row data plus explicit callbacks.
    4. Interaction persistence for like/comment/display-mode currently saves through `FeedCardStore.updatePersistedCard`, fetches broad persistence state in `FeedCardRepository.saveCards`, and rebuilds all cards; remediation must make single-card updates targeted and avoid whole-feed invalidation.
    5. Repeated `.clipShape(...)` and `.shadow(...)` on every feed card may add offscreen rendering cost after media decoding is fixed; remediation must profile or simplify repeated row effects if needed.
- Verification: audit phase uses read-only/static commands only; no build/tests/simulator UI unless explicitly requested later.


- Approved now: prepare Phase 1 + Phase 2 feed-card remediation implementation plan before coding.
  - Phase 1 objective: remove all `Local*` naming/source-split logic and converge composer, persistence, feed runtime, share extension, and widgets onto one source-neutral `FeedCard` contract.
  - Phase 2 objective: remove feed scroll jank by moving all image/video/PDF/file resolution work out of SwiftUI row bodies into prepared/cached media preview state.
  - Implementation plan, pending user confirmation before code changes:
    1. Domain/model reset in `./TchopApp/Models/NewsFeedModels.swift`:
       - replace `FeedCard`, `LocalFeed*` media/text/source types, and `.local(...)` wrapper enums with source-neutral `FeedCard`, `FeedCardMedia`, `FeedCardTextContent`, `FeedCardSourceContent`, `FeedCardDisplayMode`, and related helpers.
       - keep the product taxonomy exactly `text`, `photo`, `video`, `audio`, `pdf` and strict text order `text`, `headline`, `subheadline`, `source`.
       - remove source-origin from UI/domain names; source/sync metadata, if needed, must be storage/sync metadata, not UI branch identity.
       - move route/localization decisions out of the card domain model where practical, so the card model stays product data rather than navigation/UI policy.
    2. Persistence/store reset:
       - replace `FeedCardRecord` with source-neutral `FeedCardRecord` in `./TchopApp/Persistence/AppContentRecord.swift` and `./TchopApp/Persistence/AppDatabase.swift`; app is not released, so legacy migration compatibility does not block the rename/remodel.
       - replace `FeedCardRepository` / `FeedCardPersisting` with source-neutral `FeedCardRepository` / concrete persistence boundary in `./TchopApp/Repositories/AppContentRepository.swift`.
       - move feed-card store/persistence protocol out of `./TchopApp/ViewModels/AppShellViewModel.swift` so view-model files do not own repository contracts.
       - change single-card updates to targeted persistence paths instead of broad full-record fetch/update/rebuild where possible in this phase.
    3. App composition/share/widget naming reset:
       - replace `feedCardStore` and related DI naming in `./TchopApp/App/AppDIContainer.swift`, `./TchopApp/ViewModels/AppShellViewModel.swift`, and `./TchopApp/ViewModels/NewsFeedViewModel.swift`.
       - replace `SharedFeedCardSyncManager` with source-neutral shared feed-card import/sync naming in `./TchopApp/Shared` and `./TchopShareExtension/ShareViewController.swift`.
       - preserve the current core behavior: composer-created and share-extension-created cards persist, display in the selected channel, and preserve like/comment/display mode after restart.
    4. Feed UI renderer reset in `./TchopApp/Views/News/NewsFeedView.swift`:
       - remove `.local` switch branches and `Local*CardView` / `Local*Media*` names.
       - make rows receive source-neutral card row data and narrow callbacks rather than the entire `NewsFeedViewModel`.
       - remove `ForEach(Array(viewModel.visibleContent.cards), ...)`; compute visible cards once before rendering and pass a stable array to the section.
    5. Feed state/performance reset in `./TchopApp/ViewModels/NewsFeedViewModel.swift`:
       - replace computed hot-path `visibleContent` with precomputed or memoized visible feed snapshot invalidated only by channel, search query, card version, or translation state changes.
       - stop row body calls from repeatedly triggering translation availability and broad view-model reads.
       - keep empty/search/loading/error state derived from the same feed snapshot source of truth.
    6. Media preview pipeline for smooth scroll:
       - introduce a small feed media preview loader/cache owned outside SwiftUI row body; do not add decorative layers, only the minimum service/store needed for async thumbnail preparation and cache lookup.
       - remove `UIImage(contentsOfFile:)`, `AVAssetImageGenerator.copyCGImage`, `PDFDocument(url:)`, and repeated `FileManager.fileExists` from row body/computed render paths in `./TchopApp/Views/News/NewsFeedView.swift`.
       - create stable placeholders with similar size to loaded previews to avoid scroll jumps.
       - cache by durable media file identity/card id and avoid full-resolution image retention in rows.
    7. Interaction update narrowing:
       - like/comment/display-mode updates should update one `FeedCard` and persist one record without rebuilding unrelated rows.
       - failure handling must not silently lose the optimistic UI state; if persistence fails, surface or revert intentionally.
    8. Visual rendering follow-up after media hot path removal:
       - review repeated `.clipShape(...)` and `.shadow(...)` on feed cards; simplify or gate if they still contribute to jank.
       - keep published feed UI semantics from the contract unchanged.
    9. Verification after implementation, only with user-approved command scope:
       - always run `git diff --check`.
       - run `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` if Xcode project changes.
       - build only if explicitly requested by user.
       - manual simulator/Instruments scroll validation is recommended for a true 100% smooth-scroll claim, but must be separately approved.


- Completed now: Phase 1 + Phase 2 feed-card remediation implementation pass:
  - replaced feed-card source-split naming across app/share/persistence from `LocalFeed*` / `SharedLocal*` to source-neutral `Feed*` naming.
  - removed `.local(...)` feed-card wrapper branches; feed card content wrappers now use source-neutral `.card(...)`.
  - replaced SwiftData `LocalFeedCardRecord` with source-neutral `FeedCardRecord` and removed the duplicate legacy remote feed record from the active SwiftData schema because the app is not released and migration compatibility is not blocking this cleanup.
  - renamed feed-card store/repository/shared sync manager and DI/view-model/share-extension plumbing to source-neutral names.
  - moved feed media preview work out of SwiftUI row body computed properties: image downsampling, video first-frame generation, PDF first-page thumbnails, and file existence checks now run through async preview loading with a bounded in-memory cache instead of synchronous row rendering.
  - replaced repeated `ForEach(Array(viewModel.visibleContent.cards), ...)` / repeated computed `visibleContent` reads with a precomputed visible feed snapshot in `NewsFeedViewModel` and direct `ForEach(visibleContent.cards, ...)`.
  - narrowed `NewsFeedCardRendererView` inputs so rows no longer receive the whole `NewsFeedViewModel`; rows receive source-neutral card data plus explicit callbacks.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded after fixes; no tests or simulator UI run.


- Completed now: targeted persistence and media import I/O cleanup follow-up:
  - changed `./TchopApp/ViewModels/AppShellViewModel.swift` so single-card like/comment/display-mode updates persist one `FeedCard` and update the affected in-memory row instead of rebuilding the whole feed array.
  - added a single-card persistence API in `./TchopApp/Repositories/AppContentRepository.swift`; build constraints forced the SwiftData lookup to remain warning-free rather than using `#Predicate`, but the store/update call path is now single-card scoped.
  - moved share-extension imported file copying in `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift` into a detached utility task so large share files are not copied on the main actor.
  - moved composer media data writes and document-picker file copies in `./TchopApp/Views/Composer/SharedCardComposerView.swift` into detached utility work where the API allows it; kept the synchronous Transferable import copy for the `FileRepresentation` closure because that closure is synchronous.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests/simulator UI/Instruments run.


- Completed now: share/app-group robustness and feed visual rendering cleanup:
  - added per-file safe JSON loading in `./Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift` so one corrupted pending share item no longer blocks all valid cards.
  - added targeted removal by successfully imported card IDs and quarantine for corrupted pending share JSON files under the app-group store.
  - changed `./TchopApp/Shared/SharedFeedCardSyncManager.swift` to sync valid pending feed cards, remove only processed files, and quarantine malformed files.
  - reduced repeated feed-row offscreen rendering cost in `./TchopApp/Views/News/NewsFeedView.swift` by replacing the per-card shadow with a cheap rounded border overlay.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests/simulator UI/Instruments run.


- Completed now: permanent production audit/review rules hardening before the read-only audit:
  - created `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as the mandatory concrete checklist and forbidden-pattern stop list.
  - updated `./docs/AGENT_RULES.md` so non-trivial implementation/refactor/cleanup/review must apply both production quality gates and the new checklist.
  - updated `./docs/CURRENT_USER_OVERRIDES.md` so audits must use the current checklist/rules as the standard before findings are produced.
  - updated `./docs/WORK_CONTINUITY.md` so the checklist and stop list survive context transfer.
  - updated `./docs/PRODUCTION_QUALITY_GATES.md` and `./docs/README.md` to include the new checklist in the active baseline.
- Verification: `git diff --check` succeeded; no build/test/simulator run because this is docs-only.


- Completed now: Full Read-Only Production Audit completed in one pass using the new production checklist and stop list:
  - Scope inspected: `./TchopApp`, `./TchopShareExtension`, `./Packages`, `./docs`, and `./.codex/skills/tchop-feed-cards`; `./TchopAppTests` was not touched. `./TchopWidgetExtension` does not exist as a source directory in this worktree; widget package code under `./Packages/TchopInfrastructure/Sources/TchopWidgets` was included.
  - Block A findings: auth/session still defaults to local stub/synthetic token runtime and has ReqRes/demo fallback paths that should not be the default production-shaped flow.
  - Block B findings: SwiftData repositories still use fetch-all/in-memory filtering for targeted user/feed-card updates; acceptable only as a temporary SwiftData warning workaround, not a long-term persistence shape.
  - Block C findings: root/menu/navigation composition is mostly sane, but feature tabs still expose sample/stub navigation and placeholder content as product-visible runtime.
  - Block D findings: infrastructure package still exposes mock/stub provider surfaces and synchronous file JSON/cache/queue APIs that are acceptable for package internals but need stricter production naming/isolation and async expectations where used by UI/app flows.
  - Block E findings: feed hot path is much improved, but `AnyView` remains in repeated feed rows, tap handling uses `onTapGesture` for card containers, composer still decodes images synchronously in view computed properties, and composer/share-extension user-visible strings include hardcoded English.
  - Remediation plan prepared for user review with P1/P2/P3 ordering; no implementation changes were made during the audit.
- Verification: `git diff --check` run after plan update; no build/test/simulator/Instruments run because audit was read-only plus task-plan update.


- Completed now: executed approved remediation blocks after Full Read-Only Production Audit:
  - Block 2/4: moved share/app-group pending import and composer image previews further away from main-thread/render-path file I/O; composer photo/teaser/fullscreen image previews now use async downsample/cache loading instead of `UIImage(contentsOfFile:)` computed properties.
  - Block 6: removed `AnyView` from repeated feed file-card rows, removed visible no-op refresh/update menu actions, and added `http`/`https` allowlist for feed source URLs.
  - Block 1/5: renamed default development auth environment away from silent `localStub` naming, changed synthetic development tokens away from `stub-*`, replaced app runtime `MockUIConfigurationRemoteProvider()` with production-safe `StaticUIConfigurationProvider()`, and removed `StubTabDetailView`/`stubDescription` naming from feature-tab runtime types.
  - Block 7: localized share-extension failure text and composer placeholder text through shared localization resources.
  - Block 3: attempted scoped SwiftData `#Predicate` fetches for targeted persistence, but Xcode StrictConcurrency produced Swift 6 `ReferenceWritableKeyPath` warnings; reverted to warning-free fetch-all temporary shape rather than leaving future Swift 6 errors. This remains the one explicitly constrained follow-up item.
  - Instruments: `xcrun xctrace list templates` succeeded and confirmed `SwiftUI`, `Time Profiler`, `Animation Hitches`, `File Activity`, and related templates are available. No trace was recorded because the user explicitly excluded simulator launch/manual exercise until the end.
- Verification: after the remediation pass `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded. A final build also succeeded after feature-tab naming cleanup. No tests/simulator UI/manual validation/Instruments trace recording were run.


- Completed now: simulator login unblock for Instruments/manual feed testing:
  - changed `./TchopApp/App/AppDIContainer.swift` so the `.developmentStub` runtime uses `InMemoryAuthTokenStore()` instead of Keychain storage, avoiding unsigned simulator secure-storage failures while keeping Keychain for external/staging/production environments.
  - rebuilt and reinstalled the app on the booted simulator.
- Verification: `./scripts/verify.sh low` passed; `git diff --check` passed.


- Completed now: simulator Time Profiler scroll capture attempt and analysis:
  - target-process and manually stopped simulator traces saved only `RunIssues.storedata`, so they were not usable for sample analysis.
  - captured a valid auto-stopped all-process Time Profiler trace at `./.zenflow/tasks/new-task-be0b/traces/tchop-feed-scroll-repeat.trace`.
  - exported analysis to `./.zenflow/tasks/new-task-be0b/traces/tchop-feed-scroll-repeat.analysis.json`.
  - findings: no `potential-hangs` >250ms; simulator does not provide Animation Hitches/SwiftUI lanes; TchopApp samples are overwhelmingly main-thread/AttributeGraph/scroll graph work, with visible cost from `NewsFeedScrollObserver` KVO / `AppShellViewModel.setNewsFeedNearTop(_:)` and no sampled evidence of synchronous media decoding during this run.
- Verification: Instruments trace analysis only; no build/test run for this analysis step.


- Completed now: Scroll Hot Path Remediation block 1-4:
  - changed `./TchopApp/Views/News/NewsFeedView.swift` so `NewsFeedScrollObserver` forwards only near-top threshold transitions instead of every `contentOffset` update, preserving the existing `+` button visibility threshold.
  - split `./TchopApp/Views/ShellContentView.swift` bottom chrome observation into `ShellBottomChromeHostView`, so `isNewsFeedNearTop` invalidates the bottom chrome host rather than the whole shell/feed subtree.
  - added lightweight feed signposts for `ScrollNearTopStateChange`, `FeedCardAppear`, `FeedMediaPreviewLoad`, and `FeedVisibleContentRefresh` in `./TchopApp/Views/News/NewsFeedView.swift` and `./TchopApp/ViewModels/NewsFeedViewModel.swift`.
  - cleaned unused app-group fallback error presentation assignments in `./TchopApp/App/AppDIContainer.swift` to remove build warnings from the current branch.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `** BUILD SUCCEEDED **`. No manual simulator UI or Instruments re-test was run in this block.


- Completed now: fixed `+` button hide/show regression from the scroll-hot-path cleanup:
  - replaced the prior UIKit/KVO threshold observer in `./TchopApp/Views/News/NewsFeedView.swift` with a SwiftUI top-offset sentinel scoped to the feed `ScrollView` coordinate space.
  - preserved edge-only behavior: shell callback still fires only when the top sentinel crosses the existing `30pt` threshold, not on every scroll frame.
  - restored feed card view declarations after the observer replacement and fixed the resulting compile errors.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `** BUILD SUCCEEDED **`. Manual UI validation of `+` hide/show is still needed.


- Completed now: fixed floating `+` hide/show regression after scroll optimization:
  - moved the feed scroll-position sentinel in `./TchopApp/Views/News/NewsFeedView.swift` out of `LazyVStack` into the stable scroll content wrapper so lazy eviction cannot reset the top-offset preference to the near-top default.
  - preserved lazy card rendering and edge-only `onScrollProximityChange` updates for shell button visibility.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `BUILD SUCCEEDED`.


- Completed now: hardened floating `+` visibility path after manual check still showed the button always visible:
  - `./TchopApp/Views/News/NewsFeedView.swift` now uses native `onScrollGeometryChange` on iOS 18+ for boolean near-top tracking, with the sentinel/preference path retained only as the iOS 17 fallback.
  - `./TchopApp/Views/ShellContentView.swift` now stores feed near-top visibility in local `@State` and passes the boolean directly into bottom chrome, avoiding an indirect nested-observation dependency for the floating button.
  - the signal remains edge-only: UI state changes only when crossing the near-top threshold, not on every scroll pixel.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `BUILD SUCCEEDED`.


- Completed now: corrected feed lazy rendering structure for production scroll performance:
  - removed the opaque `NewsFeedContentSectionView` wrapper from `./TchopApp/Views/News/NewsFeedView.swift`.
  - moved empty/search-empty states and `ForEach(visibleContent.cards, id: \.id)` directly into the primary `LazyVStack` under the `ScrollView`, so the lazy container lays out individual card rows instead of a single section child.
  - kept the iOS 18+ `onScrollGeometryChange` scroll tracking and iOS 17 fallback sentinel outside lazy card rows, preserving the `+` hide/show optimization path.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `BUILD SUCCEEDED`.


- Completed now: added permanent production review completeness documentation and trigger prompt:
  - added `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` with mandatory broad review gate, `ревью` trigger rule, checklist coverage, output contract, and stop rule for uncertainty.
  - added `./docs/agent-prompts/production-review-completeness.md` as the exact production-grade review prompt to run when the user asks for `ревью`/review/audit/production-ready validation.
  - updated `./docs/README.md`, `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, and `./docs/agent-prompts/README.md` to index and enforce this gate.
- Verification: `git diff --check` only; no build needed for documentation-only changes.


- Completed now: final `./TchopApp/Views/News/NewsFeedView.swift` cleanup after external review:
  - clarified the floating `+` threshold comment from top-card semantics to top-content-area semantics.
  - extracted card row construction into concrete `makeCardView(for:) -> NewsFeedCardRendererView` while keeping `ForEach` directly inside the primary `LazyVStack`.
  - verified `startTranslation` already clears `languageSelectionState` before launching translation work.
- Verification: `git diff --check` passed; `./scripts/verify.sh low` passed with `BUILD SUCCEEDED`.
- Profiling status: attempted new simulator Time Profiler captures after the cleanup (`attach`, `all-processes`, and PID attach paths), but the generated `./.zenflow/tasks/new-task-be0b/traces/tchop-feed-scroll-after-lazy-inline.trace` contains only `RunIssues.storedata` and fails `xctrace export` with `Document Missing Template Error`; no valid comparable post-change metrics were produced yet.


- Completed now: full 5-phase iOS production documentation/prompt/skill hardening pass:
  - Phase 1 docs hygiene: rewrote `./docs/README.md` into a clean active documentation index, removed duplicated/broken production checklist entries, and updated `./docs/WORK_CONTINUITY.md` with the new production review/readiness docs.
  - Phase 2 core production standards: added `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`, `./docs/IOS_TESTING_STRATEGY.md`, `./docs/IOS_SECURITY_PRIVACY_GATE.md`, `./docs/IOS_OBSERVABILITY_STANDARD.md`, and `./docs/IOS_RELEASE_CHECKLIST.md`.
  - Phase 3 specialized standards: added `./docs/IOS_ACCESSIBILITY_STANDARD.md`, `./docs/IOS_PERFORMANCE_BUDGETS.md`, `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`, `./docs/IOS_DATA_MIGRATION_STANDARD.md`, `./docs/DESIGN_SYSTEM_GOVERNANCE.md`, `./docs/DEFINITION_OF_DONE.md`, `./docs/CI_CD_QUALITY_GATES.md`, and `./docs/DEPENDENCY_POLICY.md`; added `./docs/knowledge/global/ios/README.md`.
  - Phase 4 prompt presets: added iOS production/readiness/performance/security/accessibility/migration/API/release/done prompts under `./docs/agent-prompts/` and indexed them in `./docs/agent-prompts/README.md`.
  - Phase 5 reusable skills: added local skills under `./.codex/skills/ios-production-auditor`, `./.codex/skills/ios-performance-profiler`, `./.codex/skills/ios-security-privacy`, `./.codex/skills/ios-accessibility`, `./.codex/skills/ios-release-engineering`, `./.codex/skills/ios-data-migration`, `./.codex/skills/ios-api-contracts`, and `./.codex/skills/ios-test-strategy`.
  - Updated `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, and `./docs/knowledge/global/README.md` to enforce and index the expanded production standards.
- Verification: `git diff --check` only; no build needed for documentation/skill-only changes.


- Completed now: enterprise-scale iOS production governance/docs/prompts/skills/static-gates hardening pass:
  - Added product/process governance standards: `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`, `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`, `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md`, `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`, `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`, `./docs/INCIDENT_RESPONSE_STANDARD.md`, `./docs/PRODUCT_HEALTH_SLO.md`, `./docs/RISK_REGISTER.md`, and `./docs/TECH_DEBT_REGISTER.md`.
  - Added enterprise iOS scale standards: `./docs/MODULAR_ARCHITECTURE_STANDARD.md`, `./docs/DEVELOPER_EXPERIENCE_STANDARD.md`, `./docs/QA_TEST_PLAN_STANDARD.md`, `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`, and `./docs/COMPATIBILITY_MATRIX.md`.
  - Added prompt presets for requirements, ADR, evidence-based completion, feature flags/rollouts, incidents, QA plans, localization, and platform capabilities under `./docs/agent-prompts/`, and indexed them in `./docs/agent-prompts/README.md`.
  - Added local operational skills: `./.codex/skills/ios-product-governance`, `./.codex/skills/ios-incident-ops`, `./.codex/skills/ios-modular-architecture`, `./.codex/skills/ios-qa-localization`, and `./.codex/skills/ios-evidence-gate`.
  - Added static quality gate scripts under `./scripts/`: docs index validation, forbidden/high-risk pattern scan, secret scan, large-file scan, localization scan, SwiftUI hot-path candidate scan, and aggregate runner.
  - Updated `./docs/README.md`, `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, `./docs/WORK_CONTINUITY.md`, `./docs/agent-prompts/README.md`, `./docs/knowledge/global/README.md`, and `./docs/knowledge/global/ios/README.md` so the new standards are part of the active baseline.
  - Removed a hard-coded ReqRes demo API-key fallback from `./scripts/api_method_trace`; the script now requires `TCHOP_REQRES_API_KEY` from environment when used.
- Verification: `python3 ./scripts/check_docs_index.py` succeeded; `git diff --check` succeeded; `./scripts/run_static_quality_gates.sh` now passes docs/secret/large-file checks but intentionally stops on remaining codebase findings from `./scripts/check_forbidden_patterns.py` and downstream review candidates from localization/SwiftUI scans that should be handled as remediation/audit items, not hidden.


- Completed now: generic, non-app-specific iOS production coverage expansion requested by user:
  - Added universal iOS standards for concurrency/runtime, memory/cache/media, UI state/rendering, network resilience, offline/sync, app lifecycle/background work, error handling/user feedback, analytics/telemetry taxonomy, configuration/environments, input validation/content safety, StoreKit/payments, and camera/photos/files/permissions.
  - Added `./docs/STATIC_QUALITY_GATE_POLICY.md` to define hard fail vs warning vs review candidate vs allowed exception for static scripts.
  - Added prompt presets for generic iOS concurrency, memory/cache/media, UI state/rendering, network resilience, offline/sync, lifecycle/background, error handling, configuration/environments, and input-validation/content-safety reviews.
  - Added local skills for generic iOS concurrency/runtime, memory/cache/media, network resilience, offline/sync, lifecycle/background, error handling, configuration/environments, and input validation.
  - Updated active indexes/rules in `./docs/README.md`, `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, `./docs/WORK_CONTINUITY.md`, `./docs/agent-prompts/README.md`, and `./docs/knowledge/global/ios/README.md`.
- Verification: `python3 ./scripts/check_docs_index.py` succeeded with 101 indexed paths; `git diff --check` succeeded. Full `./scripts/run_static_quality_gates.sh` still stops on existing app/code findings from `./scripts/check_forbidden_patterns.py`; those are app/project remediation candidates and were intentionally not fixed in this generic-docs pass.


- Completed now: finalized the generic reusable iOS production framework layer:
  - Added `./docs/IOS_PRODUCTION_FRAMEWORK.md` as the canonical umbrella framework with layers, workflow, coverage matrix, and completion rule.
  - Added operating documents: `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`, `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`, `./docs/IOS_PR_REVIEW_TEMPLATE.md`, `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`, `./docs/IOS_AGENT_PROMPT_ROUTER.md`, `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`, `./docs/IOS_PRODUCTION_SCORECARD.md`, and `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`.
  - Added `./scripts/validate_ios_production_framework.py` and wired it into `./scripts/run_static_quality_gates.sh`, so the reusable framework now has an automated completeness check.
  - Updated `./docs/README.md`, `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, and `./docs/knowledge/global/ios/README.md` to route generic iOS work through the full framework instead of loose individual standards.
- Verification: `python3 ./scripts/check_docs_index.py` succeeded with 111 indexed paths; `python3 ./scripts/validate_ios_production_framework.py` succeeded with 49 required files present; `git diff --check` succeeded. Full `./scripts/run_static_quality_gates.sh` now confirms docs/framework/secret/large-file gates before stopping on existing app-code forbidden-pattern findings, which remain outside this generic-framework pass.


- Completed now: added the generic iOS inline code documentation standard requested by user:
  - Added `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md` with the rule to document contracts, not obvious code.
  - The standard explicitly includes runtime ownership/created-by information for key entities and stable external usage/call context for methods used outside their declaring type, while avoiding fragile exhaustive caller lists unless the caller is contractual.
  - Added `./docs/agent-prompts/ios-code-documentation-review.md` and `./.codex/skills/ios-code-documentation/SKILL.md`.
  - Indexed the new standard/prompt/skill in `./docs/README.md`, `./docs/IOS_PRODUCTION_FRAMEWORK.md`, `./docs/agent-prompts/README.md`, `./docs/AGENT_RULES.md`, `./docs/CURRENT_USER_OVERRIDES.md`, `./docs/knowledge/global/ios/README.md`, and `./scripts/validate_ios_production_framework.py`.
- Verification: `python3 ./scripts/check_docs_index.py` succeeded with 113 indexed paths; `python3 ./scripts/validate_ios_production_framework.py` succeeded with 52 required files present; `git diff --check` succeeded.


- Completed now: propagated inline code documentation rules into the active review/done gates:
  - Updated `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` with a mandatory Code Documentation Contracts section and a forbidden-pattern stop list for noisy/fragile/unsupported comments.
  - Updated `./docs/DEFINITION_OF_DONE.md` so code documentation contracts must be updated when public/internal APIs, ownership/lifecycle, external usage, side effects, concurrency, errors, invariants, or temporary workarounds change.
  - Updated `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` so production reviews check code documentation quality and do not treat missing/fragile contract comments as invisible.
- Verification: `python3 ./scripts/check_docs_index.py` succeeded with 113 indexed paths; `python3 ./scripts/validate_ios_production_framework.py` succeeded with 52 required files present; `git diff --check` succeeded.


- Completed now: full-project inline code documentation pass requested by user:
  - Scope covered all Swift source/test targets under `./TchopApp`, `./TchopShareExtension`, `./Packages/TchopInfrastructure`, and `./TchopAppTests`; generated/build artifacts were excluded.
  - Added/updated contract comments for feed/composer models, feed/composer view models, share-extension bridge/runtime, shared app-group sync/session managers, app repositories/errors, reusable package sync core, on-device AI, share support, UI configuration/branding/database/error APIs, and test suites/test DTOs.
  - Applied `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`: comments document contracts, ownership/lifecycle, external usage/call context, side effects, concurrency, invariants, and rationale where relevant; avoided adding comments to trivial private implementation details unless they were detected as externally meaningful declarations.
  - Added a static documentation coverage scan for this pass and verified all declarations plus public/internal functions in app/package/extension/test Swift files have nearby documentation comments after the pass.
- Verification: `git diff --check` succeeded; `./scripts/verify.sh low` succeeded with `BUILD SUCCEEDED`; custom Swift documentation scan succeeded. `swift test` in `./Packages/TchopInfrastructure` was also attempted and failed on a pre-existing package test compile issue (`AppGroupJSONItemDirectoryStore<TestItem>` has no `remove(id:)` member in `./Packages/TchopInfrastructure/Tests/TchopShareSupportTests/TchopShareSupportTests.swift:23`) plus existing warnings; this was not fixed because the current task was documentation-only.


- Completed now: fixed the package test compile failure found by `swift test` in `./Packages/TchopInfrastructure`:
  - added `remove(id:)` convenience API to `./Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift`, delegating to the existing batch removal contract so `TchopShareSupportTests` can express single-item removal without duplicating array setup.
  - restored the expected concrete error-mapper convenience surface in `./Packages/TchopInfrastructure/Sources/TchopErrors/TchopErrors.swift` by adding an `APIError` overload and default `context` arguments where the existing tests call the mapper directly.
  - updated `./Packages/TchopInfrastructure/Tests/TchopLocalizationTests/TchopLocalizationTests.swift` expectations to match the current localization resources for `login.title` (`Welcome back` / `С возвращением`).
- Verification: `git diff --check` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 52 XCTest tests and 20 Swift Testing tests; `./scripts/verify.sh low` succeeded with `BUILD SUCCEEDED`. Remaining non-blocking warnings are Swift concurrency warnings in networking/package-test code and should be handled in a dedicated Swift 6/concurrency cleanup pass.


- Completed now: Swift concurrency / Swift 6 warning cleanup for `./Packages/TchopInfrastructure`:
  - constrained `TaskBox` in `./Packages/TchopInfrastructure/Sources/TchopNetworking/TchopNetworking.swift` to `Response: Sendable`, matching the `APIRequest`/`Task` call sites that already require sendable response values.
  - made database operation closures in `./Packages/TchopInfrastructure/Sources/TchopDatabaseCore/TchopDatabaseCore.swift` explicitly `@Sendable` and adjusted the SwiftData operation wrapper so the strict-concurrency boundary is expressed in the API contract.
  - removed deprecated `Locale.languageCode` fallbacks from `./Packages/TchopInfrastructure/Sources/TchopLocalization/TchopLocalization.swift` and `./Packages/TchopInfrastructure/Sources/TchopOnDeviceAI/TchopOnDeviceAI.swift`.
  - changed share text import in `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift` so non-sendable `NSSecureCoding` payloads are decoded inside the provider callback and only sendable `ShareImportedTextItem` values cross the async continuation boundary.
  - replaced the Core Data test merge-policy global with an explicit `NSMergePolicy` instance in `./Packages/TchopInfrastructure/Tests/TchopDatabaseTests/TchopDatabaseTests.swift`.
  - replaced mutable static URL protocol test state in `./Packages/TchopInfrastructure/Tests/TchopNetworkingTests/TchopNetworkingTests.swift` with a locked sendable state holder and locked counter helpers for sendable request-handler closures.
- Verification: clean `swift test` in `./Packages/TchopInfrastructure` succeeded with no Swift compiler warnings in the captured warning grep; regular `swift test` succeeded with 52 XCTest tests and 20 Swift Testing tests; `git diff --check`, `python3 ./scripts/check_docs_index.py`, `python3 ./scripts/validate_ios_production_framework.py`, and `./scripts/verify.sh low` all succeeded. Xcode build still prints a non-code AppIntents metadata note/warning for the share extension because it has no AppIntents dependency.


- Completed now: removed the remaining Xcode AppIntents metadata warning from share-extension builds:
  - updated `./TchopApp.xcodeproj/project.pbxproj` so all `TchopShareExtension` build configurations pass `-Xfrontend -disable-autolink-framework -Xfrontend AppIntents` through `OTHER_SWIFT_FLAGS`.
  - reason: the share extension does not use AppIntents, but Xcode was still running `ExtractAppIntentsMetadata` and warning that `AppIntents.framework` was not linked.
  - avoided adding an unused `AppIntents.framework` dependency to the extension binary.
- Verification: `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, `git diff --check`, and `./scripts/verify.sh low` succeeded; captured build log no longer contains `Metadata extraction skipped` or `warning:` entries.


- Active now: full app test coverage expansion phase opened by user on 2026-05-26:
  - goal: cover the whole app at a sufficient level, starting with all packages/managers and then app-specific code.
  - existing tests should be reused, updated, or extended where practical; new tests should be added where coverage gaps remain.
  - temporary override: `./TchopAppTests` is allowed to be modified until the user explicitly says to stop writing tests; after that command, the previous no-touch rule returns automatically.
  - verification expectation: after each coherent test block, run relevant package tests/builds plus `git diff --check`; simulator UI remains disabled unless explicitly requested.


- Completed now: package and app test coverage expansion pass:
  - expanded `./Packages/TchopInfrastructure` test coverage across SyncCore, Apple authentication, navigation, branding, cache, share support, localization, and app-error mapping surfaces.
  - realigned `./TchopAppTests` with the current source-neutral feed-card runtime and SwiftData-only active persistence policy; removed stale remote feed repository/DTO assumptions from test doubles and feed view-model tests.
  - added/updated app tests for feed channel scoping/search/interactions, app session restore/sign-out/widget clearing, navigation snapshot restore/migration/future-version handling, database bootstrap policy, app DI, login validation/error mapping, deep links, user repository, and feed-card persistence.
  - updated `./TchopAppUITests/TchopAppUITests.swift` to match the current localized password-visibility accessibility label.
  - fixed app runtime issues surfaced by tests: login unknown errors now use the app login-generic localized message through `AppRuntimeErrorMessageCatalog`, and `DefaultAppContentRepository` now returns channels in stable product order instead of raw SwiftData fetch order.
- Verification: `git diff --check` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests; full `xcodebuild ... test` for `./TchopApp.xcodeproj`/`TchopApp` on iPhone 17 Pro iOS 26.0 succeeded; `./scripts/verify.sh medium` succeeded, including package tests, app/UI tests, and final debug build.


- Completed now: continued app-specific test coverage expansion after reconnect:
  - added `./TchopAppTests/AppShellViewModelTests.swift` and `./TchopAppTests/ShareExtensionRuntimeContractTests.swift` to the `TchopAppTests` Xcode target so existing test files are actually compiled and executed.
  - updated `./TchopAppTests/ShareExtensionRuntimeContractTests.swift` from stale `Local*` names to the current source-neutral `FeedCard` / `SharedFeedCardSyncManager` runtime.
  - added share/composer contract tests for 10-photo cap, incompatible media import errors, empty draft publish rejection, 200-character imported text limit, file-media caption/teaser metadata publishing, and app-group pending-card sync into `FeedCardStore`.
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` coverage for canonical search-field order: `text`, `headline`, `subheadline`, `source`.
  - added a test-only injection initializer to `./TchopApp/Shared/SharedFeedCardSyncManager.swift` so app-group sync can be tested without a real app-group entitlement.
  - fixed `./TchopAppTests/AppShellViewModelTests.swift` setup now that `UIConfigurationSnapshot` requires an explicit shell configuration.
- Verification: `git diff --check` succeeded; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded; full `xcodebuild ... test` for `./TchopApp.xcodeproj`/`TchopApp` on iPhone 17 Pro iOS 26.0 succeeded with the newly enabled tests; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests.


- Completed now: continued app-specific test coverage expansion and full verification stabilization:
  - added app launch configuration tests in `./TchopAppTests/AppStateTests.swift` for UI-test in-memory SwiftData configuration and ReqRes external-auth environment resolution.
  - added `SessionStore` transition coverage in `./TchopAppTests/AppStateTests.swift` to verify current-user exposure across signed-out/authenticated transitions.
  - added `ProfileTabViewModel` coverage in `./TchopAppTests/AppShellViewModelTests.swift` for current-user summary sync plus navigation-restore preference optimistic success and rollback failure behavior.
  - made profile and login error tests use deterministic test error managers instead of full async/localization error-mapping paths, keeping unit tests focused and parallel-stable.
  - converted `LoginViewModelTests.testSubmitTrimsWhitespaceBeforeLogin()` to async polling instead of an XCTest expectation under `@MainActor`, fixing a full-suite signal-trap flake while preserving the production behavior assertion.
- Verification: `git diff --check` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded.


- Completed now: feed/card runtime and composer contract test expansion:
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` coverage for whitespace-only search, multi-token same-field matching, equal-priority stable search ordering, search dismissal restoring the selected-channel snapshot, duplicate feed-card sync no-op behavior, targeted single-card update persistence, and missing-card update no-op behavior.
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` persistence coverage for `FeedCardRepository.saveCard` inserting a missing record and `loadCards()` returning cards newest-first by `createdAt`.
  - extended `./TchopAppTests/TestDoubles/TestAppContentRepository.swift` to record single-card saves separately from batch saves, allowing tests to verify targeted persistence rather than broad batch writes.
  - added `./TchopAppTests/ShareExtensionRuntimeContractTests.swift` composer contract coverage for required text behavior without media, removable text when media carries the draft, media removal making text required again, source URL publishing only with visible source text, and photo metadata publishing only non-empty fields.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedViewModelTests -only-testing:TchopAppTests/AppContentRepositoryTests test` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/ShareExtensionRuntimeContractTests test` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` and `git diff --check` succeeded.


- Completed now: AppState/navigation/auth lifecycle test expansion:
  - added `./TchopAppTests/AppStateTests.swift` coverage for unauthenticated deep-link queuing, latest-pending-link replacement, authenticated immediate deep-link routing, failed sign-in not replaying pending links, restore failure falling back to signed-out state, opt-in navigation snapshot persistence, clean snapshot restore without persistence feedback loop, and disabling navigation restore clearing persisted snapshot plus resetting navigation.
  - added `RecordingDeepLinkManager` and navigation save-call tracking in `./TchopAppTests/TestDoubles/AppStateTestDoubles.swift` so routing and snapshot persistence side effects are asserted directly.
  - fixed a production runtime issue surfaced by the new restore-failure test: `./TchopApp/App/AppState.swift` no longer traps with `assertionFailure` on recoverable session-restore errors; it maps the error through the app error manager and safely falls back to signed-out state.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/AppStateTests test` first exposed the restore-failure trap, then succeeded after the runtime fix; `git diff --check` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded.


- Completed now: channel/login/session-manager test coverage expansion:
  - added `./TchopAppTests/AppStateTests.swift` coverage for `ChannelsStore` ordering, persisted-selection priority, invalid selection fallback, unknown channel rejection, and reset semantics that clear user selection without destroying the available channel snapshot.
  - added `./TchopAppTests/AppStateTests.swift` coverage for `UserChannelSettingsRepository` ReqRes user normalization and default channel settings for unknown users.
  - added `./TchopAppTests/LoginViewModelTests.swift` coverage for password visibility, weak default-password blocking, ReqRes registration routing, default-mode registration no-op behavior, submission throttling, Apple authorization cancellation, and Apple authorization failure error mapping.
  - added `./TchopAppTests/AppStateTests.swift` coverage for `UserSessionService` token-backed sign-in persistence, token rollback when local user resolution fails, orphan-token cleanup, expired-token refresh, missing-refresh-token cleanup, and sign-out revoke semantics.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/ChannelsStoreTests -only-testing:TchopAppTests/UserChannelSettingsRepositoryTests test` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/LoginViewModelTests test` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/UserSessionServiceTests test` first exposed a missing test import and then succeeded after adding `TchopAppleAuthentication`; `git diff --check` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `swift test` in `./Packages/TchopInfrastructure` succeeded with 59 XCTest tests and 37 Swift Testing tests; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded.


- Completed now: bridge and feed-card model contract test expansion:
  - added `./TchopAppTests/AppStateTests.swift` coverage for widget feed sync save/empty/clear behavior, widget sync failure reporting, APNs token forwarding, registration failure forwarding, remote notification payload forwarding, and push-manager failure reporting.
  - fixed recoverable bridge failure behavior in `./TchopApp/App/AppWidgetBridge.swift` and `./TchopApp/App/AppPushNotificationBridge.swift`: widget/push bridge failures now go through `AppErrorManaging` without debug/test `assertionFailure` traps.
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` `NewsFeedModelContractTests` coverage for composer text ordering/trimming, legacy persisted `FeedCard` interaction defaults, translation payload trimming/source exclusion, nil channel scoping, detail-route fallback fields, and media display-title contracts.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/AppBridgeTests test` first exposed an expected localized-description assertion mismatch and then succeeded after fixing the test expectation; targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedModelContractTests test` first exposed a malformed string literal in the new test and then succeeded after fixing it; final `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, and `swift test` in `./Packages/TchopInfrastructure` all succeeded.


- Completed now: app-specific shell/composer/action-coordinator test expansion:
  - added `./TchopAppTests/AppShellViewModelTests.swift` coverage for menu toggle/close, composer presentation using the selected channel, channel selection refreshing feed scope and syncing share-extension session context, and composer publishing refreshing the feed plus dismissing the active composer.
  - added a test-only file-manager injection initializer to `./TchopApp/Shared/ShareExtensionSessionContextManager.swift` so app-group session context can be verified without real entitlements.
  - fixed recoverable UI-configuration refresh failure behavior in `./TchopApp/ViewModels/AppShellViewModel.swift`: refresh errors now go through `AppErrorManaging` without debug/test `assertionFailure` traps.
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` coverage for `NewsFeedCardActionCoordinator` queued additive actions, per-card clear semantics, and `cancelAll()` task cancellation/queue cleanup.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/AppShellViewModelTests test` first exposed a missing test file-manager double, then succeeded after adding a local double; targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedCardActionCoordinatorTests test` succeeded; final `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, and `swift test` in `./Packages/TchopInfrastructure` all succeeded.


- Completed now: app-specific shell error and composer view-model contract test expansion:
  - added `./TchopAppTests/AppShellViewModelTests.swift` coverage that failed UI-configuration refreshes are reported through `AppErrorManaging` while preserving the cached shell `showsFloatingActionButton` state.
  - made the app-shell test factory accept an injected `AppErrorManaging` instance so shell error side effects can be asserted without production reporting.
  - added `./TchopAppTests/ShareExtensionRuntimeContractTests.swift` `FeedComposerViewModelTests` coverage for empty publish no-op behavior, source-neutral text-card publishing, channel/title sourcing from `ChannelsStore`, and draft field visibility mutations through the view-model surface.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/AppShellViewModelTests test` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/FeedComposerViewModelTests test` succeeded; final `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, and `swift test` in `./Packages/TchopInfrastructure` all succeeded.


- Completed now: launch-configuration and share-extension session-context test expansion:
  - added `./TchopAppTests/AppStateTests.swift` coverage for default launch configuration, UI-test authenticated-session flags, invalid initial URL handling, and ReqRes external-auth default API-key behavior.
  - added `./TchopAppTests/ShareExtensionRuntimeContractTests.swift` `ShareExtensionSessionContextManagerTests` coverage for authenticated session context round-trip through app-group JSON storage and signed-out context scrubbing of channel details.
- Verification: targeted `xcodebuild ... -only-testing:TchopAppTests/AppLaunchConfigurationTests test` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/ShareExtensionSessionContextManagerTests test` succeeded; final `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, and `swift test` in `./Packages/TchopInfrastructure` all succeeded.

- Completed now: P0 feed/composer/FAB UI regression coverage:
  - made `./TchopApp/App/AppDIContainer.swift` use deterministic UI-test UI configuration by avoiding persisted standard `UserDefaults` shell configuration in UI-test mode, so tests cannot inherit a hidden floating action button from previous runtime state.
  - added stable UI-test identifiers in `./TchopApp/Views/Composer/SharedCardComposerView.swift` for composer root, body input, and publish/cancel actions.
  - kept `./TchopApp/Views/Tabs/FloatingActionButton.swift` visual glass styling intact while preserving a stable accessibility identifier and adding XCTest label fallbacks for iOS 26 Liquid Glass exposure behavior.
  - hardened `./TchopApp/Views/News/NewsFeedView.swift` scroll/FAB proximity handling: empty feed keeps the plus button visible, iOS 18+ uses native scroll geometry, and older systems keep the preference-key fallback.
  - added `./TchopAppUITests/TchopAppUITests.swift` P0 UI tests for authenticated text-card publish into feed and feed scroll hide/restore behavior for the shell plus button.
- Verification: targeted UI tests for `testAuthenticatedUserCanPublishTextCardIntoFeed` and `testFeedScrollHidesAndRestoresFloatingActionButton` succeeded; `git diff --check` succeeded; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded; `(cd ./Packages/TchopInfrastructure && swift test)` succeeded with 59 XCTest tests and 37 Swift Testing tests; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded.

- Completed now: feed MVVM contract hardening for scalable growth without speculative layers:
  - added `NewsFeedAction` in `./TchopApp/ViewModels/NewsFeedViewModel.swift` so feed UI/shell events enter the view model as product/user intents instead of direct mutation helper calls.
  - added `NewsFeedScreenState` in `./TchopApp/ViewModels/NewsFeedViewModel.swift` so `./TchopApp/Views/News/NewsFeedView.swift` reads one cheap screen-level presentation snapshot per SwiftUI body pass.
  - made feed mutation/refresh/search/channel-change implementation methods private behind `send(_:)` / `sendAndWait(_:)`, keeping async refresh/translation awaitable for lifecycle-bound callers.
  - updated `./TchopApp/Views/News/NewsFeedView.swift`, `./TchopApp/Views/ShellContentView.swift`, `./TchopApp/ViewModels/AppShellViewModel.swift`, and `./TchopApp/App/AppState.swift` to use the action contract where feed events cross component boundaries.
  - updated `./TchopAppTests/NewsFeedViewModelTests.swift` to exercise feed interactions/search/channel changes through the new action surface.
- Verification: first targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedViewModelTests test` exposed a Swift concurrency isolation issue in `NewsFeedViewModel.deinit`; removed the unsafe deinit access and reran successfully. Final verification succeeded with `git diff --check`, targeted `NewsFeedViewModelTests`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `(cd ./Packages/TchopInfrastructure && swift test)`.



- Completed now: first-step feed card view-state boundary:
  - added `NewsFeedCardViewState`, `NewsFeedCardActionViewState`, and `NewsFeedCardTranslationViewState` in `./TchopApp/ViewModels/NewsFeedViewModel.swift`.
  - extended `NewsFeedScreenState` with `cardStates`, so `./TchopApp/Views/News/NewsFeedView.swift` renders rows from a prepared presentation snapshot instead of rebuilding translation/action/footer decisions in the view tree.
  - changed `NewsFeedCardRendererView` in `./TchopApp/Views/News/NewsFeedView.swift` to consume `NewsFeedCardViewState`; route, rendered card, footer action state, and translation presentation now come from the view-model snapshot.
  - moved feed action footer labels/state into `NewsFeedCardActionViewState` while keeping existing text/photo/video/audio/pdf renderers intact.
  - added `./TchopAppTests/NewsFeedViewModelTests.swift` assertions for the new screen/card-state action contract.
- Verification: `git diff --check` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedViewModelTests test` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded; `(cd ./Packages/TchopInfrastructure && swift test)` succeeded.



- Completed now: feed screen-state presentation branching cleanup:
  - added `NewsFeedContentPresentation` in `./TchopApp/ViewModels/NewsFeedViewModel.swift` so empty/search-empty/cards branching is part of the screen-state snapshot instead of being recomputed in `./TchopApp/Views/News/NewsFeedView.swift`.
  - added `hasVisibleCards` to `NewsFeedScreenState` so scroll/FAB proximity handling no longer reads `viewModel.visibleContent` from the scroll callback path.
  - updated `./TchopApp/Views/News/NewsFeedView.swift` to keep `ForEach` directly inside the main `LazyVStack` while switching on `screenState.contentPresentation`.
  - removed the duplicate `@ViewBuilder` annotation from `NewsFeedScrollProximityModifier` while preserving native iOS 18 scroll-geometry handling and iOS 17 preference fallback behavior.
  - extended `./TchopAppTests/NewsFeedViewModelTests.swift` coverage for empty, no-results, card-list presentation, `hasVisibleCards`, and first-step card accessibility summary state.
- Verification: first targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedViewModelTests test` exposed a missing `return` in `NewsFeedViewModel.screenState`; fixed it and reran targeted tests successfully. Final verification succeeded with `git diff --check`, targeted `NewsFeedViewModelTests`, full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `(cd ./Packages/TchopInfrastructure && swift test)`.



- Completed now: feed translation tap behavior presentation-state cleanup:
  - added `NewsFeedCardTranslationTapBehavior` in `./TchopApp/ViewModels/NewsFeedViewModel.swift` to encode restore-original, direct one-language translation, and language-picker behavior in card presentation state.
  - changed `NewsFeedCardTranslationViewState` to expose `tapBehavior` instead of leaking target-language decision logic into `./TchopApp/Views/News/NewsFeedView.swift`.
  - simplified `NewsFeedView.handleTranslationTap` so the view only performs UI effects: send restore action, start async translation, or present the language picker.
  - added deterministic `TestOnDeviceAIManager` support and translation tap-behavior assertions in `./TchopAppTests/NewsFeedViewModelTests.swift`.
- Verification: `git diff --check` succeeded; targeted `xcodebuild ... -only-testing:TchopAppTests/NewsFeedViewModelTests test` succeeded; full `xcodebuild -project ./TchopApp.xcodeproj -scheme TchopApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO test` succeeded; `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded; `(cd ./Packages/TchopInfrastructure && swift test)` succeeded.




- Completed now: documentation/rules update for generic SwiftUI view model ownership and restored test-writing ban:
  - added a reusable decision rule in `./docs/IOS_UI_STATE_RENDERING_STANDARD.md` for when any view should receive a dedicated model/view model versus narrow immutable `ViewState` plus callbacks.
  - hardened `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` and `./docs/AGENT_RULES.md` to block speculative per-view models that only mirror parent input or exist for pattern symmetry.
  - updated `./docs/CURRENT_USER_OVERRIDES.md` to restore the no-test-writing/no-test-file-touch rule until the user explicitly allows tests again.
- Verification: docs/static check only; `git diff --check` succeeded; no build/tests/simulator run because this was documentation-only and the test-writing ban is active.



- Completed now: documentation split/export baseline for future projects:
  - created `./docs/documentation-split/app-specific/` with TchopApp-specific docs, task docs, feed/card contracts, Tchop package skills, app-specific prompt/knowledge files, and manifest.
  - created `./docs/documentation-split/reusable/` with non-app-specific iOS production standards, prompt presets, generic iOS skills, reusable user/agent preferences, porting guide, and manifest.
  - kept active canonical docs in place; the split folder is an export/staging area and does not replace `./docs`, `./.codex/skills`, or task docs.
  - updated `./docs/README.md` so the split/export baseline is indexed.
- Verification: `git diff --check` succeeded; documentation index check was run; no build/tests/simulator run because this is documentation-only and the test-writing ban is active.

## Verification Status
- Latest verification succeeded with `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, full `xcodebuild ... test` for `./TchopApp.xcodeproj`/`TchopApp`, targeted `NewsFeedViewModelTests`, targeted P0 UI tests for composer publish and feed scroll/FAB behavior, and `swift test` in `./Packages/TchopInfrastructure`.
- Package tests currently pass with 59 XCTest tests and 37 Swift Testing tests.
- App/unit/UI tests currently pass on iPhone 17 Pro iOS 26.0 with app-shell/share-extension runtime tests plus launch/session/profile/login/feed/persistence/composer contract coverage, P0 feed/composer/FAB UI regressions, feed MVVM action/screen-state contract coverage, first-step feed-card view-state boundary coverage, feed screen-state presentation branching coverage, and feed translation tap-behavior state coverage.
- Build and tests were run by explicit user permission/request; no manual simulator UI flow or Instruments trace was run in this block.

## Archive
Detailed historical plan/log entries were moved out of the active plan to reduce context cost.
Global reusable knowledge and TchopApp-specific knowledge are now split under `./docs/knowledge/`.

Use archives only when historical detail is needed:
- `./.zenflow/tasks/new-task-be0b/archive/plan.before-cleanup-2026-05-20.md`
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`

- Completed now: removed legacy remote/stub feed runtime surface from app/feed composition:
  - simplified `./TchopApp/Repositories/AppContentRepository.swift` to channel resolution plus feed card SwiftData persistence only; removed remote feed refresh/action sync helpers and network reachability dependency.
  - removed unused `FeedAPIManager` stub/DTO/action helper runtime and its Xcode project source references.
  - removed app DI wiring for `FeedAPIManaging` and `NetworkAvailabilityChecking`.
  - removed `NewsFeedPhotoCardContent.remote` / `NewsFeedTextCardContent.remote` cases and matching renderer no-op branches; feed card variants now carry local published cards only.
  - removed unused legacy remote feed action/state payload structs while leaving `FeedCardRecord` schema in place for migration/backward-compatibility safety.
- Verification: `git diff --check` and `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` only; no build/test/simulator run per current instruction.

- Completed now: build-backed follow-up cleanup across the three requested checks:
  - initial `./scripts/verify.sh low` succeeded before further cleanup.
  - static compile-surface review found no remaining `FeedAPIManager`, `FeedAPIManaging`, `StubFeed`, `NewsFeedRepository`, or `.remote(...)` feed-card runtime references.
  - persistence leftovers review kept `FeedCardRecord` in the SwiftData schema for migration/backward-compatibility safety and clarified comments in `./TchopApp/Persistence/AppContentRecord.swift`; active runtime remains `FeedCardRecord`.
  - removed legacy UI-only remote card views/models from `./TchopApp/Views/News/PhotoCardView.swift`, `./TchopApp/Views/News/TextCardView.swift`, `./TchopApp/Views/News/PhotoActionView.swift`, `./TchopApp/Models/NewsFeedModels.swift`, and related preview samples/project references.
  - fixed share-extension publish/concurrency warnings by aligning `./TchopShareExtension/ShareViewController.swift` with boolean `publish()` and marking `NSItemProviderShareItemImporter` main-actor isolated in `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and final `./scripts/verify.sh low` all succeeded; no tests/simulator UI run.

- Completed now: static end-to-end review of local-created feed card flow:
  - verified app composer publish path writes `ChannelCardContent.feedCardModel` into `FeedCardStore`, then persists via `FeedCardRepository`/SwiftData `FeedCardRecord`.
  - verified feed visibility is channel-scoped through `NewsFeedViewModel.visibleContent` and all five feed card kinds render through `NewsFeedView` feed card branches.
  - verified like/comment/display-mode mutations update `FeedCardStore.updatePersistedCard` and re-save the full `FeedCard` payload, preserving state across restart.
  - verified share extension publishes pending feed cards through `SharedFeedCardSyncManager` and app refresh pulls them into the same `FeedCardStore` path.
  - applied one contract fix in `./TchopApp/Models/NewsFeedModels.swift`: composer visible text fields now use canonical order `text`, `headline`, `subheadline`, `source`, matching published feed/feed card ordering.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests/simulator UI run.
