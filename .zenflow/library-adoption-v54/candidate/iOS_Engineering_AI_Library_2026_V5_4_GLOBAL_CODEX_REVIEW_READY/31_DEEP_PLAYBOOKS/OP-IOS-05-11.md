---
id: OP-IOS-05-11
type: deep-playbook
source_skill: IOS-05-11
title: Reusable component — Operational Deep Playbook
section: 05_SWIFTUI
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-05-11 — Reusable component

## Mission
создавать composable, accessible, preview/testable component с минимальным API surface

Этот playbook — operational-версия `05_SWIFTUI/IOS-05-11_CUSTOM_COMPONENT.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- minimum OS and Observation availability
- view tree, identity and source-of-truth ownership
- navigation/presentation state and deep-link entry points
- async tasks started by views/models
- accessibility, Dynamic Type, locale and adaptive layout requirements
- Конкретные call sites/owners/tests, затронутые именно задачей «Reusable component».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- owned versus borrowed state is explicit
- view identity remains stable for semantic entities
- body is a pure description without hidden side effects
- async results cannot overwrite newer state
- presentation/navigation derive from coherent typed state

### Topic-specific invariants / traps
- Verify stable identity, reuse, cancellation, prefetching, image decoding, diff application and hitch evidence.
- Control clock/random/network/storage and shared global state; avoid fixed sleeps and order-dependent fixtures.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- prefer Observation/@Observable where availability and project fit allow
- use State for view-owned state and Binding for borrowed mutation
- model loading/content/empty/error and cancellation explicitly
- keep expensive work out of body and measure invalidation/scroll cost
- build accessibility and adaptive layout into component API

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find duplicated state, boolean presentation explosion and unstable ForEach ids
- flag side effects in body/onAppear loops and unbounded Task creation
- check observation dependencies/invalidation, async stale updates and accessibility

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- use state/identity logging and minimal reproduction before adding refresh hacks
- profile scrolling/body invalidation when issue is performance
- verify navigation restoration/deep link sequence with typed route state

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- bridge UIKit/ObservableObject incrementally at stable boundaries
- preserve identity, lifecycle and ownership semantics during migration
- keep availability fallback when deployment target predates Observation API

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
- previews/fixtures for key states plus unit tests for model logic
- UI/integration test for navigation/presentation critical paths
- performance/accessibility checks when affected
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-05-11 «Reusable component» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: создавать composable, accessible, preview/testable component с минимальным API surface.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
