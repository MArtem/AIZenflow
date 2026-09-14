---
id: OP-IOS-24-12
type: deep-playbook
source_skill: IOS-24-12
title: Home/Matter integration — Operational Deep Playbook
section: 27_SYSTEM_INTEGRATION
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-24-12 — Home/Matter integration

## Mission
authorization, home/accessory topology, commissioning lifecycle, errors and privacy

Этот playbook — operational-версия `27_SYSTEM_INTEGRATION/IOS-24-12_HOMEKIT_MATTER.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- entitlements/capabilities and hardware support
- session/process/scene lifecycle
- peer/system delivery and version-skew semantics
- permissions/user prompts
- security/privacy of external data exchange
- Конкретные call sites/owners/tests, затронутые именно задачей «Home/Matter integration».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- integration survives process/session interruption where platform allows
- incoming external data is validated
- delivery is treated according to actual guarantee, not assumed reliable
- version skew is handled explicitly
- resource/session ownership is bounded

### Topic-specific invariants / traps
- Verify expiry skew, concurrent refresh, logout-vs-refresh ordering, replay idempotency, Keychain lifecycle and 401/403 distinction.
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
- model integration as a state machine
- persist idempotency/deduplication state when delivery can repeat
- keep platform-specific adapter behind narrow domain boundary

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- check lifecycle teardown/restoration and entitlement assumptions
- audit external input validation/security
- test unavailable/unsupported/revoked cases

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture session state transitions and system error codes
- test on real hardware when simulator does not represent transport/sensors

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- support protocol/version overlap between app/device peers
- roll out transport/schema changes compatibly

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
- hardware/device matrix where required
- interruption/reconnect/version-skew tests
- permission/security negative path
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-24-12 «Home/Matter integration» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: authorization, home/accessory topology, commissioning lifecycle, errors and privacy.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
