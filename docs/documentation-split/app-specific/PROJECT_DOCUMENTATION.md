# source-app Developer Onboarding Guide

## Purpose
This is the stable onboarding document for `source-app`.

Read this file for:
- app shape
- architecture boundaries
- runtime baselines
- documentation entry points
- top-level folder ownership

Do not use this file for:
- current task history
- implementation logs
- temporary debugging notes

For the full documentation map, use [docs/README.md](./docs/README.md).

## First Read For Agents
When starting or resuming work in this worktree, read in this order:
1. [docs/README.md](./docs/README.md)
2. this file
3. [PROJECT_HEALTH.md](./PROJECT_HEALTH.md)
4. [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md)
5. [docs/AGENT_RULES.md](./docs/AGENT_RULES.md)
6. [docs/WORK_CONTINUITY.md](./docs/WORK_CONTINUITY.md)
7. current task docs under `.zenflow/tasks/new-task-be0b/`

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Quick Orientation
`source-app` is a SwiftUI iOS application with:
- coordinator-driven navigation
- app-level session and shell state
- local-first persistence
- source-only reusable packages under `./PackagesInUse` plus the full vault under `./PackagesForReuse`
- widget, localization, branding, and push-notification support
- feed/composer runtime built around `text/photo/video/audio/pdf` cards

The primary separation is:
- `source-app` = product-specific composition, features, UI, app policies, DTO/app mapping, persistence schema, routing
- `./PackagesInUse` = active source-only reusable managers; `./PackagesForReuse` = reviewed reusable package vault

## Stable Runtime Baselines
- Current deployment target: `iOS 17`
- UI-facing state owners should prefer `Observation` (`@Observable`, `@Bindable`)
- Type-level `@MainActor` belongs on UI state owners, not on repositories/use cases/API clients by default
- Active app persistence path is `SwiftData`
- `Core Data` is fallback-only historical/runtime material, not the active design direction
- Reusable packages/managers are the root; app code adapts to them instead of wrapping them in decorative layers
- `SyncCore` is the reusable sync foundation; app code owns project-specific mapping and policy
- Use `.task` over `.onAppear` for async loading when lifecycle correctness matters
- Do not assume deallocation immediately after navigation pop
- Feature view models are created above views and injected downward
- Implement only explicitly requested behavior; do not add speculative UI or logic
- Prefer the simplest correct implementation and avoid decorative abstraction

## Current Task Overrides
Current user/task overrides live in:
- [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md)

Important current overrides:
- apply `./docs/MODEL_ROUTING_RULE.md`: use `GPT-5.4` only for approved low-risk execution and `GPT-5.5` for planning, architecture, high-risk, and final-gate work
- do not run builds/tests/simulator UI unless user explicitly asks
- do not touch `./app test targets` unless user explicitly asks
- UI/design work from screenshots/Figma/PDF/CSS must be pixel-focused and use `GPT-5.5`

## Knowledge Organization
Reusable cross-project knowledge lives in:
- [docs/knowledge/global/README.md](./docs/knowledge/global/README.md)

source-app-specific knowledge lives in:
- [docs/knowledge/source-app/README.md](./docs/knowledge/source-app/README.md)

Rule of thumb:
- reusable prompts/rules → `docs/knowledge/global/`
- concrete source-app files/entities/contracts/current task rules → `docs/knowledge/source-app/` or the canonical app doc indexed there

## Feed / Composer Baseline
The app currently centers on a local-first feed/composer runtime.

Canonical contracts:
- [feed-card-contract.md](./.codex/skills/ios-content-cards/references/feed-card-contract.md)
- [docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md](./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md)
- [docs/knowledge/source-app/feed-and-composer-summary.md](./docs/knowledge/source-app/feed-and-composer-summary.md)

Current product baseline:
- card kinds: `text`, `photo`, `video`, `audio`, `pdf`
- text render order: `text`, `headline`, `subheadline`, `source`
- feed cards must persist through SwiftData and durable media references
- future backend/API sync should merge into local-first records instead of creating permanent local-vs-remote split behavior

## Dependency Map
```text
source-app.swift
  -> AppDIContainer
    -> AppState
      -> AppCoordinator
      -> AppShellViewModel
      -> LoginViewModel
      -> ProfileTabViewModel
      -> repositories/services/managers

AppShellViewModel
  -> NewsFeedViewModel
    -> FeedCardStore
      -> FeedCardRepository
        -> source-appDatabase / SwiftData
    -> SharedFeedCardSyncManager
      -> source-appShareSupport app-group storage
```

Use [PROJECT_HEALTH.md](./PROJECT_HEALTH.md) for package boundaries and manager ownership.

## Top-Level Structure
### App
- `source-app/App`: app entry points, DI, app-global state, bridges, theme/localization
- `source-app/Models`: app-local models and feature contracts
- `source-app/Navigation`: coordinator, routes, deep links, navigation snapshot integration
- `source-app/Persistence`: app schema, bootstrap, seeding, persistence policy
- `source-app/Repositories`: feature-facing repository orchestration
- `source-app/Services`: app services and API-facing managers
- `source-app/ViewModels`: UI-facing state owners
- `source-app/Views`: SwiftUI screens and reusable view pieces

### Infrastructure Package
`./PackagesInUse` contains active reusable source packages for:
- networking
- database
- sync
- navigation
- localization
- branding
- widgets
- push notifications
- analytics
- UI configuration
- Apple authentication

## Canonical Companion Documents
- [docs/README.md](./docs/README.md): documentation map and placement policy
- [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md): current task/user overrides
- [docs/AGENT_RULES.md](./docs/AGENT_RULES.md): short mandatory implementation guardrails
- [PROJECT_HEALTH.md](./PROJECT_HEALTH.md): package inventory and ownership boundaries
- [docs/PACKAGES_AND_MANAGERS.md](./docs/PACKAGES_AND_MANAGERS.md): reusable package and manager usage guide
- [docs/UI_PIXEL_PERFECT_WORKFLOW.md](./docs/UI_PIXEL_PERFECT_WORKFLOW.md): UI/design implementation workflow
- [docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md](./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md): local feed persistence and sync direction
- [docs/WORK_CONTINUITY.md](./docs/WORK_CONTINUITY.md): durable resume state and transition prompt
- [docs/knowledge/global/README.md](./docs/knowledge/global/README.md): reusable cross-project knowledge
- [docs/knowledge/source-app/README.md](./docs/knowledge/source-app/README.md): source-app-specific knowledge index
- [TESTING_INSTRUCTIONS.md](./TESTING_INSTRUCTIONS.md): verification and testing workflow
- [APPLE_SIGN_IN_SETUP.md](./APPLE_SIGN_IN_SETUP.md): Sign in with Apple setup
- [handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md): current task resume state
- [plan.md](./.zenflow/tasks/new-task-be0b/plan.md): current task plan only

## What To Update When Things Change
- Stable architecture or runtime policy:
  update this file
- Package or manager ownership:
  update [PROJECT_HEALTH.md](./PROJECT_HEALTH.md)
- Verification workflow:
  update [TESTING_INSTRUCTIONS.md](./TESTING_INSTRUCTIONS.md)
- Current user/task override:
  update [docs/CURRENT_USER_OVERRIDES.md](./docs/CURRENT_USER_OVERRIDES.md)
- UI/design workflow:
  update [docs/UI_PIXEL_PERFECT_WORKFLOW.md](./docs/UI_PIXEL_PERFECT_WORKFLOW.md)
- Feed/composer product contract:
  update [feed-card-contract.md](./.codex/skills/ios-content-cards/references/feed-card-contract.md)
- Local feed persistence/sync contract:
  update [docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md](./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md)
- Current task state:
  update [handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md)
- Current task plan:
  update [plan.md](./.zenflow/tasks/new-task-be0b/plan.md)

## Archive Policy
Verbose historical versions are kept only for fallback reference:
- `docs/archive/`
- `.zenflow/tasks/new-task-be0b/archive/`

They are not part of the default read path.
