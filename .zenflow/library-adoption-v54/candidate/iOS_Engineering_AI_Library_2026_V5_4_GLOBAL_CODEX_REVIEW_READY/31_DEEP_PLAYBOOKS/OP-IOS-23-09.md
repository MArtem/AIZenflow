---
id: OP-IOS-23-09
type: deep-playbook
source_skill: IOS-23-09
title: ML data privacy — Operational Deep Playbook
section: 26_ML_VISION_AR
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-23-09 — ML data privacy

## Mission
минимизировать captured media/features, prefer on-device, redact/store safely и define retention

Этот playbook — operational-версия `26_ML_VISION_AR/IOS-23-09_ML_PRIVACY.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- model/request revision and device capability
- input preprocessing/orientation/color/ROI
- latency/memory/thermal budget
- quality metrics and regression dataset
- camera/sensor/privacy lifecycle
- Конкретные call sites/owners/tests, затронутые именно задачей «ML data privacy».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- quality is measured on representative fixtures
- pre/post-processing is deterministic
- unsupported device/model has a defined fallback
- captured media/features obey retention/privacy policy
- session/model resources are bounded

### Topic-specific invariants / traps
- Define threat boundary and negative tests; never trade away verification/privacy for implementation convenience.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- version models and preprocessing together
- prefer on-device processing when it meets product needs and privacy goals
- schedule inference away from UI/realtime bottlenecks
- make confidence/tolerance semantics explicit

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- check orientation/preprocessing mismatch and silent model revision changes
- audit memory/thermal fan-out and privacy retention
- verify fallback/capability checks

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reproduce on fixed golden fixture and device class
- separate model quality from preprocessing/session bugs
- profile inference pipeline

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- A/B or staged model update with fallback
- retain old model/schema until new quality/latency thresholds are proven

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
- regression dataset metrics
- device performance/thermal check
- privacy/capability negative tests
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-23-09 «ML data privacy» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: минимизировать captured media/features, prefer on-device, redact/store safely и define retention.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
