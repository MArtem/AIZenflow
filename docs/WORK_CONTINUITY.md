# Work Continuity

## Purpose
This file is the durable repo-level continuity checkpoint for `TchopApp`.

Use it when:
- the current Zenflow task/thread is lost
- a new chat/session needs to resume the same long-running work
- the project needs a git-backed status snapshot instead of `.zenflow`-only task state

## Current Long-Running Epic
Restore and complete the new feed/composer/card runtime around the 5-type card model while keeping package-first architecture and docs consistent.

## Stable Baselines That Must Be Preserved
- Deployment target: `iOS 17`
- UI-facing state owners prefer `Observation`
- Active persistence runtime: `SwiftData`
- `Core Data` is fallback-only material
- Reusable packages/managers are the root
- `SyncCore` is the active sync foundation
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
- documentation was refactored into a canonical map + package guide + local project skills

## What Still Needs Work
- continue aligning composer and feed render behavior so both speak the same first-class card contract
- after feature restoration, run a final consistency pass across docs and local project skills

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

## Related Durable Context
- [docs/PACKAGES_AND_MANAGERS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/PACKAGES_AND_MANAGERS.md)
- [.codex/skills/tchop-feed-cards/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-feed-cards/SKILL.md)
- [.codex/skills/tchop-packages/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-packages/SKILL.md)
