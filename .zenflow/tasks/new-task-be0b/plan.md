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
  - made `./TchopApp/ViewModels/AppShellViewModel.swift` require an explicit `LocalFeedCardPersisting` repository for `LocalFeedCardStore`, preventing accidental memory-only production feed persistence.
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
  - step 1 legacy localization/resource cleanup: removed unused `news.fallback.*`, `news.photo.pending.*`, and `news.text.pending.*` localization keys from active English/Russian resources; added active `news.local.sourceFallback` in English/Russian/German and switched local card source fallback to that key in `./TchopApp/Models/NewsFeedModels.swift`.
  - step 2 static UX edge-case review: verified empty-feed state, channel-scoped search filtering, source-only translation suppression, source URL tap gating, media-only spacing/action bar behavior, and action toolbar isolation from card-detail tap handling.
  - step 4 context/package cleanup: refreshed active documentation/handoff references so they no longer point at removed remote/stub feed runtime files such as `FeedAPIManager`, `PhotoActionView`, `PhotoCardView`, or `TextCardView`.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests or simulator UI run.

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
  - simplified `./TchopApp/Repositories/AppContentRepository.swift` to channel resolution plus local feed-card SwiftData persistence only; removed remote feed refresh/action sync helpers and network reachability dependency.
  - removed unused `FeedAPIManager` stub/DTO/action helper runtime and its Xcode project source references.
  - removed app DI wiring for `FeedAPIManaging` and `NetworkAvailabilityChecking`.
  - removed `NewsFeedPhotoCardContent.remote` / `NewsFeedTextCardContent.remote` cases and matching renderer no-op branches; feed card variants now carry local published cards only.
  - removed unused legacy remote feed action/state payload structs while leaving `FeedCardRecord` schema in place for migration/backward-compatibility safety.
- Verification: `git diff --check` and `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` only; no build/test/simulator run per current instruction.

- Completed now: build-backed follow-up cleanup across the three requested checks:
  - initial `./scripts/verify.sh low` succeeded before further cleanup.
  - static compile-surface review found no remaining `FeedAPIManager`, `FeedAPIManaging`, `StubFeed`, `NewsFeedRepository`, or `.remote(...)` feed-card runtime references.
  - persistence leftovers review kept `FeedCardRecord` in the SwiftData schema for migration/backward-compatibility safety and clarified comments in `./TchopApp/Persistence/AppContentRecord.swift`; active runtime remains `LocalFeedCardRecord`.
  - removed legacy UI-only remote card views/models from `./TchopApp/Views/News/PhotoCardView.swift`, `./TchopApp/Views/News/TextCardView.swift`, `./TchopApp/Views/News/PhotoActionView.swift`, `./TchopApp/Models/NewsFeedModels.swift`, and related preview samples/project references.
  - fixed share-extension publish/concurrency warnings by aligning `./TchopShareExtension/ShareViewController.swift` with boolean `publish()` and marking `NSItemProviderShareItemImporter` main-actor isolated in `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and final `./scripts/verify.sh low` all succeeded; no tests/simulator UI run.

- Completed now: static end-to-end review of local-created feed card flow:
  - verified app composer publish path writes `ChannelCardContent.localFeedCardModel` into `LocalFeedCardStore`, then persists via `LocalFeedCardRepository`/SwiftData `LocalFeedCardRecord`.
  - verified feed visibility is channel-scoped through `NewsFeedViewModel.visibleContent` and all five local card kinds render through `NewsFeedView` local card branches.
  - verified like/comment/display-mode mutations update `LocalFeedCardStore.updatePersistedCard` and re-save the full `LocalFeedCardModel` payload, preserving state across restart.
  - verified share extension publishes pending local cards through `SharedLocalFeedCardSyncManager` and app refresh pulls them into the same `LocalFeedCardStore` path.
  - applied one contract fix in `./TchopApp/Models/NewsFeedModels.swift`: composer visible text fields now use canonical order `text`, `headline`, `subheadline`, `source`, matching published feed/local card ordering.
- Verification: `git diff --check`, `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, and `./scripts/verify.sh low` succeeded; no tests/simulator UI run.
