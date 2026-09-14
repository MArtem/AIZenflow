---
id: OP-IOS-06-10
type: deep-playbook
source_skill: IOS-06-10
title: UIKit code review — Operational Deep Playbook
section: 06_UIKIT
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-06-10 — UIKit code review

## Mission
lifecycle, containment, main-thread, layout, reuse, memory, accessibility и appearance edge cases

Этот playbook — operational-версия `06_UIKIT/IOS-06-10_UIKIT_REVIEW.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- UIViewController/view lifecycle and containment hierarchy
- delegate/data-source ownership and reuse boundaries
- Auto Layout/self-sizing setup
- tasks/observers/timers/display links and teardown
- SwiftUI hosting bridges if present
- Конкретные call sites/owners/tests, затронутые именно задачей «UIKit code review».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- UI work occurs on main actor/thread
- containment add/remove contract is balanced
- reusable views do not retain stale tasks/state
- constraints are satisfiable across supported sizes/text
- observers/delegates/tasks do not outlive intended owner

### Topic-specific invariants / traps
- Use ownership graph plus runtime deinit/Memory Graph evidence; inspect tasks, timers, notifications, delegates and closures.
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
- place one-time setup, binding, appearance and teardown in correct lifecycle phase
- cancel reuse-bound async work in prepareForReuse or equivalent owner teardown
- prefer diffable/modern registration APIs when project baseline supports them
- keep bridge coordinators ownership-explicit

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- trace retain cycles through delegates/closures/timers/tasks
- check lifecycle duplicate work and stale async updates
- inspect containment/appearance and constraint ambiguity

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- reproduce lifecycle sequence with logs/symbolic breakpoints
- use Memory Graph/Leaks for ownership bugs
- use layout debugging and main-thread profiling for stalls

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- introduce SwiftUI hosting at a stable screen/component seam
- share domain state rather than duplicate UIKit and SwiftUI sources of truth

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
- targeted lifecycle/reuse tests where practical
- UI test/manual matrix for rotations/text sizes/presentation
- memory/deinit evidence for leak fixes
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-06-10 «UIKit code review» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: lifecycle, containment, main-thread, layout, reuse, memory, accessibility и appearance edge cases.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
