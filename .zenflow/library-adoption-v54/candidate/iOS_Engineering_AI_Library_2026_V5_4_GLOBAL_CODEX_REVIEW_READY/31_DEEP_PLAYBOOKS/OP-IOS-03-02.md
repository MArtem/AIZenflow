---
id: OP-IOS-03-02
type: deep-playbook
source_skill: IOS-03-02
title: Actor isolation design — Operational Deep Playbook
section: 03_CONCURRENCY
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-03-02 — Actor isolation design

## Mission
назначить владельца mutable state, boundaries, reentrancy rules и transfer semantics

Этот playbook — operational-версия `03_CONCURRENCY/IOS-03-02_ACTOR_ISOLATION.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- Swift language mode and Strict Concurrency Checking level
- all mutable state owners and actor annotations
- Task creation sites and cancellation owners
- cross-actor values, closures, delegates and callback bridges
- legacy GCD/OperationQueue synchronization around the same state
- Конкретные call sites/owners/tests, затронутые именно задачей «Actor isolation design».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- every shared mutable state has a single isolation strategy
- UI-bound mutation is main-actor isolated
- task lifetime is bounded by an owner or structured scope
- cancellation propagates and is not reported as a normal failure
- no unchecked sendability without a documented synchronization invariant

### Topic-specific invariants / traps
- Verify stable identity, reuse, cancellation, prefetching, image decoding, diff application and hitch evidence.
- Write pre-await/post-await invariants and assume another actor job may mutate state at every suspension point.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- model isolation before adding async syntax
- prefer structured concurrency over detached/unstructured tasks
- make cross-actor transfer Sendable or redesign ownership
- re-check invariants around every await because actor code is reentrant
- bridge callbacks with checked continuations only when no native async API exists

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- trace mutable state across actor/task boundaries
- find orphan tasks, Task.detached, unchecked Sendable and unsafe captures
- check cancellation, priority inheritance and continuation exactly-once resume
- look for heavy work accidentally isolated to MainActor

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reproduce under strict concurrency diagnostics and TSAN when applicable
- log state transitions/task identifiers without sensitive data
- reduce race to competing accesses and redesign ownership rather than add arbitrary locks

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- enable complete checking/module migration incrementally
- classify diagnostics by root ownership problem to avoid repetitive suppressions
- keep legacy queue boundary explicit until one owner model replaces it

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
- Swift 6/complete-concurrency build for affected modules
- targeted async/cancellation/reentrancy tests
- TSAN or runtime stress test when bug class needs dynamic evidence
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-03-02 «Actor isolation design» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: назначить владельца mutable state, boundaries, reentrancy rules и transfer semantics.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
