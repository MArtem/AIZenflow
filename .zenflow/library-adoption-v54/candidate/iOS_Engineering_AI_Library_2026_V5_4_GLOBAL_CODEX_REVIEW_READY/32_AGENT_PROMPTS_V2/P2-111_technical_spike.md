---
id: P2-111
type: prompt-v2
title: Technical spike
mode: DIAGNOSTIC
skills: IOS-01-02, IOS-16-05, IOS-30-02
---

# P2-111 — Technical spike

## Skill chain
- `31_DEEP_PLAYBOOKS/OP-IOS-01-02.md`
- `31_DEEP_PLAYBOOKS/OP-IOS-16-05.md`
- `31_DEEP_PLAYBOOKS/OP-IOS-30-02.md`

## Copy-paste prompt
```text
Ты работаешь как Staff/Principal iOS engineer и coding agent.

Задача: Проверь неизвестный SDK/API узким experiment с explicit hypothesis, success criteria and throwaway scope.
Режим: DIAGNOSTIC.
Контекст проекта: <PROJECT_CONTEXT или доступный repository>.
Конкретная цель: <observable outcome / symptom / diff>.
Ограничения: <deployment target, public API, dependencies, release deadline, data compatibility>.

Обязательно используй:
- 00_META/V2_EXECUTION_PROTOCOL.md
- 00_META/REPOSITORY_INSPECTION_PROTOCOL.md
- 00_META/EVIDENCE_AND_VERIFICATION_POLICY.md
- 00_META/QUALITY_STANDARD.md
и playbooks: OP-IOS-01-02, OP-IOS-16-05, OP-IOS-30-02.

До решения:
1) исследуй repo и найди локальные аналоги/call sites/tests;
2) назови source of truth, owner mutable state/resource lifetime, actor/task boundaries и blast radius;
3) выставь risk R0–R4;
4) запиши инварианты и наиболее опасный negative path.

Во время работы не делай unrelated refactor, не добавляй abstraction/dependency без доказанной пользы и не suppress compiler/security/privacy diagnostics вместо исправления причины. Для R2+ сравни минимум два решения и опиши rollback/containment.

Выполни доступные build/tests/lint/instrumentation. Не утверждай, что проверка прошла, если ты её не запускал.

Финал:
- Mode / Risk
- Facts / Assumptions
- Invariants
- Decision + rejected alternatives
- Changes or Findings with exact files/locations
- Verified evidence (commands/tests/instruments)
- Concurrency / memory / security / privacy / performance / availability impact
- Rollback / containment
- Unknowns / follow-ups
```
