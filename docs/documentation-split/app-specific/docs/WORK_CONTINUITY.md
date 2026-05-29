# Work Continuity

## Purpose
Durable resume checkpoint for `TchopApp` when chat/task context is lost.

## Chat Transition Rule (Universal)
- Keep and update a universal transition prompt here.
- When context gets large or phase boundary is reached, propose new chat proactively.
- After reset, run bootstrap read **once per new chat**.
- If the user asks to refresh docs/rules state, re-read the active documentation set listed in `docs/README.md` before continuing.
- Every context-transfer prompt must explicitly include this rule:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Working Mode Rule (Low Resource)
- When the user has already approved a clear implementation plan, the assistant may batch multiple consecutive plan steps into one larger execution block instead of reporting after each small step.
- Choose batch size based on overall efficiency, code quality, architectural safety, and minimizing unnecessary builds/context churn.
- Report back after a meaningful block is complete, or earlier only if a blocker, ambiguity, or architecture-risk decision appears.
- If the user creates a separate new task, treat it as an independent unit and provide a completion report for that task specifically.

### Universal Transition Prompt Template
```text
Работаем в проекте `TchopApp` в worktree:
`/Users/Artem/.zenflow/worktrees/new-task-be0b`

Перед началом прочитай в таком порядке:
1) docs/README.md
2) PROJECT_DOCUMENTATION.md
3) PROJECT_HEALTH.md
4) docs/CURRENT_USER_OVERRIDES.md
5) docs/AGENT_RULES.md
6) docs/WORK_CONTINUITY.md
7) .zenflow/tasks/new-task-be0b/handoff.md
8) .zenflow/tasks/new-task-be0b/plan.md
9) .zenflow/tasks/new-task-be0b/ios-engineering-rules.md
10) .zenflow/tasks/new-task-be0b/services-engineering-rules.md
11) docs/agent-prompts/README.md
12) docs/knowledge/global/README.md
13) docs/knowledge/TchopApp/README.md
14) docs/PRODUCTION_QUALITY_GATES.md
15) docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md
16) docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md
17) docs/IOS_PRODUCTION_READINESS_STANDARD.md
18) docs/DEFINITION_OF_DONE.md
19) docs/EVIDENCE_BASED_ENGINEERING_RULES.md
20) docs/PRODUCT_REQUIREMENTS_STANDARD.md
21) docs/ARCHITECTURE_DECISION_GOVERNANCE.md
22) docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md
23) docs/FEATURE_FLAGS_AND_ROLLOUTS.md
24) docs/INCIDENT_RESPONSE_STANDARD.md
25) docs/PRODUCT_HEALTH_SLO.md
26) docs/RISK_REGISTER.md
27) docs/TECH_DEBT_REGISTER.md
28) docs/MODULAR_ARCHITECTURE_STANDARD.md
29) docs/QA_TEST_PLAN_STANDARD.md
30) docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md
31) docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md
32) docs/DATA_GOVERNANCE_AND_COMPLIANCE.md
33) docs/COMPATIBILITY_MATRIX.md
34) docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md
35) docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md
36) docs/IOS_UI_STATE_RENDERING_STANDARD.md
37) docs/IOS_NETWORK_RESILIENCE_STANDARD.md
38) docs/IOS_OFFLINE_SYNC_STANDARD.md
39) docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md
40) docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md
41) docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md
42) docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md
43) docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md
44) docs/IOS_STOREKIT_PAYMENTS_STANDARD.md
45) docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md

Правило после очистки контекста:
- Этот список читается один раз в начале нового чата.
- Повторно перечитывать полностью только если изменились архитектурные правила/фаза/контракты.
- При любом переносе контекста обязательно явно добавить в промпт правило:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.
- Если пользователь просит обновить состояние документации/правил, перечитать активный набор документации из `docs/README.md` перед продолжением.
- Для задач, похожих на feature generation / UI from design / refactoring / code review / ADR / tests / CI-debug / compile errors / signing / flaky tests, открыть релевантный prompt preset из `docs/agent-prompts/` и применить его только после project/task/user overrides.

Критичные правила:
- Для текущего worktree/task использовать `GPT-5.5`, пока пользователь явно не изменит модель.
- Архитектура — приоритет №1.
- После архитектуры всегда проверка на overengineering.
- Не угадывать state flow/ownership/boundaries; если неясно — сначала уточнить.
- Точные iOS/SwiftUI/ViewModel правила брать из `.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`.
- Точные services/package rules брать из `.zenflow/tasks/new-task-be0b/services-engineering-rules.md`.
- Точные UI/design правила брать из `docs/UI_PIXEL_PERFECT_WORKFLOW.md`.
- Точные local feed/card persistence правила брать из `docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`.
- Перед любой нетривиальной реализацией, рефакторингом, cleanup или review применять `docs/PRODUCTION_QUALITY_GATES.md` и `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`.
- Stop list из `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` является блокирующим по умолчанию; если нужен exception, сначала явно зафиксировать причину и tradeoff.
- Перед утверждением `готово` / `исправлено` / `production-ready` / `verified` применять `docs/EVIDENCE_BASED_ENGINEERING_RULES.md`.
- Перед нетривиальной feature-работой проверять требования по `docs/PRODUCT_REQUIREMENTS_STANDARD.md`; если acceptance criteria/state behavior неясны — спрашивать.
- Для production-scale изменений учитывать rollout/rollback, incident response, SLO/product health, risk/debt register, QA, localization, Apple capabilities, data governance, compatibility matrix.
- Для generic iOS задач учитывать concurrency/runtime, memory/cache/media, UI state/rendering, network resilience, offline/sync, lifecycle/background, error handling, analytics/telemetry, configuration/environments, input validation/content safety, permissions, StoreKit/payments where applicable.
- Глобальные reusable правила/промпты брать из `docs/knowledge/global/`.
- TchopApp-specific правила/контракты/пути брать из `docs/knowledge/TchopApp/`.

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
- Mandatory production checklist + forbidden-pattern stop list before implementation/review/audit
- Mandatory iOS production standards available for release, testing, security/privacy, observability, accessibility, performance, API, migration, design-system, CI/CD, and dependency decisions
- Mandatory enterprise production standards available for requirements, ADRs, code ownership, evidence, rollout, incidents, SLOs, risk/debt, modular architecture, QA, localization, platform capabilities, data governance, and compatibility decisions

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
  - app bridge in `SharedFeedCardSyncManager`
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
- `TchopApp/Shared/SharedFeedCardSyncManager.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift`
- `Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`
