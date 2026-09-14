---
id: OP-IOS-11-11
type: deep-playbook
source_skill: IOS-11-11
title: Performance budget — Operational Deep Playbook
section: 11_PERFORMANCE_MEMORY
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-11-11 — Performance budget

## Mission
задать SLO для launch, interaction, scroll, memory, network и regression gate

Этот playbook — operational-версия `11_PERFORMANCE_MEMORY/IOS-11-11_PERF_BUDGET.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- user-visible metric and current baseline
- Instruments/MetricKit/signpost evidence
- main-thread work, allocations and object lifetime
- image/database/network payload sizes
- device/thermal/battery conditions and release build behavior
- Конкретные call sites/owners/tests, затронутые именно задачей «Performance budget».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- optimization targets a measured bottleneck
- before/after workload is comparable
- memory and CPU trade-offs are explicit
- UI responsiveness is not bought by uncontrolled background fan-out
- instrumentation does not leak sensitive data

### Topic-specific invariants / traps
- Verify stable identity, reuse, cancellation, prefetching, image decoding, diff application and hitch evidence.
- Use ownership graph plus runtime deinit/Memory Graph evidence; inspect tasks, timers, notifications, delegates and closures.
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
- add signposts/state labels where attribution is weak
- optimize dominant path first
- move heavy work off UI isolation without creating races
- bound caches/buffers/tasks and define eviction/lifetime

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- reject micro-optimizations without evidence
- find repeated body/layout work, N+1 I/O and accidental decoding on main
- inspect cache retention and image/resource lifetime

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture Time Profiler/Allocations/Leaks/Hangs/Points of Interest as appropriate
- compare representative cold/warm paths
- correlate production MetricKit/state metrics with local reproduction

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- preserve metric baseline while changing rendering/storage/network implementation
- roll out high-risk performance changes behind flag when regression cost is large

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
- before/after measurement with same workload
- memory/deinit evidence for leaks
- production metric follow-up for R3 performance changes
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-11-11 «Performance budget» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: задать SLO для launch, interaction, scroll, memory, network и regression gate.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
