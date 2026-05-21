# Current Plan

## Goal
Keep `TchopApp` implementation and documentation aligned with the current product contract while minimizing unnecessary complexity, context churn, and verification cost.

## Active Focus
- Feed/composer/card runtime for `text`, `photo`, `video`, `audio`, `pdf`.
- Documentation/rules are now part of the active working baseline.
- Current user overrides are canonical for this task and live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Active Steps
No open implementation step is currently queued in this plan.

## Current Working Baseline
- Use `GPT-5.5` for this worktree/task unless the user explicitly changes the model.
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

## Verification Status
- Latest verification succeeded with `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low`.
- Build was run by explicit user request; tests and simulator UI were not run.

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
