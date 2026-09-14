---
id: OP-IOS-14-01
type: deep-playbook
source_skill: IOS-14-01
title: App Intents — Operational Deep Playbook
section: 14_PLATFORM_SERVICES
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-14-01 — App Intents

## Mission
моделировать discoverable actions/entities, parameters, authorization, background behavior и stable identifiers

Этот playbook — operational-версия `14_PLATFORM_SERVICES/IOS-14-01_APP_INTENTS.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- entitlements/capabilities and OS availability
- permission lifecycle and revocation
- scene/background execution constraints
- system delivery guarantees and quotas
- shared storage/account/state across extensions/devices
- Конкретные call sites/owners/tests, затронутые именно задачей «App Intents».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- permission denial/revocation is normal state
- background callbacks are idempotent and resumable
- system quotas are treated as nondeterministic
- extension/widget/watch state does not assume app process is alive
- entitlements match actual capability use

### Topic-specific invariants / traps
- Verify expiry skew, concurrent refresh, logout-vs-refresh ordering, replay idempotency, Keychain lifecycle and 401/403 distinction.
- Verify stable identity, reuse, cancellation, prefetching, image decoding, diff application and hitch evidence.
- Treat refresh timing as system-controlled; validate timeline/background restoration, shared-container access and process death.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- request permission at user-value moment
- model delivery/retry/restoration explicitly
- persist only minimal state needed to recover after process death

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find assumptions about exact background timing or reachability
- check entitlement/Info.plist/privacy declarations
- verify extension memory/time budgets and cross-process store safety

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture lifecycle/authorization/state transitions
- test process termination/background/interruption paths on device when simulator is insufficient

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- support old/new API availability and data formats during OS transition
- keep shared-container changes backward compatible

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
- device test when hardware/system scheduler matters
- permission denied/revoked tests
- cold launch/background restoration check
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-14-01 «App Intents» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: моделировать discoverable actions/entities, parameters, authorization, background behavior и stable identifiers.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
