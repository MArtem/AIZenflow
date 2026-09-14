---
id: OP-IOS-22-04
type: deep-playbook
source_skill: IOS-22-04
title: AVPlayer playback — Operational Deep Playbook
section: 25_MEDIA_GRAPHICS
baseline: project-aware / Swift 6 safety target / 2026
---

# OP-IOS-22-04 — AVPlayer playback

## Mission
state/KVO/async observation, buffering, seeking, PiP, interruptions, captions и lifecycle

Этот playbook — operational-версия `25_MEDIA_GRAPHICS/IOS-22-04_VIDEO_PLAYBACK.md`. Используй его, когда задача требует реального изменения/ревью/диагностики/миграции, а не только справочного ответа.

## Обязательные протоколы
- `00_META/V2_EXECUTION_PROTOCOL.md`
- `00_META/REPOSITORY_INSPECTION_PROTOCOL.md`
- `00_META/EVIDENCE_AND_VERIFICATION_POLICY.md`
- `00_META/CHANGE_RISK_MATRIX.md`
- `00_META/QUALITY_STANDARD.md`

## Fact pass: что найти в репозитории
- session/engine/player/render lifecycle
- permissions, interruptions and route/orientation changes
- realtime thread/GPU constraints
- asset formats/color spaces/HDR/orientation
- memory/thermal/background/PiP requirements
- Конкретные call sites/owners/tests, затронутые именно задачей «AVPlayer playback».
- Deployment/availability/toolchain ограничения до предложения нового API.

## Invariants
- realtime callbacks avoid blocking/allocation-heavy work
- session/resources are stopped and released deterministically
- interruptions/device changes restore coherent state
- image/video orientation and color space remain correct
- large buffers/assets are bounded

### Topic-specific invariants / traps
- Verify ownership of the @Observable reference, Observation dependency reads, Binding semantics, MainActor needs and invalidation scope.

## Mode A — IMPLEMENTATION
1. Сформулируй наблюдаемое изменение и risk class.
2. Найди существующий локальный паттерн и объясни, почему его сохраняешь или почему от него нужно отступить.
3. Запиши инварианты до кода.
4. Для R2+ сравни минимум два решения.
5. Реализуй минимальный coherent diff.
6. Добавь tests/diagnostics пропорционально риску.
7. Выполни verification ladder и evidence ledger.

Тематические требования:
- centralize session state machine and interruption handling
- reuse expensive contexts/pipelines when safe
- move non-realtime processing away from realtime callbacks
- validate device/codec/capability availability

## Mode B — REVIEW
Review не является пересказом diff. Ищи конкретный failure mode и подтверждай его surrounding code.

- look for main/realtime thread blocking, buffer retention and session races
- check authorization/interruption/route-change handling
- verify orientation/color/HDR and cleanup

Каждый finding формируй как: `severity → location → violated invariant → failure scenario → minimal fix → regression test`.

## Mode C — DIAGNOSTIC
1. Зафиксируй symptom/environment/version/state.
2. Сформируй 2–5 falsifiable hypotheses.
3. Выбери самый дешёвый evidence, различающий гипотезы.
4. Не меняй архитектуру до подтверждения root cause.
5. После root cause добавь минимальный fix и regression detector.

- use AV/Metal/Instruments captures and lifecycle logs
- reproduce interruptions/background/device changes on hardware when required

## Mode D — MIGRATION
Применяй `00_META/MIGRATION_PROTOCOL.md`.

- preserve media semantics and resource lifetime across API/render-pipeline migration
- stage codec/color pipeline changes with golden assets

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
- device media test matrix
- memory/thermal/performance measurement
- golden output/audio behavior checks
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
Работай как Staff/Principal iOS engineer. Применяй OP-IOS-22-04 «AVPlayer playback» и V2_EXECUTION_PROTOCOL.

Режим: <IMPLEMENTATION|REVIEW|DIAGNOSTIC|MIGRATION>.
Задача: <observable outcome>.
Контекст проекта: <repo/project context>.
Ограничения: <deployment/public API/dependencies/release/data>.

Сначала выполни fact pass по репозиторию и назови source of truth, owner mutable state/resource lifetime, async/actor boundaries и blast radius. Не пиши решение до фиксации инвариантов.

Основной фокус: state/KVO/async observation, buffering, seeking, PiP, interruptions, captions и lifecycle.

Для R2+ сравни два варианта. Сделай минимальный diff, не вводи abstraction или dependency без доказанной пользы. Проверь error/cancellation/availability/security/privacy/performance paths по применимости.

Запусти доступные build/tests/diagnostics. В финале раздели Verified / Reasoned / Unknown и не заявляй о проверке, которой не было.
```
