---
id: OP-IOS-26-07
type: deep-playbook
source_skill: IOS-26-07
title: Empty/error state system — Operational Deep Playbook
section: 29_DESIGN_SYSTEM
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-26-07 — Empty/error state system

## Mission
standardize recoverable actions, copy, analytics, accessibility and offline distinctions

Этот playbook — operational-версия `29_DESIGN_SYSTEM/IOS-26-07_EMPTY_ERROR_STATES.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- token/component source of truth
- semantic versus raw color/spacing/typography tokens
- component variants/states/accessibility
- SwiftUI/UIKit sharing strategy
- snapshot/previews and visual regression process
- Конкретные call sites/owners/tests, затронутые именно задачей «Empty/error state system».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- components encode semantic states, not product-specific hacks
- tokens support dark/high-contrast/Dynamic Type
- API surface stays small and composable
- accessibility semantics are preserved by default
- breaking visual/API changes are versioned or migrated intentionally

### Topic-specific invariants / traps
- For **Empty/error state system**, derive at least one concrete repository/task failure scenario from the source skill, actual owners/callers/tests and acceptance criteria; record the invariant that would falsify the proposed change.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- build primitive tokens then reusable components then feature composition
- prefer semantic names and system behavior
- document escape hatches rather than expose every styling knob

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find duplicated magic values and inaccessible custom controls
- check variant explosion and feature-specific logic in core components
- verify environment/theme invalidation cost

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reproduce visual issue across theme/text-size/locale matrix
- inspect component/token ownership before local override

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- introduce token/component migration incrementally with compatibility aliases
- remove old tokens only after usage inventory is zero

Обязательно определить: compatibility window, old/new coexistence, data/API behavior parity, rollout/rollback и legacy cleanup criterion.

## Failure-mode checklist
- Happy path работает, но error/cancellation/permission/offline path оставляет stale or impossible state.
- Lifetime owner не совпадает с async/resource lifetime.
- Новый API доступен не на всём deployment range.
- Test double/fixture проверяет реализацию, но не реальный контракт boundary.
- Локальный fix нарушает consumer в extension/widget/watch/other module.
- Логи/analytics становятся источником PII/secrets.
- «Оптимизация» или «упрощение» не имеет before/after evidence.
- Миграция удаляет старый путь до доказанной behavioral parity.

## Verification ladder для этой темы
- preview/snapshot matrix
- accessibility/Dynamic Type audit
- API usage inventory
- `build` affected target/module.
- Проверить warnings/concurrency diagnostics, относящиеся к diff.
- Проверить exact negative path, который наиболее вероятно сломает инвариант.

## Agent output contract
```text
Mode: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>
Risk: <R0..R4>

Facts:
- ...
Assumptions:
- ...

Invariants:
1. ...

Decision:
- chosen approach
- rejected alternative(s) and why

Changes / Findings:
- file:line / exact scope

Verification:
- command/test/instrument → observed result

Impact:
- concurrency
- memory/lifetime
- security/privacy
- performance
- availability/migration

Rollback / containment:
- ...

Unknowns:
- ...
```

## Copy-paste execution prompt
```text
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-26-07 «Empty/error state system» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: standardize recoverable actions, copy, analytics, accessibility and offline distinctions.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
