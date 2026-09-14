---
id: IOS-23-04
type: skill
title: ML model update/distribution
domain: Vision, ML, AR & Spatial
priority: production
baseline: Swift 6 / modern iOS
---

# ML model update/distribution

## Назначение
Версионировать models, validate signatures/compatibility, staged rollout, fallback и storage budget.

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
5. Проверь: model provenance, version compatibility, rollback, disk, privacy, evals.
6. Добавь deterministic tests там, где возможно; hardware/system behavior изолируй за test seam без protocol explosion.
7. Для performance-sensitive API добавь measurement/signpost; для privacy-sensitive API — data minimization/redaction.

## Anti-patterns
- Считать system callback гарантированным или своевременным без учёта interruption/background/permission state.
- Держать hardware/session resource без явного lifetime и teardown.
- Игнорировать denied/restricted/unavailable/thermal/memory/background states.
- Добавлять third-party SDK до проверки системного API и privacy/dependency cost.

## Готовый prompt
```text
Примени skill IOS-23-04: «ML model update/distribution» как Staff iOS engineer.
Контекст: <PROJECT_CONTEXT>.
Задача: <observable outcome>.
Ограничения: <min iOS, capabilities/entitlements, privacy, offline/background, dependencies>.

Сначала опиши lifecycle/state machine и системные ограничения. Особый фокус: версионировать models, validate signatures/compatibility, staged rollout, fallback и storage budget.
Проверь: model provenance, version compatibility, rollback, disk, privacy, evals.
Следуй QUALITY_STANDARD.md. Не выдумывай API/availability. Сохраняй минимальный diff, добавь tests/fixtures/diagnostics и выполни доступные build/test checks.
Финал: changed files, rationale, lifecycle/permission/concurrency impact, verification, risks/fallbacks.
```

## V2 operational binding
Перед выполнением этого skill прочитай `00_META/V2_EXECUTION_PROTOCOL.md` и выбери режим `IMPLEMENTATION`, `REVIEW`, `DIAGNOSTIC` или `MIGRATION`. Для задач риска R2+ также применяй `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`, `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md` и `00_META/CHANGE_RISK_MATRIX.md`.

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-23-04.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.
