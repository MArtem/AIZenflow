---
id: OP-IOS-13-06
type: deep-playbook
source_skill: IOS-13-06
title: RTL/bidi — Operational Deep Playbook
section: 13_ACCESSIBILITY_LOCALIZATION
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-13-06 — RTL/bidi

## Mission
leading/trailing semantics, mirrored assets, mixed-direction text и layout tests

Этот playbook — operational-версия `13_ACCESSIBILITY_LOCALIZATION/IOS-13-06_RTL.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- VoiceOver tree/actions/focus
- Dynamic Type and content-size extremes
- RTL/locales/pluralization/date-number-currency formatting
- Reduce Motion/contrast/differentiate-without-color settings
- keyboard/switch control where relevant
- Конкретные call sites/owners/tests, затронутые именно задачей «RTL/bidi».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- all actionable controls have accessible semantics
- layout survives supported text sizes/locales
- meaning is not encoded only by color/animation
- formatted values respect locale/calendar/time zone
- focus order matches logical task flow

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
- use semantic system controls before custom accessibility recreation
- let text wrap/scale and avoid fixed-height assumptions
- use String Catalog/pluralization/FormatStyle as project baseline allows

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find inaccessible gestures/custom controls and clipped text
- check hard-coded strings/date formats and LTR assumptions
- verify announcements/focus after async/presentation changes

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reproduce with target accessibility setting enabled
- inspect Accessibility hierarchy and layout bounds

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- preserve accessibility identifiers/semantics during UI rewrite
- update localization keys without breaking translation workflow

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
- VoiceOver manual/UI audit for changed critical path
- Dynamic Type/RTL/locale snapshot or UI checks
- Reduce Motion/contrast validation if animations/colors changed
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-13-06 «RTL/bidi» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: leading/trailing semantics, mirrored assets, mixed-direction text и layout tests.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
