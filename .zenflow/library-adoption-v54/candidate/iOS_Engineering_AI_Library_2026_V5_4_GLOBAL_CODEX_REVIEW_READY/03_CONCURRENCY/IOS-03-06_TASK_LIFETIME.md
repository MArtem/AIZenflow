---
id: IOS-03-06
type: skill
title: Task lifetime & ownership
domain: Swift Concurrency
priority: production
baseline: Swift 6 / modern iOS
---

# Task lifetime & ownership

## Назначение
Связать task с владельцем feature/view/model, избежать orphan tasks и capture cycles.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **связать task с владельцем feature/view/model, избежать orphan tasks и capture cycles**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: actor isolation, Sendable, cancellation, task lifetime, reentrancy, MainActor hops.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-03-06: «Task lifetime & ownership».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: связать task с владельцем feature/view/model, избежать orphan tasks и capture cycles.
Проверь: actor isolation, Sendable, cancellation, task lifetime, reentrancy, MainActor hops.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-03-06.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — task ownership across suspension

**Scenario.** A screen/model starts an unstructured `Task`, stores its handle, and expects the work to stop when the owner is replaced or released.

**Common wrong approach.** Capture `[weak self]`, immediately promote `self` to a strong local before a long `await`, and assume `deinit { task.cancel() }` bounds the task lifetime. The strong local can keep the owner alive across suspension, so deinitialization may not happen when the external owner disappears.

**Preferred approach.** Decide the lifetime contract first. Prefer structured child tasks when the parent operation naturally owns the work. For owner-managed unstructured work, capture only the dependency/value state needed across suspension, keep an explicit cancellable handle, cancel on the real lifecycle/replacement event, and reacquire/check owner/state only when applying the result. Treat cancellation as cooperative rather than as forced termination.

**Traps / edge cases.** Dependencies that ignore cancellation; old task success arriving after replacement; generic non-`CancellationError` failure arriving after cancellation; multiple starts racing; `MainActor` UI updates from stale generations; an owner retaining a task while the task retains the owner; cancellation after the irreversible side effect already occurred.

**Verification.** Test at least pending-operation release/replacement, explicit cancellation, stale success, stale generic failure, and repeated-start ordering. Use a controllable suspended dependency so the test proves whether the owner can be released and whether a superseded task can still mutate current UI state.

**Compatibility.** Exact isolation and `Sendable` diagnostics depend on the project’s Swift language mode and toolchain. Do not introduce `@unchecked Sendable` merely to silence a migration error; prove the ownership/isolation contract instead.

Primary sources checked 2026-09-11: https://developer.apple.com/documentation/swift/task/cancel%28%29, https://developer.apple.com/documentation/swift/task/checkcancellation%28%29, and https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/

