---
id: OP-IOS-09-06
type: deep-playbook
source_skill: IOS-09-06
title: Local cache — Operational Deep Playbook
section: 09_PERSISTENCE_DATA
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-09-06 — Local cache

## Mission
TTL/ETag/versioning, stale-while-revalidate, eviction, disk budget и source-of-truth semantics

Этот playbook — operational-версия `09_PERSISTENCE_DATA/IOS-09-06_CACHE_LAYER.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- store technology/schema/version history
- thread/actor/context ownership
- relationships, uniqueness, indexes and fetch shapes
- migration code and production fixture availability
- cache/offline conflict and backup/restore semantics
- Конкретные call sites/owners/tests, затронутые именно задачей «Local cache».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- user data remains readable across supported upgrade path
- transactions preserve domain invariants
- contexts/models never cross unsupported concurrency boundaries
- cache staleness/invalidation semantics are explicit
- destructive fallback is never a silent default

### Topic-specific invariants / traps
- Verify cache key correctness, TTL/validators, invalidation, stale-while-offline behavior and memory/disk budget.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- model stable identifiers and constraints before convenience relationships
- keep persistence DTO/model boundary where it shields domain from schema churn
- design migration before shipping schema mutation
- bound fetches/batches and large blobs to avoid memory spikes

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find cross-context/object misuse and hidden main-thread I/O
- check migration gaps, optionality/default changes and relationship delete rules
- inspect data-loss paths and cache invalidation

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- freeze writes when corruption/data-loss investigation requires evidence
- test against production-like previous-version store
- separate schema, transaction, concurrency and filesystem causes

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- backup/fixture → migrate → validate invariants → rollback/containment
- stage backend/schema contract changes when old app versions coexist

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
- migration tests from supported historical schemas
- transaction/concurrency tests
- data integrity assertions and storage-pressure path where relevant
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-09-06 «Local cache» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: TTL/ETag/versioning, stale-while-revalidate, eviction, disk budget и source-of-truth semantics.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
