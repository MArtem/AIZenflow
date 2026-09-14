---
id: OP-IOS-17-02
type: deep-playbook
source_skill: IOS-17-02
title: CI test parallelism — Operational Deep Playbook
section: 17_CI_CD_RELEASE
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-17-02 — CI test parallelism

## Mission
sharding, simulator allocation, shared-state isolation, retries only as diagnostics и result merging

Этот playbook — operational-версия `17_CI_CD_RELEASE/IOS-17-02_TEST_PARALLELISM.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- branch/release workflow and test plans
- signing/provisioning/secrets ownership
- build artifact/versioning rules
- TestFlight/App Store submission automation
- feature flags/migrations/rollback and observability gates
- Конкретные call sites/owners/tests, затронутые именно задачей «CI test parallelism».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- same source revision produces traceable artifact
- secrets never appear in logs/artifacts
- release can be stopped/contained when critical metric fails
- migration and backend compatibility fit staged rollout
- CI failure is actionable rather than flaky noise

### Topic-specific invariants / traps
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
- make gates proportional to risk
- parallelize only isolated deterministic tests
- pin toolchain/dependencies where reproducibility matters
- produce release notes and change/risk inventory from evidence

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- check skipped tests, silent failures, environment drift and secret exposure
- audit signing/profile renewal and dependency/privacy gates
- verify release checklist includes data migration and rollback when needed

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- classify failure as source/toolchain/signing/service/flaky test
- preserve logs/artifacts needed for reproducibility

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- dual-run new CI/release path before cutover
- keep rollback to prior artifact/process for at least one validated release

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
- clean pipeline from checkout to archive/test
- artifact/version/signing inspection
- staged rollout/kill switch exercise for R3 changes
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-17-02 «CI test parallelism» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: sharding, simulator allocation, shared-state isolation, retries only as diagnostics и result merging.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
