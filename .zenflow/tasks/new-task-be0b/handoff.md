# Handoff

## Current Status
- Project: `TchopApp`
- State: app builds successfully
- Current track: restoration of lost card/composer/feed functionality
- Resume from this worktree, not from scratch

## Default Resume Read Order
1. [docs/README.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/README.md)
2. [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
3. [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
4. This file
5. [plan.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/plan.md)

## What Is Already Restored
- app shell, tabs, menu, auth flow, session restoration
- package-first infrastructure baseline
- `SyncCore` integrated into active project architecture
- feed taxonomy moved to `text/photo/video/audio/pdf`
- local composer/feed runtime substantially restored
- photo fullscreen/detail viewer added in composer
- photo/file/teaser action surfaces exist in composer
- asset metadata editing exists for photo caption/copyright and file caption/teaser copyright

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

## Current Next Work
- continue replacing remaining placeholder behavior with first-class media/runtime behavior
- after full restoration, do a final docs consistency pass across the new documentation structure and local project skills

## Important Files
- App shell state:
  [AppShellViewModel.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/ViewModels/AppShellViewModel.swift)
- Feed/card/composer models:
  [NewsFeedModels.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Models/NewsFeedModels.swift)
- Composer UI:
  [ShellContentView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/ShellContentView.swift)
- Feed runtime UI:
  [NewsFeedView.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Views/News/NewsFeedView.swift)
- Feed/persistence/sync orchestration:
  [AppContentRepository.swift](/Users/Artem/.zenflow/worktrees/new-task-be0b/TchopApp/Repositories/AppContentRepository.swift)

## Verification Baseline
- Default verification is not automatic
- If user asks for verification, use [TESTING_INSTRUCTIONS.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/TESTING_INSTRUCTIONS.md)
- Last confirmed command:
  `./scripts/verify.sh low`
- Last confirmed result:
  `BUILD SUCCEEDED`

## Post-Restoration Requirement
After full restoration is complete:
1. re-check all project docs for consistency, correctness, completeness, and duplication
2. re-check the package/manager guide and local project skills for consistency with the final codebase

## Archive
Detailed historical handoff logs are preserved only in:
- [.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md)
