---
id: OP-IOS-15-10
type: deep-playbook
source_skill: IOS-15-10
title: AI feature review — Operational Deep Playbook
section: 15_AI_INTELLIGENCE
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-15-10 — AI feature review

## Mission
quality/evals/privacy/security/latency/fallback/accessibility/observability gate

Этот playbook — operational-версия `15_AI_INTELLIGENCE/IOS-15-10_AI_FEATURE_REVIEW.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- model/provider/profile availability and OS/device requirements
- prompt/instruction/tool definitions and context budget
- data sensitivity and on-device/PCC/server routing
- evaluation dataset and expected structured outputs
- tool side effects, authorization and idempotency
- Конкретные call sites/owners/tests, затронутые именно задачей «AI feature review».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- model output is untrusted input until validated
- side-effecting tools enforce app authorization themselves
- prompt/model update cannot silently break critical contract
- sensitive context is minimized and routed according to policy
- fallback exists for unsupported/unavailable model path when product requires it

### Topic-specific invariants / traps
- Define threat boundary and negative tests; never trade away verification/privacy for implementation convenience.
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
- prefer structured/guided generation for machine-consumed output
- keep tool schemas narrow, typed and side-effect safe
- bound context and summarize/chunk intentionally
- separate deterministic business rules from probabilistic generation
- add evaluation cases before prompt optimization

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- look for raw model text driving privileged action or parsing fragile JSON
- check tool authorization, duplicate calls, context leakage and prompt injection surface
- verify availability/fallback and model-update regression testing

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- capture redacted session/tool traces and model/profile version
- classify failure as availability/context/tool/prompt/model/output-validation
- use Foundation Models Instruments where available

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- regression-test prompts when OS/system model changes
- abstract provider only when multi-provider requirement is real
- stage model/profile changes with evaluation thresholds

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
- automated eval dataset and structured-output validation
- tool-call negative/authorization/idempotency tests
- device/profile availability tests
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-15-10 «AI feature review» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: quality/evals/privacy/security/latency/fallback/accessibility/observability gate.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
