---
id: IOS-03-07
type: skill
title: Cancellation
domain: Swift Concurrency
priority: production
baseline: Swift 6 / modern iOS
---

# Cancellation

## Назначение
Сделать cooperative cancellation сквозной: network, parsing, loops, child tasks и UI state.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **сделать cooperative cancellation сквозной: network, parsing, loops, child tasks и UI state**.
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
Ты работаешь как Staff iOS engineer. Примени skill IOS-03-07: «Cancellation».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: сделать cooperative cancellation сквозной: network, parsing, loops, child tasks и UI state.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-03-07.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — cancellation semantics

**Scenario.** A user starts request A, immediately replaces it with B, and A later completes with either success or a non-`CancellationError` failure.

**Common wrong approach.** Treating `Task.cancel()` as forced termination, or checking cancellation only on the success path. This lets stale A update UI or display an obsolete error.

**Preferred approach.** Make cancellation part of the operation contract: cancel replaced work, check cancellation at meaningful suspension/loop boundaries, and gate every externally visible completion by current request identity/generation. Suppress a generic failure if the task has already been cancelled/replaced.

**Traps / edge cases.** Dependencies may ignore cooperative cancellation; cancellation handlers can themselves race with completion; actor reentrancy means state can change while an async operation is suspended; retry loops need an explicit cancellation exit before sleeping or issuing another attempt.

**Verification.** Test replacement A→B with controlled continuations: old success, old `CancellationError`, and old generic failure must not mutate B's state. Verify deallocation separately when task lifetime is owner-bounded.

**Compatibility.** Do not use an availability-new helper if the project toolchain does not provide it. Preserve the same semantic checks using APIs supported by the project.

Primary sources checked 2026-09-11: https://developer.apple.com/documentation/swift/task/cancel%28%29 and https://developer.apple.com/documentation/swift/task/checkcancellation%28%29 — cancellation is cooperative; cancellation checks are part of the operation contract.

