---
id: IOS-09-05
type: skill
title: Data migrations
domain: Persistence & Data
priority: production
baseline: Swift 6 / modern iOS
---

# Data migrations

## Назначение
Versioning, lightweight/custom migration, backups, rollback, telemetry и large-store performance.

## Когда применять
- При реализации новой функциональности в этой области.
- При code review/refactor/migration, если затронут соответствующий риск.
- При расследовании production-дефекта, связанного с этой областью.

## Обязательные входы
- Relevant project context из `00_META/PROJECT_CONTEXT_TEMPLATE.md`.
- Затронутые файлы/модули и соседние реализации.
- Minimum deployment target и фактический toolchain.
- Acceptance criteria и ограничения на public API/dependencies/migration.

## Алгоритм skill
1. Найди существующий паттерн в репозитории и определи владельца state/lifecycle.
2. Зафиксируй инварианты и failure modes именно для задачи: **versioning, lightweight/custom migration, backups, rollback, telemetry и large-store performance**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: integrity, migrations, concurrency, transactions, fetch performance, data loss recovery.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-09-05: «Data migrations».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: versioning, lightweight/custom migration, backups, rollback, telemetry и large-store performance.
Проверь: integrity, migrations, concurrency, transactions, fetch performance, data loss recovery.
Следуй `QUALITY_STANDARD.md`, сохраняй минимальный diff и не вводи abstraction без причины.
Добавь/обнови релевантные тесты и выполни доступные build/test/lint проверки.

В ответе дай:
1) решение и почему оно минимально рискованное;
2) изменения по файлам;
3) tests/verification;
4) concurrency/memory/security/privacy/performance impact, если применимо;
5) риски и что осталось непроверенным.
```

## Definition of success
Решение сохраняет инварианты проекта, проходит релевантные проверки и не создаёт новый скрытый lifecycle/concurrency/security/performance долг.

## V2 operational binding
Перед выполнением этого skill прочитай `00_META/V2_EXECUTION_PROTOCOL.md` и выбери режим `IMPLEMENTATION`, `REVIEW`, `DIAGNOSTIC` или `MIGRATION`. Для задач риска R2+ также применяй `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`, `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md` и `00_META/CHANGE_RISK_MATRIX.md`.

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-09-05.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — migration invariants

**Scenario.** A shipped store must move from schema N to N+1 while existing installations may contain old, partial, large, or previously migrated data.

**Common wrong approach.** Editing the current model until a clean install works, then treating that as migration evidence. A clean database proves almost nothing about upgrade safety.

**Preferred approach.** Version the persisted contract, enumerate semantic invariants before code changes, preserve a representative old-store fixture, migrate through supported historical paths, and make irreversible deletion the last step after validation. Distinguish schema compatibility from business-data transformation.

**Traps / edge cases.** Optional→required fields, uniqueness changes, identifier remapping, relationship cardinality, partial prior migrations, interrupted migration, disk-full conditions, locale/time-zone assumptions, and rollback to an older app version.

**Verification.** Open representative pre-upgrade stores, migrate, assert row/object counts and key domain invariants, reopen the migrated store, and verify failure/rollback behavior. If production history spans multiple schema versions, test the supported upgrade matrix rather than only N→N+1.

**Compatibility.** SwiftData migration APIs are deployment/toolchain sensitive; Core Data or custom storage may require a different mechanism, but the semantic invariant and fixture discipline remains.

Primary source checked 2026-09-10: https://developer.apple.com/documentation/SwiftData/SchemaMigrationPlan. This documents the SwiftData versioned-schema and migration-stage API; successful data preservation, disk-full handling, interruption, and rollback still require the app's old-store fixtures and migration evidence.
