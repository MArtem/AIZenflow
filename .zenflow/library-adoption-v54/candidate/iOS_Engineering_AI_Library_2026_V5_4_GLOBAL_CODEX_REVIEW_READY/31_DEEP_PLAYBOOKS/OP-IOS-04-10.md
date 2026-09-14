---
id: OP-IOS-04-10
type: deep-playbook
source_skill: IOS-04-10
title: Modular architecture — Operational Deep Playbook
section: 04_ARCHITECTURE
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-04-10 — Modular architecture

## Mission
проектировать граф модулей по ownership/build/test boundaries, избегая циклов и микромодулей

Этот playbook — operational-версия `04_ARCHITECTURE/IOS-04-10_MODULAR_ARCHITECTURE.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- feature dependency graph and module boundaries
- actual state/effect ownership
- existing DI approach and test seams
- public interfaces and cross-feature coupling
- team/release constraints that make a pattern costly or valuable
- Конкретные call sites/owners/tests, затронутые именно задачей «Modular architecture».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- there is one source of truth for each piece of mutable feature state
- dependency direction is explicit
- abstraction protects a volatile boundary or test seam
- navigation/data/infrastructure responsibilities do not collapse into a god object
- architecture reduces change amplification rather than only file count

### Topic-specific invariants / traps
- Use ownership graph plus runtime deinit/Memory Graph evidence; inspect tasks, timers, notifications, delegates and closures.
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
- design around domain/state transitions before naming layers
- inject only dependencies that consumers actually need
- use protocols at substitution boundaries, not every concrete type
- keep feature boundary small and observable

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- detect duplicated state and service-locator/global-container usage
- measure abstraction fan-out and meaningless pass-through layers
- check that effect ownership, errors and cancellation remain visible

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- trace a bug end-to-end through state owner and side-effect boundary
- identify which boundary allowed invalid state or hidden dependency
- prefer local seam repair before broad rewrite

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- characterize behavior with tests before moving responsibilities
- migrate one vertical slice and compare behavior/metrics
- keep old/new boundary interoperable until rollback risk is low

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
- architecture decision backed by concrete dependency/call-site evidence
- behavior tests across moved boundary
- no new cycles or unnecessary public surface
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-04-10 «Modular architecture» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: проектировать граф модулей по ownership/build/test boundaries, избегая циклов и микромодулей.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
