---
id: OP-IOS-08-05
type: deep-playbook
source_skill: IOS-08-05
title: Upload/download — Operational Deep Playbook
section: 08_NETWORKING
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-08-05 — Upload/download

## Mission
progress, background/resume, temp files, integrity, cancellation и storage pressure

Этот playbook — operational-версия `08_NETWORKING/IOS-08-05_UPLOAD_DOWNLOAD.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- endpoint/request/response types and HTTP semantics
- URLSession configuration, timeouts, cache and connectivity policy
- auth token storage/refresh/replay flow
- retry/backoff/idempotency rules
- metrics/logging/redaction and background transfer needs
- Конкретные call sites/owners/tests, затронутые именно задачей «Upload/download».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- a request is cancellable through the entire stack
- retries cannot duplicate unsafe side effects
- auth refresh is single-flight and logout wins races
- transport errors, HTTP errors and decoding errors remain distinguishable
- sensitive headers/payload never enter logs

### Topic-specific invariants / traps
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
- use typed request/response and native URLSession async APIs by default
- design timeout/retry/cache semantics per endpoint, not globally by convenience
- respect Retry-After and add jitter/budget when retrying
- decode defensively at external boundary and map into domain types

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- check accidental retries of POST/payment/write operations
- look for refresh storms, stale token replay and cancellation loss
- verify URL construction, status handling, content type, decoding and redaction

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture URLSession metrics/request IDs/status/timing without secrets
- separate DNS/connect/TLS/server/decoding/auth failures
- replay with deterministic stub before changing policy

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- preserve endpoint semantics and cancellation when moving callbacks/Combine/libraries to async
- dual-run or contract-test high-risk auth/cache changes

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
- URLProtocol/stub integration tests for success/error/cancel/retry
- auth refresh concurrency tests
- real or representative network check only when necessary
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-08-05 «Upload/download» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: progress, background/resume, temp files, integrity, cancellation и storage pressure.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
