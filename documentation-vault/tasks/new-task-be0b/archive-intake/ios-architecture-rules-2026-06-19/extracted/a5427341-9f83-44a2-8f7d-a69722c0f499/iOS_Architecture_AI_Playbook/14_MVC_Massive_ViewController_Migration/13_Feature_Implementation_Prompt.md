# 13_Feature_Implementation_Prompt — MVC / Massive ViewController / Migration

## 1. Purpose

Prompt for implementing or cleaning a simple MVC screen without letting it become Massive ViewController.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Implement/clean this UIKit/MVC screen carefully.

First decide:
1. Is simple MVC enough?
2. What responsibilities are in ViewController?
3. What must be extracted now?
4. What can stay local UI?
5. What target architecture is needed if it grows?

Rules:
- ViewController may setup UI and forward events.
- ViewController may own simple local UI state.
- ViewController must not decode JSON for production data feature.
- ViewController must not implement cache/offline policy.
- ViewController must not contain business rules.
- ViewController must not build complex navigation graph.
- Use ViewState if loading/error/empty/content exists.
- Use Repository/UseCase when data/business complexity exists.
- Use Coordinator/Router when navigation complexity exists.

Output:
- file structure
- responsibilities
- code
- tests if logic extracted
- future migration notes
```
