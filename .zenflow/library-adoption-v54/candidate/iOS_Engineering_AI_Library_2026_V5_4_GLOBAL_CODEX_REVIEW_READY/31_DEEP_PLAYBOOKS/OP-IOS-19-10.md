---
id: OP-IOS-19-10
type: deep-playbook
source_skill: IOS-19-10
title: Refactor review — Operational Deep Playbook
section: 19_CODE_REVIEW_REFACTOR
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-19-10 — Refactor review

## Mission
behavior parity, API compatibility, test adequacy, migration, performance и readability

Этот playbook — operational-версия `19_CODE_REVIEW_REFACTOR/IOS-19-10_REFACTOR_REVIEW.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- diff plus surrounding callers/owners/tests
- ticket/behavioral intent
- public API and dependency blast radius
- concurrency/lifecycle boundaries touched
- baseline tests/metrics before refactor
- Конкретные call sites/owners/tests, затронутые именно задачей «Refactor review».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- review findings are actionable and evidence-based
- refactor preserves externally observable behavior unless stated
- diff stays minimal and logically separable
- tests characterize behavior rather than implementation accident
- style preferences do not obscure correctness issues

### Topic-specific invariants / traps
- Verify schema history, previous-version store fixtures, context/actor isolation, uniqueness/delete rules and rollback/data-loss policy.
- Control clock/random/network/storage and shared global state; avoid fixed sleeps and order-dependent fixtures.
- Record baseline, bottleneck instrument, representative device/workload and before/after metric before claiming improvement.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- characterize behavior first
- move one responsibility/seam at a time
- delete abstraction only after call-site and dynamic usage search
- add regression tests around prior bug/smell boundary

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- rank by severity/likelihood/blast radius
- explain failure scenario and minimal fix
- search surrounding code when diff alone cannot prove safety

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- use failing test/metric/crash evidence to identify actual design pressure
- avoid speculative rewrite for unproven root cause

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- retain compatibility adapters only for defined window
- remove legacy path when telemetry/tests prove parity

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
- targeted regression suite
- API/behavior comparison
- diff review for accidental unrelated changes
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-19-10 «Refactor review» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: behavior parity, API compatibility, test adequacy, migration, performance и readability.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
