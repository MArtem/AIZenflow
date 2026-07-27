# 14_Refactoring_Prompt — RIBs

## 1. Purpose

Prompt for refactoring app flow toward RIBs.

---

## 2. Full Prompt

```text
Ты Staff iOS Architect.

Analyze existing app flow and decide if RIBs are justified.

Find:
1. Chaotic app flow.
2. Parent/child lifecycle bugs.
3. Sibling feature coupling.
4. Random dependency passing.
5. Navigation/business mixed.
6. Global singletons everywhere.
7. No ownership of flows.
8. Existing over-engineered tree.

Migration:
Step 1: Identify business flow tree.
Step 2: Start from Root/major flow RIB.
Step 3: Define parent-child boundaries.
Step 4: Define Listener contracts.
Step 5: Define Components/dependencies.
Step 6: Move attach/detach to Router.
Step 7: Move business flow to Interactor.
Step 8: Add tests for Interactor/Router/Listener.
Step 9: Avoid converting tiny screens first.
Step 10: Remove direct sibling communication.

Rules:
- no big bang rewrite
- migrate major flows first
- preserve behavior
- avoid RIBs if Coordinator is enough
```
