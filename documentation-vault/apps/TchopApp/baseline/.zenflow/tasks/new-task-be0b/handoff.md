# Handoff

## Current Status
- Project: `TchopApp`
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Build state: `BUILD SUCCEEDED`
- Phase status: **Phase 1 completed, Phase 2 checkpoint completed**

## Resume Read Order (One-Time)
1. `docs/README.md`
2. `PROJECT_DOCUMENTATION.md`
3. `PROJECT_HEALTH.md`
4. `docs/CURRENT_USER_OVERRIDES.md`
5. `docs/AGENT_RULES.md`
6. `docs/WORK_CONTINUITY.md`
7. `docs/MODEL_ROUTING_RULE.md`
8. this file
9. `.zenflow/tasks/new-task-be0b/plan.md`
10. `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
11. `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
12. `docs/agent-prompts/README.md`
13. `docs/knowledge/global/README.md`
14. `docs/knowledge/TchopApp/README.md`

If this handoff is used in a context-transfer prompt, include the explicit rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

Current model routing: apply `./docs/MODEL_ROUTING_RULE.md`; use `GPT-5.4` for approved-plan low-risk execution and `GPT-5.5` for planning, architecture, high-risk, and final-gate work.

## What Is Completed
- Phase 1 runtime simplification pass over active runtime/repository code.
- Phase 2 SwiftUI decomposition pass over the main app surfaces:
  - feed/composer/auth
  - shell/menu/top bar/tab container
  - root/profile
  - feature-tab/card surfaces
- No changes in `TchopAppTests`.

## Next Work
1. Static UX edge-case review follow-up only if new issues appear.
2. Manual simulator validation via `docs/SHARE_EXTENSION_VALIDATION.md` when explicitly requested.

## Key Files for Next Step
- `TchopApp/Models/NewsFeedModels.swift`
- `TchopApp/ViewModels/AppShellViewModel.swift`
- `TchopApp/ViewModels/NewsFeedViewModel.swift`
- `TchopApp/Views/News/NewsFeedView.swift`
- `TchopApp/Views/Composer/SharedCardComposerView.swift`
- `TchopApp/Shared/SharedFeedCardSyncManager.swift`
- `TchopShareExtension/ShareViewController.swift`

## Verification Baseline
- Command: `./scripts/verify.sh low`
- Result: `BUILD SUCCEEDED`

## Archive
Detailed historical handoff is preserved in:
- `.zenflow/tasks/new-task-be0b/archive/handoff.legacy.md`
