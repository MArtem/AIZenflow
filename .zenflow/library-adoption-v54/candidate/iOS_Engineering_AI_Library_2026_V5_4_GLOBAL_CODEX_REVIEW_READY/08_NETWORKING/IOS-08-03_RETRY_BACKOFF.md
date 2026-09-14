---
id: IOS-08-03
type: skill
title: Retry/backoff
domain: Networking
priority: production
baseline: Swift 6 / modern iOS
---

# Retry/backoff

## Назначение
Retry только безопасных операций, exponential backoff+jitter, Retry-After и retry budget.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **retry только безопасных операций, exponential backoff+jitter, Retry-After и retry budget**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: HTTP semantics, cancellation, retry/idempotency, auth, decoding, privacy-safe logging.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-08-03: «Retry/backoff».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: retry только безопасных операций, exponential backoff+jitter, Retry-After и retry budget.
Проверь: HTTP semantics, cancellation, retry/idempotency, auth, decoding, privacy-safe logging.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-08-03.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — retry policy

**Scenario.** A request fails transiently under poor connectivity or server overload.

**Common wrong approach.** Retry every failure a fixed number of times without considering method semantics, cancellation, server guidance, or request body replayability.

**Preferred approach.** Retry only classified transient failures and only when replay is semantically safe. Use bounded attempts, backoff with jitter where appropriate, cancellation-aware waiting, and server-provided retry guidance when contractually valid. Non-idempotent operations need an application-level idempotency strategy before automatic replay.

**Traps / edge cases.** Partial uploads, streaming bodies, auth refresh interacting with retry counters, background transfer semantics, duplicated payments/mutations, retry-after parsing, and network-path changes.

**Verification.** Use a deterministic fake clock/transport to test attempt count, delay sequence, cancellation during backoff, terminal errors, and duplicate-side-effect prevention.

Primary networking source checked 2026-09-10: https://developer.apple.com/documentation/foundation/handling-an-authentication-challenge (authentication boundary); endpoint-specific retry semantics remain server-contract evidence, not an Apple default.



Primary transport source checked 2026-09-11: https://developer.apple.com/documentation/foundation/urlsession. HTTP retry guidance source: https://www.rfc-editor.org/rfc/rfc9110.html#name-retry-after. `URLSession` defines transport/task behavior; whether a failed application operation is safe to replay still comes from HTTP/application/server semantics, not from the existence of URLSession itself.

**Compatibility.** Keep retry semantics compatible with the app's deployed OS range and its actual transport/server contract. Do not assume newer networking conveniences exist on the minimum target; preserve request-body replay and background-session behavior used by the current implementation.
