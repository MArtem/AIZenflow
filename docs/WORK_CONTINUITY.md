# Work Continuity

## Purpose
This file is the durable repo-level continuity checkpoint for `TchopApp`.

Use it when:
- the current Zenflow task/thread is lost
- a new chat/session needs to resume the same long-running work
- the project needs a git-backed status snapshot instead of `.zenflow`-only task state

## Current Long-Running Epic
Restoration of the feed/composer/card runtime around the 5-type card model is complete.

The current active epic is runtime architecture/simplification audit of the working code:
- share-extension rollout foundation is complete enough to build and continue later
- current focus is reducing decorative seams, duplicate paths, and unnecessary indirection in runtime code
- test-target cleanup is intentionally deferred

The most recent architectural simplification batch:
- removed duplicated shared-card sync ownership from `AppState` and routed it through `NewsFeedViewModel`
- removed app-local single-implementation seams around channel selection and local channel settings
- simplified `TchopShareSupport` by deleting unused public protocols and an unused per-item delete API
- simplified app-specific share wrappers by removing unused store-injection initializers

The current share-extension status remains:
- reusable package root: `TchopShareSupport`
- app-specific bridge: `SharedLocalFeedCardSyncManager`
- current stage:
  - app-group-backed shared local card sync is wired into app entry and pull-to-refresh
  - reusable share-intake importer exists
  - share extension targets exist for both app variants and the project builds with them

## Stable Baselines That Must Be Preserved
- Deployment target: `iOS 17`
- UI-facing state owners prefer `Observation`
- Active persistence runtime: `SwiftData`
- `Core Data` is fallback-only material
- Reusable packages/managers are the root
- `SyncCore` is the active sync foundation
- `TchopOnDeviceAI` is the active local AI foundation
- `TchopShareSupport` is the active share-extension storage foundation
- Do not add speculative UI, logic, or fallback behavior

## Current Functional Contract
### Card Types
- `text`
- `photo`
- `video`
- `audio`
- `pdf`

### Text Fields
Only these fields exist:
- `text`
- `headline`
- `subheadline`
- `source`

### Draft Rules
- Empty draft is forbidden
- Without media, `text` is required
- With media, optional text fields can be removed
- If text and media both exist, either side can be removed, but the remaining side becomes required

### Media Rules
- `photo`: up to 10 items
- `video/audio/pdf`: single item and mutually exclusive
- non-photo media may have teaser image
- each photo may have caption and copyright
- non-photo media may have caption
- teaser image may have copyright

## What Is Already Restored
- app shell, tabs, session restoration, and base feed flow
- package-first infrastructure baseline
- `SyncCore` integrated into active project architecture
- runtime taxonomy moved to `text/photo/video/audio/pdf`
- composer draft model moved to richer card/media state
- local published cards now use unified feed runtime semantics instead of the old special-case local branch
- composer supports:
  - photo strip
  - card-specific file media preview for `video/audio/pdf`
  - teaser preview
  - photo fullscreen/detail
  - file media detail
  - teaser detail
  - photo actions
  - file media actions
  - teaser actions
  - photo caption/copyright editing
  - file caption editing
  - teaser copyright editing
- feed runtime no longer uses the old generic local media placeholder path for local `photo/video/audio/pdf`
- local `video/audio/pdf` feed cards now use dedicated card-specific media layouts instead of a shared generic file preview block
- composer and feed now use matching card-specific visual semantics for non-photo media
- `video/audio/pdf` were lifted to first-class feed content wrappers instead of flowing through `NewsFeedCard` as raw local draft models
- published local feed cards now use feed-oriented `LocalFeed*` payload types instead of reusing draft-oriented `ChannelCard*` payload types inside runtime models
- locally published cards now enter runtime through a feed-native `LocalFeedCardStore` that stores `NewsFeedCard`, not draft-side `ChannelCardContent`
- published local feed no longer renders draft-only media labels such as per-photo placeholder names or generic file titles
- composer preview/detail now matches that behavior and no longer renders draft-only media titles either
- `source` now supports hidden separate URL storage in draft/model and published local feed opens it only when a URL is present
- channel/publish/search contract has been re-checked: composer starts from current feed channel, publish writes to the selected draft channel, local cards are scoped by current channel in feed, and search runs only against cards visible in the current channel
- documentation was refactored into a canonical map + package guide + local project skills
- final docs consistency pass was completed across repo docs and local project skills
- final package/manager audit was completed after the card/runtime restoration and did not reveal new decorative app-local wrapper layers
- `TchopOnDeviceAI` package was added as the reusable local AI root
- app-local translated snapshot persistence was added for cards
- feed translation flow now works for remote and local feed cards:
  - translation button appears after the last text block
  - if two app languages exist, translation goes directly to the other language
  - if more than two app languages exist, a simple language picker popup is shown
  - translated cards switch the button label to `See original`
  - translated state survives refresh/navigation/reopen through local persisted snapshots
  - button stays hidden when the on-device model is unavailable
- `TchopOnDeviceAI` now contains a session-level circuit breaker:
  - if runtime translation fails with missing Foundation Model catalog assets
  - the package marks itself unavailable for the current session
  - feed buttons hide on subsequent renders instead of allowing repeated dead taps
- current app localization baseline now includes `de` in addition to existing locales
- `TchopShareSupport` package was added as the reusable app-group JSON storage root for extension/app handoff
- `TchopShareSupport` now also contains a reusable `NSItemProvider`-based share-intake importer for text/image/video/pdf/audio/file payloads
- `SharedLocalFeedCardSyncManager` now syncs extension-published local cards into the app runtime:
  - app sync happens on app activation
  - app sync also happens on pull-to-refresh
  - extension/app are intentionally not coupled through direct shared in-memory runtime
  - the current local app store remains the visible runtime cache
- `FeedComposerViewModel` publish boundary is now generalized:
  - the same app-specific composer can publish either into app runtime or into extension shared storage
  - the publish decision is injected as an app-specific closure instead of being hard-wired to one runtime path
- `FeedComposerDraft` now supports app-specific import of shared content:
  - imported text is merged into the `text` field
  - imported image batches map into photo items
  - one imported video/audio/pdf file maps into the corresponding file-media draft
  - incompatible imported media mixes fail explicitly instead of silently guessing
- share extension target scaffolding now exists for both app variants:
  - `TchopShareExtension`
  - `TchopShareOceanExtension`
- share extension now uses the real app-specific composer contract instead of a summary scaffold:
  - `SharedCardComposerView` was extracted into its own app-specific shared source file
  - the same composer UI is now used by the app and the share extension
  - extension publish writes `LocalFeedCardModel` payloads into shared app-group storage
  - unauthenticated extension state now shows `Open app` plus reason text
  - both `TchopApp` and `TchopAppOcean` build successfully with their embedded share extensions after the shared composer extraction

## What Still Needs Work
- manual runtime validation of share-extension flows is still pending
- incompatible import combinations and unknown file types now fail explicitly by rule
- `Open app` from share extension remains best-effort platform behavior and should not be treated as a guaranteed system contract
- on-device translation is still paused at feed-only stage until detail design exists
- runtime architecture/overengineering audit of the working code is still in progress

## Reopen First
If work must resume quickly, start with:

1. [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)
2. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
3. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
4. This file
5. [handoff.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/handoff.md) if the Zenflow task still exists

## Key Files
- [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
- [AppShellViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift)
- [ShellContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift)
- [NewsFeedView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift)
- [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)
- [NewsFeedViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/NewsFeedViewModel.swift)
- [Package.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Package.swift)
- [TchopOnDeviceAI.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopOnDeviceAI/TchopOnDeviceAI.swift)
- [TchopShareSupport.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift)
- [ShareItemImporter.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift)
- [SharedLocalFeedCardSyncManager.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Shared/SharedLocalFeedCardSyncManager.swift)
- [ShareViewController.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopShareExtension/ShareViewController.swift)
- [docs/SHARE_EXTENSION_VALIDATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/SHARE_EXTENSION_VALIDATION.md)

## Related Durable Context
- [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
- [.codex/skills/tchop-feed-cards/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-feed-cards/SKILL.md)
- [.codex/skills/tchop-packages/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-packages/SKILL.md)
