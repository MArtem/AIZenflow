# Work Continuity

## Purpose
Durable resume checkpoint for `TchopApp` when chat/task context is lost.

## Chat Transition Rule (Universal)
- Keep and update a universal transition prompt here.
- When context gets large or phase boundary is reached, propose new chat proactively.
- After reset, run bootstrap read **once per new chat**.

### Universal Transition Prompt Template
```text
Работаем в проекте `TchopApp` в worktree:
`/Users/Artem/.zenflow/worktrees/new-task-be0b`

Перед началом прочитай в таком порядке:
1) docs/README.md
2) PROJECT_DOCUMENTATION.md
3) PROJECT_HEALTH.md
4) docs/WORK_CONTINUITY.md
5) .zenflow/tasks/new-task-be0b/handoff.md
6) .zenflow/tasks/new-task-be0b/plan.md
7) .zenflow/tasks/new-task-be0b/ios-engineering-rules.md
8) .zenflow/tasks/new-task-be0b/services-engineering-rules.md

Правило после очистки контекста:
- Этот список читается один раз в начале нового чата.
- Повторно перечитывать полностью только если изменились архитектурные правила/фаза/контракты.

Критичные правила:
- Архитектура — приоритет №1.
- После архитектуры всегда проверка на overengineering.
- Не угадывать state flow/ownership/boundaries; если неясно — сначала уточнить.
- Для SwiftUI внутри `View` запрещены view-returning helpers (`private var ...: some View`, `@ViewBuilder private func ... -> some View`).
- ViewModel standard: `@MainActor`, `@Observable`, один state container, explicit intent methods, без generic `send(action)` как стандарта.

Текущий фокус:
1) Phase 1: runtime architecture/overengineering audit
2) Phase 2: SwiftUI view decomposition pass
3) Phase 3: ViewModel standardization pass

После фаз: manual validation по `docs/SHARE_EXTENSION_VALIDATION.md`.

Начни с краткого статуса:
1) какая сейчас active phase
2) какие файлы смотришь
3) какой следующий безопасный шаг
```

## Current Long-Running Epic
Runtime restoration for feed/composer/card (`text/photo/video/audio/pdf`) is complete.
Current epic: 3-phase cleanup/refactor over working runtime code (tests are intentionally out of scope for now).

## Stable Baselines (Must Keep)
- Deployment target: `iOS 17`
- UI state owners use Observation
- Active persistence runtime: `SwiftData` (`Core Data` fallback-only)
- Reusable packages/managers are primary architecture root
- `SyncCore`, `TchopOnDeviceAI`, `TchopShareSupport` are active foundations
- No speculative UI/logic/fallback flows

## Current Functional Contract (Compact)
- Card kinds: `text`, `photo`, `video`, `audio`, `pdf`
- Text fields: `text`, `headline`, `subheadline`, `source`
- Draft rules:
  - empty draft forbidden
  - without media, `text` required
  - with media, optional text fields may be removed
- Media rules:
  - `photo` up to 10
  - `video/audio/pdf` single + mutually exclusive
  - non-photo media may have teaser image

## Restored Runtime Snapshot (Compact)
- Feed/composer local runtime restored and aligned to 5-kind card model.
- Local published cards use feed-native models/store and channel-scoped visibility.
- Non-photo media rendering unified between composer and feed.
- Source URL behavior, channel/publish/search contract, and translation feed-stage are implemented.
- Share extension foundation is wired:
  - reusable storage/import in `TchopShareSupport`
  - app bridge in `SharedLocalFeedCardSyncManager`
  - sync points on activation + pull-to-refresh
  - shared composer reused by app and extension

## Still Pending
- Manual share-extension runtime validation (`docs/SHARE_EXTENSION_VALIDATION.md`)
- Runtime architecture/overengineering audit (Phase 1 in progress)
- Translation detail-stage design (feed-stage exists)

## Reopen First
1. `docs/README.md`
2. `PROJECT_DOCUMENTATION.md`
3. `PROJECT_HEALTH.md`
4. this file
5. task `handoff.md` / `plan.md`

## Key Files
- `TchopApp/Models/NewsFeedModels.swift`
- `TchopApp/ViewModels/AppShellViewModel.swift`
- `TchopApp/ViewModels/NewsFeedViewModel.swift`
- `TchopApp/Views/News/NewsFeedView.swift`
- `TchopApp/Views/Composer/SharedCardComposerView.swift`
- `TchopApp/Repositories/AppContentRepository.swift`
- `TchopApp/Shared/SharedLocalFeedCardSyncManager.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`
