---
id: OP-IOS-07-05
type: deep-playbook
source_skill: IOS-07-05
title: State restoration — Operational Deep Playbook
section: 07_NAVIGATION_DEEPLINKS
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-07-05 — State restoration

## Mission
восстанавливать navigation/document/user state безопасно и version-aware

Этот playbook — operational-версия `07_NAVIGATION_DEEPLINKS/IOS-07-05_STATE_RESTORATION.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- route model, navigation stack/coordinator and modal state
- universal link/custom URL/App Intent entry points
- authentication/authorization gates
- state restoration and multi-scene behavior
- analytics and security validation
- Конкретные call sites/owners/tests, затронутые именно задачей «State restoration».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- routes are typed and validated before privileged action
- navigation state has a single owner per scene/flow
- deep link replay after auth is deterministic
- unknown/unsupported route fails safely
- restoration does not deserialize unsafe or stale privileged state

### Topic-specific invariants / traps
- Verify cold/warm launch, authenticated/unauthenticated replay, modal competition, restoration and external-input validation.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- parse external input into validated internal route type
- separate route interpretation from UI presentation
- make auth gating/replay explicit and idempotent

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- find stringly route parsing, force unwraps and authorization bypasses
- check competing presentations and multi-scene ownership
- test cold/warm/background entry variants

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture exact incoming URL/activity/scene state and route transitions
- reduce issue to parser, gate, or presentation ownership

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- support old and new route forms during compatibility window
- add telemetry before removing legacy deep links

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
- parser/unit tests for valid/invalid routes
- UI/integration tests for auth/cold/warm flows
- security negative tests
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-07-05 «State restoration» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: восстанавливать navigation/document/user state безопасно и version-aware.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
