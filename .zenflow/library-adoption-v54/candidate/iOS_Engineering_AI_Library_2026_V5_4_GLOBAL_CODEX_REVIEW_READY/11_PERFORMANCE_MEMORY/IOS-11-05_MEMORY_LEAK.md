---
id: IOS-11-05
type: skill
title: Leak diagnosis
domain: Performance & Memory
priority: production
baseline: Swift 6 / modern iOS
---

# Leak diagnosis

## Назначение
Retain path, closures/tasks/delegates/timers/observers, lifecycle и deterministic reproduction.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **retain path, closures/tasks/delegates/timers/observers, lifecycle и deterministic reproduction**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: baseline metric, instrument evidence, main-thread impact, allocations, energy, regression guard.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-11-05: «Leak diagnosis».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: retain path, closures/tasks/delegates/timers/observers, lifecycle и deterministic reproduction.
Проверь: baseline metric, instrument evidence, main-thread impact, allocations, energy, regression guard.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-11-05.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — ownership before “leak” labels

**Scenario.** A screen is dismissed but one or more objects remain alive.

**Common wrong approach.** Call every delayed deallocation a retain cycle, or mechanically add `weak` without finding the owning path. This can create premature deallocation while leaving the real owner unchanged.

**Preferred approach.** Reconstruct the ownership graph and expected lifetime first. Distinguish a true cycle from intentional cache ownership, a pending task/closure, framework retention, or delayed teardown. Change ownership only where the semantic owner is wrong.

**Traps / edge cases.** Tasks that promote weak self before `await`, timers/display links, notification/observation tokens, closure properties, delegates with unexpected strength, caches, and ObjC bridging.

**Verification.** Repeat the lifecycle, capture a memory graph/Allocations evidence, identify the retain path, then re-run the same scenario after the smallest ownership fix. Add a deterministic lifetime test where the architecture permits one.

Primary sources checked 2026-09-10: https://developer.apple.com/documentation/xcode/gathering-information-about-memory-use and https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/

**Compatibility.** Diagnose ownership with the language/runtime and framework behavior used by the supported deployment range. Prefer semantic ownership fixes that work across the current target range; availability-specific diagnostics or APIs are evidence tools, not reasons to raise the deployment target.
