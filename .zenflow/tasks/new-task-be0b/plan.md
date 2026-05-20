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

## Verification Status
- This latest cleanup is code + localization only.
- No build/test/simulator verification was run.

## Archive
Detailed historical plan/log entries were moved out of the active plan to reduce context cost.
Global reusable knowledge and TchopApp-specific knowledge are now split under `./docs/knowledge/`.

Use archives only when historical detail is needed:
- `./.zenflow/tasks/new-task-be0b/archive/plan.before-cleanup-2026-05-20.md`
- `./.zenflow/tasks/new-task-be0b/archive/plan.legacy.md`
