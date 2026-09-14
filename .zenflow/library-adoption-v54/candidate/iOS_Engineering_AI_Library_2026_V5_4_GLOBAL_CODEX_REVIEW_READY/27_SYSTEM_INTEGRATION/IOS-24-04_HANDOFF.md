---
id: IOS-24-04
type: skill
title: NSUserActivity/Handoff
domain: System Integration & Extensions
priority: production
baseline: Swift 6 / modern iOS
---

# NSUserActivity/Handoff

## Назначение
Activity types, eligibility, state serialization, continuity, privacy и restoration.

## Когда применять
- При новой интеграции, развитии существующей feature или review этой технологии.
- При миграции SDK/API и расследовании platform-specific дефектов.

## Обязательные входы
- `00_META/PROJECT_CONTEXT_TEMPLATE.md` и `00_META/QUALITY_STANDARD.md`.
- Minimum deployment target, entitlements/capabilities/background modes.
- Реальный data/lifecycle flow и ограничения устройства/системы.
- Product expectations: offline/background/privacy/accessibility/performance.

## Алгоритм skill
1. Проверь platform availability, entitlement/permission и lifecycle constraints.
2. Найди существующие wrappers/adapters и ownership model в репозитории.
3. Сформулируй state machine, failure/interruption paths и recovery.
4. Реализуй минимальный API surface и минимальный diff.
5. Проверь: state size, identifiers, privacy, restoration, multi-device failure, availability.
6. Добавь deterministic tests там, где возможно; hardware/system behavior изолируй за test seam без protocol explosion.
7. Для performance-sensitive API добавь measurement/signpost; для privacy-sensitive API — data minimization/redaction.

## Anti-patterns
- Считать system callback гарантированным или своевременным без учёта interruption/background/permission state.
- Держать hardware/session resource без явного lifetime и teardown.
- Игнорировать denied/restricted/unavailable/thermal/memory/background states.
- Добавлять third-party SDK до проверки системного API и privacy/dependency cost.

## Готовый prompt
```text
Примени skill IOS-24-04: «NSUserActivity/Handoff» как Staff iOS engineer.
Контекст: <PROJECT_CONTEXT>.
Задача: <observable outcome>.
Ограничения: <min iOS, capabilities/entitlements, privacy, offline/background, dependencies>.

Сначала опиши lifecycle/state machine и системные ограничения. Особый фокус: activity types, eligibility, state serialization, continuity, privacy и restoration.
Проверь: state size, identifiers, privacy, restoration, multi-device failure, availability.
Следуй QUALITY_STANDARD.md. Не выдумывай API/availability. Сохраняй минимальный diff, добавь tests/fixtures/diagnostics и выполни доступные build/test checks.
Финал: changed files, rationale, lifecycle/permission/concurrency impact, verification, risks/fallbacks.
```

## V2 operational binding
Перед выполнением этого skill прочитай `00_META/V2_EXECUTION_PROTOCOL.md` и выбери режим `IMPLEMENTATION`, `REVIEW`, `DIAGNOSTIC` или `MIGRATION`. Для задач риска R2+ также применяй `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`, `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md` и `00_META/CHANGE_RISK_MATRIX.md`.

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-24-04.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.
