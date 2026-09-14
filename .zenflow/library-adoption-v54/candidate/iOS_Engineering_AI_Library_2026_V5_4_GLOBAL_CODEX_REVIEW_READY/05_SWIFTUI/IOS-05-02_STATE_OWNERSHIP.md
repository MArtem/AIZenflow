---
id: IOS-05-02
type: skill
title: State ownership
domain: SwiftUI
priority: production
baseline: Swift 6 / modern iOS
---

# State ownership

## Назначение
Различать owned state, bindings, environment dependencies и derived state.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **различать owned state, bindings, environment dependencies и derived state**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: source of truth, view identity, invalidation, async lifetime, accessibility, availability.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-05-02: «State ownership».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: различать owned state, bindings, environment dependencies и derived state.
Проверь: source of truth, view identity, invalidation, async lifetime, accessibility, availability.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-05-02.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — SwiftUI source-of-truth ownership

**Scenario.** A feature shows duplicated or resetting UI state because the same logical value is independently stored in a parent, child, and model, or because view-local state is being used as durable domain state.

**Common wrong approach.** Add another `@State` copy to make a child editable, synchronize copies with `onChange`, or move every value into a global observable object. This obscures the single source of truth and creates ordering/reset bugs instead of defining ownership.

**Preferred approach.** Place transient view state at the least common ancestor that genuinely owns its lifetime. Pass read-only values downward when children only observe and bindings when they are authorized to mutate the same source of truth. Keep durably persisted data in its persistence layer; view-lifetime storage may own a view model or observable reference when that lifetime is intentional. Derive values rather than storing a second independently mutable copy when derivation is deterministic.

**Traps / edge cases.** View identity changes that recreate state; default state initialization with expensive/side-effecting work; optional navigation state; two-way binding across an ownership boundary that should be command-based; async work writing into state after the owning identity changed; observable reference objects whose lifetime is mistaken for the value-type view’s lifetime.

**Verification.** Exercise identity-preserving updates and identity replacement separately. Verify navigation/back-forward recreation, parent/child edits, async completion after replacement, and persistence/relaunch behavior where applicable. A passing render snapshot alone does not prove correct state ownership.

**Compatibility.** SwiftUI state APIs and observation behavior are SDK/toolchain sensitive. Follow the project’s deployment target and currently compiled observation model rather than assuming the newest API is available.

Primary sources checked 2026-09-11: https://developer.apple.com/documentation/swiftui/state and https://developer.apple.com/documentation/swiftui/managing-user-interface-state
