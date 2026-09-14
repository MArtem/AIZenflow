---
id: OP-IOS-21-04
type: deep-playbook
source_skill: IOS-21-04
title: Refactor workflow — Operational Deep Playbook
section: 21_AGENT_WORKFLOWS
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-21-04 — Refactor workflow

## Mission
behavior lock → dependency map → small steps → tests/build after each logical slice

Этот playbook — operational-версия `21_AGENT_WORKFLOWS/IOS-21-04_REFACTOR_WORKFLOW.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- task intent and repository access available to agent
- project-local AGENTS/contributing instructions
- tools agent can actually run
- scope/permissions for edits and destructive actions
- expected final evidence/report format
- Конкретные call sites/owners/tests, затронутые именно задачей «Refactor workflow».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- agent inspects before editing
- agent distinguishes verified from assumed
- agent never expands scope silently
- agent does not weaken safety gates to get green build
- agent ends with diff+verification review

### Topic-specific invariants / traps
- Control clock/random/network/storage and shared global state; avoid fixed sleeps and order-dependent fixtures.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- use repository inspection protocol and risk classification
- make small coherent edits then verify
- surface blocker evidence instead of hallucinating around missing context

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- audit agent plan for skipped discovery/verification
- check claims against command/tool evidence
- flag unnecessary rewrites and unsafe shortcuts

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reconstruct what agent changed and which assumptions were wrong
- compare tool output with final claims

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- introduce agent automation gradually with branch/PR and human review gates for R3+
- encode project conventions in versioned repo instructions

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
- commands/results logged
- changed files match requested scope
- unknowns explicitly listed
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-21-04 «Refactor workflow» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: behavior lock → dependency map → small steps → tests/build after each logical slice.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
