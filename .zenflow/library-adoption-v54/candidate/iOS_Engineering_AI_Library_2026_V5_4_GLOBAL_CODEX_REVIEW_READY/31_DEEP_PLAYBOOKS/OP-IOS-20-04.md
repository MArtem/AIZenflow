---
id: OP-IOS-20-04
type: deep-playbook
source_skill: IOS-20-04
title: Core Data→SwiftData assessment — Operational Deep Playbook
section: 20_MIGRATION_LEGACY
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-20-04 — Core Data→SwiftData assessment

## Mission
сначала доказать бизнес-ценность, migration feasibility, store compatibility и feature parity

Этот playbook — operational-версия `20_MIGRATION_LEGACY/IOS-20-04_SWIFTDATA_MIGRATION.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- complete inventory of legacy API/technology usage
- behavioral tests and production metrics baseline
- compatibility with supported OS/app/backend versions
- data/public API migration constraints
- team rollout and rollback capability
- Конкретные call sites/owners/tests, затронутые именно задачей «Core Data→SwiftData assessment».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- migration has an explicit reason and success metric
- old and new paths have defined interoperability window
- behavior/data compatibility is tested
- rollback/containment exists for R3+
- legacy cleanup happens only after success is proven

### Topic-specific invariants / traps
- Verify schema history, previous-version store fixtures, context/actor isolation, uniqueness/delete rules and rollback/data-loss policy.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- stabilize/test before rewriting
- add seam, migrate one vertical slice, compare, expand
- avoid mixing feature changes into migration diff

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find silent semantic changes hidden as modernization
- check fallback/availability/data compatibility
- audit lingering dual-write/dual-state hazards

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- measure legacy pain and classify actual failure modes
- prototype risky framework assumptions in isolated spike

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- follow observe → characterize → seam → slice → compare → expand → remove
- record stop conditions and cleanup criteria

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
- behavior parity tests
- migration/rollback fixtures
- staged rollout metrics
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-20-04 «Core Data→SwiftData assessment» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: сначала доказать бизнес-ценность, migration feasibility, store compatibility и feature parity.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
