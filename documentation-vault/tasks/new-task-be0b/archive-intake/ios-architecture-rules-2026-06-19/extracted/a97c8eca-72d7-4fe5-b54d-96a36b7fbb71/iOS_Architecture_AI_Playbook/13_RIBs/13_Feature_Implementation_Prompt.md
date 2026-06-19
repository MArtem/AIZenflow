# 13_Feature_Implementation_Prompt — RIBs

## 1. Purpose

Prompt for implementing a RIB.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Implement feature using RIBs.

First produce plan:

1. Is RIBs justified?
2. RIB tree:
   - parent RIB
   - child RIBs
   - attach/detach lifecycle
3. Router:
   - attach child
   - detach child
   - navigation mechanics
4. Interactor:
   - business flow
   - use case calls
   - listener outputs
5. Builder:
   - module graph
   - child builders
6. Component:
   - dependencies
   - scoped services
7. View:
   - rendering
   - event forwarding
8. Boundaries:
   - IDs/domain values only
   - no DTO/DBModel crossing
9. Tests:
   - Interactor
   - Router
   - Listener
   - Builder

Rules:
- no business logic in Router
- no API/DB/cache in Router/Builder/View
- no sibling direct communication
- no global service locator Component
- detach for every attach
- no RIB for tiny UI component
```
