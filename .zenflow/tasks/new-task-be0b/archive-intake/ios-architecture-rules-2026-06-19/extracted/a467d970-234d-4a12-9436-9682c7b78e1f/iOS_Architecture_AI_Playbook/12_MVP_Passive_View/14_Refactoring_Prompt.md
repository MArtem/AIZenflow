# 14_Refactoring_Prompt — MVP / Passive View

## 1. Purpose

Prompt for refactoring legacy MVC/UIKit code into MVP.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Refactor existing screen toward MVP / Passive View if justified.

Find:
1. ViewController business logic.
2. ViewController API/DB/cache calls.
3. ViewController formatting logic.
4. Navigation mixed with UI.
5. DTO/DBModel in View.
6. Missing testable presentation layer.
7. Too many UI setters risk.
8. Presenter overgrowth risk.

Migration:
Step 1: Identify View events.
Step 2: Create Presenter.
Step 3: Move presentation decisions to Presenter.
Step 4: Create View protocol.
Step 5: Move data/business calls behind UseCase/Repository.
Step 6: Create ViewState.
Step 7: Move navigation to Router/Coordinator.
Step 8: Add Presenter tests.
Step 9: Keep local visual state in View.
Step 10: Remove dead code from ViewController.

Rules:
- no big bang rewrite
- preserve behavior
- one screen at a time
- avoid huge View protocol
- avoid Presenter God Object
```
