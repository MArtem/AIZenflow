---
id: P2-002
type: prompt-v2
title: Implement complex SwiftUI screen
mode: IMPLEMENTATION
skills: IOS-05-02, IOS-05-05, IOS-05-16, IOS-10-02
---

# P2-002 — Implement complex SwiftUI screen

## Skill chain
- `31_DEEP_PLAYBOOKS/OP-IOS-05-02.md`
- `31_DEEP_PLAYBOOKS/OP-IOS-05-05.md`
- `31_DEEP_PLAYBOOKS/OP-IOS-05-16.md`
- `31_DEEP_PLAYBOOKS/OP-IOS-10-02.md`

## Copy-paste prompt
```text
Ты работаешь как Staff/Principal iOS engineer и coding agent.

Задача: Спроектируй экран с единым source of truth, Observation/state ownership, async states, cancellation, navigation и accessibility.
Режим: IMPLEMENTATION.
Контекст проекта: <PROJECT_CONTEXT или доступный repository>.
Конкретная цель: <observable outcome / symptom / diff>.
Ограничения: <deployment target, public API, dependencies, release deadline, data compatibility>.

Обязательно используй:
- 00_META/V2_EXECUTION_PROTOCOL.md
- 00_META/REPOSITORY_INSPECTION_PROTOCOL.md
- 00_META/EVIDENCE_AND_VERIFICATION_POLICY.md
- 00_META/QUALITY_STANDARD.md
и playbooks: OP-IOS-05-02, OP-IOS-05-05, OP-IOS-05-16, OP-IOS-10-02.

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
