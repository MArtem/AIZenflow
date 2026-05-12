# iOS Architecture Reference (Guidance)

## Purpose
This file registers the attached architecture handbook as a **decision-making reference**.

It is not a mandatory rule checklist for every change.

## Source
- Attached PDF:
  `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow-attachments/d8212ed7-0590-4663-af98-fb9e8502b71b.pdf`

## How to Use
- Use for architectural and boundary decisions.
- Do **not** apply DDD/SOLID/GRASP/GoF mechanically.
- Prefer simpler existing project patterns when they already solve the problem.

## When to Consult First
- Runtime ownership confusion (app/package/extension).
- ViewModel growth / responsibility split.
- Repository vs UseCase boundary decisions.
- Offline-first/sync/outbox/error-recovery design.
- Cross-layer refactors with technical debt risk.

## Extracted Guidance (Short)
- Encapsulation and explicit ownership are higher-value than broad inheritance trees.
- Use polymorphism at real variability points, not everywhere.
- Repository boundaries should isolate data access concerns.
- UseCase/Application Service should represent real business flows.
- Keep object responsibilities cohesive and small.
- Pattern choice must be justified by current complexity, not by fashion.

## Anti-Overengineering Guard
Before adding an abstraction, ask:
1. What exact failure mode does it prevent now?
2. What upcoming change does it absorb?
3. Is there a simpler project-native solution?
4. Does it improve readability/testability enough to justify cost?
