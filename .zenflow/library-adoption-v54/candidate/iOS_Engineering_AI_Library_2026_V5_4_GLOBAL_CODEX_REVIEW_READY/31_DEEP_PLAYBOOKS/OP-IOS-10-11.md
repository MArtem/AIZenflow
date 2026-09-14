---
id: OP-IOS-10-11
type: deep-playbook
source_skill: IOS-10-11
title: Test doubles — Operational Deep Playbook
section: 10_TESTING
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-10-11 — Test doubles

## Mission
fake/stub/spy выбирать по поведению; избегать brittle mocks по implementation details

Этот playbook — operational-версия `10_TESTING/IOS-10-11_TEST_DOUBLES.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- current Swift Testing/XCTest/XCUITest conventions
- test plans, parallelization and CI sharding
- fixtures, clocks, random/UUID/network/persistence seams
- flaky/quarantined tests and historical failures
- coverage of changed behavior rather than raw percentage
- Конкретные call sites/owners/tests, затронутые именно задачей «Test doubles».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- tests are deterministic and independent of order
- no real network/wall clock/randomness unless explicitly integration-scoped
- failure message identifies violated behavior
- parallel execution cannot share mutable global fixture state
- test double preserves the semantic contract it replaces

### Topic-specific invariants / traps
- Control clock/random/network/storage and shared global state; avoid fixed sleeps and order-dependent fixtures.
- Treat model output as untrusted; enforce tool authorization/idempotency in code and run evals across model/OS changes.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- prefer Swift Testing for new unit/integration tests when project/toolchain fit
- parameterize meaningful input spaces
- use controlled Clock/time zone/locale/UUID/random sources
- test cancellation/errors and boundary contracts, not implementation trivia

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- detect sleeps, order dependence, shared singleton state and over-mocking
- check missing negative/concurrency/migration cases
- ensure UI tests wait on observable conditions rather than fixed delays

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- re-run with seed/environment captured
- bisect shared state, timing, simulator/device and service dependencies
- turn flaky behavior into a minimal deterministic stress/ordering test

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- move XCTest to Swift Testing only where value exceeds churn
- preserve CI reporting/traits/tags and unsupported XCTest-only features where needed

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
- repeat failing/flaky test enough to establish signal
- run targeted and relevant suite
- record environment and seed for reproducibility
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-10-11 «Test doubles» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: fake/stub/spy выбирать по поведению; избегать brittle mocks по implementation details.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
