---
id: OP-IOS-27-03
type: deep-playbook
source_skill: IOS-27-03
title: API deprecation — Operational Deep Playbook
section: 30_TEAM_ENGINEERING
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-27-03 — API deprecation

## Mission
staged deprecation annotations/docs/migration aids/usage tracking and removal version

Этот playbook — operational-версия `30_TEAM_ENGINEERING/IOS-27-03_API_DEPRECATION.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- team ownership/review/release topology
- coding/ADR/documentation conventions
- incident/on-call and quality metrics
- dependency/module ownership
- knowledge gaps and bus factor
- Конкретные call sites/owners/tests, затронутые именно задачей «API deprecation».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- process improves correctness/throughput rather than ceremony
- ownership and escalation are explicit
- decisions are discoverable and revisitable
- quality gates are automated where practical
- standards do not mandate architecture without context

### Topic-specific invariants / traps
- Verify schema history, previous-version store fixtures, context/actor isolation, uniqueness/delete rules and rollback/data-loss policy.
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
- encode high-value conventions in repo-local docs/templates/checks
- use ADRs for durable trade-offs
- define review boundaries and incident learning loops

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- detect rules with no measurable benefit or unenforceable manual gates
- check documentation drift and unclear ownership

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- use delivery/incident/review data to find process bottleneck
- separate tool problem from ownership/communication problem

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- roll process/tool changes through pilot team/repo first
- keep reversible path until adoption proves useful

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
- adoption/lead-time/defect signal
- repo docs and automation agree
- ownership escalation tested
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-27-03 «API deprecation» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: staged deprecation annotations/docs/migration aids/usage tracking and removal version.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
