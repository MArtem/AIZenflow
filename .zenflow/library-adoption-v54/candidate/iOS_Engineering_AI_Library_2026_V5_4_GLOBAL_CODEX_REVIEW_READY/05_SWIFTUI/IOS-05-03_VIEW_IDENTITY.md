---
id: IOS-05-03
type: skill
title: View identity
domain: SwiftUI
priority: production
baseline: Swift 6 / modern iOS
---

# View identity

## Назначение
Устранить bugs от неверной identity, conditional trees, ForEach ids и state resets.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **устранить bugs от неверной identity, conditional trees, ForEach ids и state resets**.
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
Ты работаешь как Staff iOS engineer. Примени skill IOS-05-03: «View identity».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: устранить bugs от неверной identity, conditional trees, ForEach ids и state resets.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-05-03.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — state and identity

**Scenario.** A list/navigation subtree unexpectedly loses state, reuses the wrong state, or performs excessive updates after data changes.

**Common wrong approach.** Add `.id(UUID())`, index-based identity, or extra `@State` until the symptom disappears. That often destroys stable identity and masks ownership errors.

**Preferred approach.** Define stable domain identity, keep state at the narrowest real owner, and let data flow determine updates. Treat identity changes as lifecycle changes: they may recreate state and side effects.

**Traps / edge cases.** Reordering collections, duplicate IDs, transient wrapper values, navigation destinations, conditional branches that change structural identity, and observation dependencies that cause wider-than-expected invalidation.

**Verification.** Exercise insertion/deletion/reordering, navigation away/back, state restoration where relevant, and use SwiftUI performance tooling when update frequency is the concern rather than guessing from code shape.

Primary sources checked 2026-09-10: https://developer.apple.com/documentation/swiftui/state and https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance

**Compatibility.** Evaluate identity/state behavior against the SwiftUI APIs and observation model actually available at the project's minimum deployment target and Xcode/Swift toolchain. Do not migrate to newer observation APIs solely for stylistic consistency when the deployment/toolchain contract does not support them.
