---
id: IOS-13-01
type: skill
title: VoiceOver
domain: Accessibility & Localization
priority: production
baseline: Swift 6 / modern iOS
---

# VoiceOver

## Назначение
Semantic labels/values/hints/actions, grouping, focus order и dynamic updates.

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
2. Зафиксируй инварианты и failure modes именно для задачи: **semantic labels/values/hints/actions, grouping, focus order и dynamic updates**.
3. Сравни минимально два варианта, если решение затрагивает architecture/public contract или добавляет dependency.
4. Реализуй минимальный diff, следуя `00_META/QUALITY_STANDARD.md`.
5. Проверь тематические quality gates: VoiceOver, Dynamic Type, RTL, locale, motion, text expansion.
6. Добавь тесты/diagnostics пропорционально риску.
7. Запусти доступные build/test/lint проверки и отдели проверенное от предположений.

## Anti-patterns
- Подмена design-проблемы suppression, force unwrap, global mutable state или "временным" unchecked escape hatch.
- Создание нового слоя/manager/protocol без измеримой пользы для coupling/testability.
- Изменение unrelated кода и массовое форматирование в том же diff.
- Утверждение о корректности без build/tests/measurement, когда их можно выполнить.

## Готовый prompt
```text
Ты работаешь как Staff iOS engineer. Примени skill IOS-13-01: «VoiceOver».

Контекст проекта: <вставь PROJECT_CONTEXT>.
Задача: <что должно наблюдаемо измениться>.
Ограничения: <deployment target, public API, dependencies, migration, performance>.

Перед кодом изучи существующую реализацию и аналоги в репозитории. Назови source of truth/lifetime/dependency boundaries и ключевые инварианты.
Особый фокус: semantic labels/values/hints/actions, grouping, focus order и dynamic updates.
Проверь: VoiceOver, Dynamic Type, RTL, locale, motion, text expansion.
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

Глубокая operational-версия этого skill: `31_DEEP_PLAYBOOKS/OP-IOS-13-01.md`. Она задаёт обязательные факты, инварианты, режимы исполнения, failure modes и verification ladder.

## Review-ready depth — accessibility traversal

**Scenario.** A custom composite control is visually clear but VoiceOver order, labels, actions, or focus behavior are confusing.

**Common wrong approach.** Infer accessibility quality from the view hierarchy or add labels without testing traversal. Visual order is not sufficient evidence of the assistive experience.

**Preferred approach.** Define the semantic element boundaries, labels/values/hints/actions, focus order, and state announcements based on user intent. Prefer native controls/semantics when they already express the interaction correctly.

**Traps / edge cases.** Dynamic content insertion, modal focus, custom gestures without equivalent actions, hidden decorative content, repeated labels, large text reflow, reduced motion, and right-to-left layouts.

**Verification.** Perform actual VoiceOver traversal and action testing on a representative device/simulator setup; supplement with Accessibility Inspector/static checks, but do not replace manual interaction evidence with them.

Compatibility: behavior can vary by OS and control implementation; verify on the deployment range that matters to the product.


Primary source checked 2026-09-11: https://developer.apple.com/documentation/uikit/supporting-voiceover-in-your-app — manual VoiceOver navigation is part of the verification evidence for traversal/semantics.
