# QualityControl — актуальный план продолжения

Обновлён 2026-09-08 по разрешённому полному аудиту на GPT-6 Astra. Это task recovery и operational index внедрения; он не заменяет reusable policy и не является разрешением запускать runtime/CI или менять apps без соответствующего блока. Предыдущий утверждённый план целиком сохранён в `audit-2026-09-05/before-universal-quality-control-plan.md`.

## Новое ограничение исполнения

Пользователь установил единственную модель для всего плана от начала до конца: **GPT-5.6 Luna xhigh**, включая проектирование, implementation, review и финальный аудит. Предыдущие модельные рекомендации отменены. Использовать `audit-2026-09-05/LUNA_EXECUTION_GUIDE.md`; при неоднозначности уточнять контракт, а не менять модель или снижать quality bar.

## Текущее решение

Сохранить QualityControl engine. Объединить лучшие человеческие правила нового ZIP с существующей системой после нормализации; shell runner ZIP не устанавливать. Исправить точность действующих gates перед массовым rollout. Полный подробный план с моделью/reasoning, dependencies, acceptance и rollback:

- `audit-2026-09-05/IMPLEMENTATION_ROADMAP.md`
- основания: `audit-2026-09-05/AUDIT_REPORT.md` и `FINDING_EVIDENCE.md`
- 67 решений по ZIP: `audit-2026-09-05/ARCHIVE_DECISIONS.md`
- покрытие/ограничения: `audit-2026-09-05/COVERAGE.md`

## Состояние внедрения — 2026-09-08

Статус: **implementation in progress**. Блок 0.1 завершён task-level фиксацией владельцев и
границ; это не означает готовность engine, пилотов или release. Все блоки реализации, review и
итоговая проверка выполняются на GPT-5.6 Luna xhigh.

| Владелец | Источник истины и ответственность | Что сюда не переносится |
| --- | --- | --- |
| Documentation Vault | reusable human policy, prompts, skills, templates, registries и boundary rules | app facts, локальные исключения, task history и исполняемый engine |
| QualityControl | executable engine, schemas, adapters, fixtures, workflows и machine evidence | reusable human policy и product/app decisions |
| Project/app repository | project profile/facts, app code, thin launcher/workflow wiring, adoption state и local exceptions | глобальная policy и чужие app overlays |
| Task evidence | plan/handoff, implementation receipts, temporary decisions и recovery evidence | authority для reusable rules, engine или app behavior |

Глобальная активация инженерных правил и подключение QualityControl остаются разными
механизмами: bootstrap действует по canonical boundary, а engine adoption остаётся явным opt-in
с profile, permissions, receipt и rollback. Ручные GitHub/Codex Review, создание/изменение/запуск
тестов, UI/Simulator/Instruments, CI, branch protection и платные сервисы не активируются этим
статусом. Вердикты local readiness, merge readiness и release readiness не объединяются.

Evidence блока 0.1: `audit-2026-09-05/implementation/0.1-authority-boundary.md`.

## Свежий baseline блока 0.2 — 2026-09-08

Receipt `audit-2026-09-05/implementation/0.2-baseline-receipt.json` обновляет audit-era
identities. Documentation Vault, QualityControl main-active, AIZenflow development и AIZenflow
main проверены на чистое состояние; local HEAD совпадает с соответствующим remote ref. Старые
значения `28d11bb…` и `f60d5da…` в историческом audit baseline помечены stale относительно
текущей реализации и не используются как PASS evidence.

На QualityControl main зафиксированы текущие engine/policy inputs: `Package.swift`,
`policies/check-catalog.json` и `schemas/deterministic-check-result.schema.json`. Consumer profile
не подменяется engine revision и будет проверяться в соответствующем project/pilot scope.
Build, tests, toolchain и runtime evidence в этом read-only блоке не создавались.

## Проверенное состояние

- Documentation remote main: `28d11bb79457d62d7fd26cec2ccf5ab1edaccbc6` перед публикацией аудита.
- QC remote main и `AIZenflowQualityControl-main-active`: `f60d5da6c2dca4c2d12c72ed3096a133402ae408`.
- Catalog: 16 implemented, 3 staged, 1 review-candidate. Наличие adapter не равно mode coverage/pilot readiness.
- Foundation, permissions, bounded evidence и canary существуют; не реализовывать их повторно.
- H format/privacy/signing/disabled-test уже реализованы; Swift source gates также добавлены. Остались scope/lexical accuracy, maturity/fixture mapping, SwiftLint, first-party warnings/concurrency diagnostics.
- I manual PR/governance сохраняется; per-change receipt — текущая операция, не одноразовый «готово».
- J: два разных consumer pilots, rollback/idempotence и rollout не завершены.
- Исторические app source blockers требуют свежей проверки в отдельном app scope.

## Сохраняемые ограничения

- Пользователь отдельно управляет созданием, изменением и запуском тестов, UI/Simulator/Instruments, CI/review. Отказ/отсутствие запуска не PASS.
- CI и Codex Review ручные, advisory; отсутствие запуска само по себе не вводит mandatory merge block. Branch protection отложена.
- Не использовать платные runners/API/services или автоматические расходы.
- Policy weakening, HIGH/CRITICAL exceptions, release/promotion и новые consumers требуют соответствующего пользовательского решения.
- Scope reset 2026-08-11 сохраняется по смыслу: новая engine сложность должна устранять реальный false-pass/false-fail/permission/usefulness gap. Hostile-runner attestation, hooks, automated scoring и telemetry platform не возобновляются автоматически.
- App facts/ADR/exceptions остаются у приложения; generic standards — в Documentation; исполняемый код — в QualityControl.
- Глобальные инженерные правила и opt-in adoption engine — отдельные механизмы.
- В текущем блоке разрешены аудит и план. Предыдущая история разрешений не используется для незапрошенной реализации вместо результата аудита.

## Следующие этапы

- [x] 0.1: authority/current state и четыре владельца — Luna xhigh.
- [x] 0.2: свежий baseline evidence — Luna xhigh.
- [ ] 0.3: ранние observations работы Luna — Luna xhigh.
- [ ] 0.4: пять нейтральных сценариев — Luna xhigh.
- [ ] 1.1: единый severity/readiness/exception contract — Luna xhigh.
- [ ] 2: architecture/prompts/skills/package ownership — Luna xhigh.
- [ ] 3: toolchain-aware iOS baseline — Luna xhigh.
- [ ] 4: global bootstrap/effective routes/distribution — Luna xhigh.
- [ ] 5: QC source scope, Swift patterns, disabled-tests, catalog/mode claims — Luna xhigh.
- [ ] 6: SwiftLint + warnings/concurrency diagnostics — Luna xhigh.
- [ ] 7: разрешённая verifier-test/canary фаза — Luna xhigh.
- [ ] 8: простой и сложный app pilots — Luna xhigh.
- [ ] 9: release/promotion и reversible rollout — Luna xhigh.
- [ ] 10: context/калибровка процесса Luna — Luna xhigh.
- [ ] 11: итоговая проверка внедрения — Luna xhigh.

Следующий implementation block: 0.3 — компактные observations работы Luna, без telemetry platform и
без ожидания статистической значимости. Конкретика и критерии приёмки находятся в подробном
roadmap. Ни один implementation checkbox не помечается выполненным только потому, что написан
план.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Pilot → promotion: каждый из двух consumers закрывает полную матрицу этапа 8 roadmap, включая разрешённый runtime mode, local/GitHub parity и pre-PR receipt. Missing/denied evidence оставляет pilot partial и блокирует обычный stable promotion; запуск этим требованием не разрешается. Более узкий release требует отдельного явного решения пользователя.

## Принятые улучшения подготовки — 2026-09-07
Продуктового проекта пока нет; текущие apps — испытательные consumers. План теперь содержит 30 блоков. Добавлены 0.3 (ранние observations Luna), 0.4 (нейтральные сценарии/критерии), 4.3 (new-project flow), 7.2 (generation и detection отдельно), 8.3 (готовность подготовки). Все исполняются Luna xhigh. Начать с 0.1 → 0.2 → 0.3 → 0.4 → 1.1. Никакого продукта, benchmark runner или тестового кода текущая корректировка не создаёт.

Готовность подготовки по 8.3 отделена от stable QC release: обязательные два pilots и вся матрица этапа 8 сохранены. Массовые миграции остальных пробных apps не являются автоматическим prerequisite начала будущего проекта. Этап 10 использует данные с 0.3, а не начинает измерения с нуля.
