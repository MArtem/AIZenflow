# Handoff

## Current Status
- Project: `TchopApp`
- State: app builds successfully
- Current track: runtime architecture/simplification audit of working code after the completed runtime restoration
- Resume from this worktree, not from scratch

## Default Resume Read Order
1. [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)
2. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
3. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
4. [docs/WORK_CONTINUITY.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/WORK_CONTINUITY.md)
5. This file
6. [plan.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/plan.md)

## What Is Already Restored
- app shell, tabs, menu, auth flow, session restoration
- package-first infrastructure baseline
- `SyncCore` integrated into active project architecture
- feed taxonomy moved to `text/photo/video/audio/pdf`
- local composer/feed runtime substantially restored
- photo fullscreen/detail viewer added in composer
- photo/file/teaser action surfaces exist in composer
- asset metadata editing exists for photo caption/copyright and file caption/teaser copyright
- local `video/audio/pdf` feed cards now render through dedicated card-specific layouts instead of a shared generic file preview block
- composer non-photo media previews now use matching card-specific layouts instead of one generic file preview
- `video/audio/pdf` feed runtime now uses first-class content wrappers instead of carrying raw local draft models through `NewsFeedCard`
- published local feed cards now use feed-oriented `LocalFeed*` payload types instead of draft-oriented `ChannelCard*` payload types in runtime models
- publish path now writes directly into a feed-native `LocalFeedCardStore` as `NewsFeedCard`, instead of storing draft-side `ChannelCardContent`
- published local feed no longer shows draft-only media labels like `Photo 1` or generic file titles
- composer preview/detail no longer shows those draft-only media titles either, so this parity gap is closed
- `source` now has hidden separate URL storage and published local feed performs tap-to-open only when the URL exists
- channel/publish/search contract was re-checked and currently looks aligned with the agreed runtime behavior
- `TchopOnDeviceAI` feed translation integration exists and is currently paused at feed-only stage
- `TchopShareSupport` package root was added for reusable app-group JSON storage
- `TchopShareSupport` now also provides generic `NSItemProvider` intake for shared text/files
- `SharedLocalFeedCardSyncManager` now bridges extension-originated local cards into app runtime through sync points instead of direct live coupling
- current sync points:
  - app activation
  - pull-to-refresh
- share extension target scaffolding now exists for both app variants and both app schemes build successfully with the new embedded extensions
- `FeedComposerViewModel` publish is now injected instead of being hard-wired only to `LocalFeedCardStore`
- `FeedComposerDraft` now supports imported text/image/video/audio/pdf application with explicit failure for incompatible media mixes
- the share extension now renders the real shared app-specific composer instead of a summary scaffold
- `SharedCardComposerView` was extracted from `ShellContentView.swift` into its own shared app source file and is now used by both app and extension
- share-extension publish now writes app-specific `LocalFeedCardModel` payloads into app-group storage
- unauthenticated extension state now shows reason text plus `Open app`
- latest simplification pass removed decorative package protocols and extra wrapper initializers in the share-support/runtime path

## Current Functional Contract
- card types: `text`, `photo`, `video`, `audio`, `pdf`
- text fields: `text`, `headline`, `subheadline`, `source`
- empty draft is forbidden
- without media, `text` is required
- with media, optional text fields can be removed
- `photo` supports up to 10 items
- `video/audio/pdf` are single-item and mutually exclusive
- non-photo media can have a teaser image
- per-photo caption/copyright is part of the draft model
- on-device translation excludes `source`
- translation currently targets published feed cards, not composer preview
- detail-screen translation is still open

## Current Next Work
- continue runtime architecture/complexity audit on working code only
- keep avoiding test-target cleanup until it becomes a dedicated task
- after the audit, return to manual share-extension runtime validation

## Important Files
- App shell state:
  [AppShellViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift)
- Feed/card/composer models:
  [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
- Composer UI:
  [SharedCardComposerView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/Composer/SharedCardComposerView.swift)
  [ShellContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift)
- Feed runtime UI:
  [NewsFeedView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift)
- Feed translation orchestration:
  [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- Shared extension/app local card sync:
  [SharedLocalFeedCardSyncManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Shared/SharedLocalFeedCardSyncManager.swift)
- Feed/persistence/sync orchestration:
  [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- Local AI package:
  [TchopOnDeviceAI.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopOnDeviceAI/TchopOnDeviceAI.swift)
- Share support package:
  [TchopShareSupport.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift)
- Share intake importer:
  [ShareItemImporter.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift)
- Share extension scaffold:
  [ShareViewController.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopShareExtension/ShareViewController.swift)
  [ShareExtensionRootView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopShareExtension/ShareExtensionRootView.swift)

## Verification Baseline
- Default verification is not automatic
- If user asks for verification, use [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
- Last confirmed command:
  `./scripts/verify.sh low`
- Last confirmed result:
  `BUILD SUCCEEDED`
- Additional confirmed build:
  `xcodebuild -project TchopApp.xcodeproj -scheme TchopAppOcean -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build`
- Additional confirmed result:
  `BUILD SUCCEEDED`

## Post-Restoration Requirement
Completed in this worktree:
1. project docs were re-checked for consistency, correctness, completeness, and duplication
2. the package/manager guide and local project skills were re-checked against the final codebase

## Archive
Detailed historical handoff logs are preserved only in:
- [.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md)
