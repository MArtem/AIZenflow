---
id: OP-IOS-01-04
type: deep-playbook
source_skill: IOS-01-04
title: Feature flags и staged rollout — Operational Deep Playbook
section: 01_DISCOVERY_PRODUCT
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-01-04 — Feature flags и staged rollout

## Mission
спроектировать flag ownership, default states, kill switch, analytics, cleanup date, remote/local failure semantics

Этот playbook — operational-версия `01_DISCOVERY_PRODUCT/IOS-01-04_FEATURE_FLAG_PLAN.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- ticket/acceptance criteria and product copy
- affected feature flags, analytics and rollout constraints
- existing feature analogs and ADRs
- backend/API contracts and error semantics
- minimum OS/device/locale/accessibility requirements
- Конкретные call sites/owners/tests, затронутые именно задачей «Feature flags и staged rollout».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- observable acceptance criteria are testable
- scope excludes unrelated redesign
- failure/offline/permission states are explicit
- analytics and privacy requirements are not invented after implementation
- unknown product decisions remain explicit assumptions

### Topic-specific invariants / traps
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
- translate requirements into state transitions and acceptance tests before code
- identify technical spikes only for real uncertainty
- prefer reversible decisions while requirements are still volatile
- record architecture-impacting choices in an ADR when warranted

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- look for ambiguous acceptance criteria that can produce divergent implementations
- check hidden platform constraints and cross-target effects
- flag scope creep and irreversible decisions without evidence

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reduce product symptom to a reproducible technical behavior
- separate requirement gap from implementation defect
- capture environment, account/state and feature-flag conditions

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- preserve current externally observable behavior unless requirement explicitly changes it
- stage requirement/contract changes behind compatibility or flags when needed

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
- acceptance criteria mapped to tests or manual checks
- edge/failure states explicitly verified
- dependencies and rollout assumptions recorded
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-01-04 «Feature flags и staged rollout» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: спроектировать flag ownership, default states, kill switch, analytics, cleanup date, remote/local failure semantics.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
