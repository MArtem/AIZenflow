# 14_Refactoring_Prompt — VIP / Clean Swift

## 1. Purpose

Prompt for refactoring existing UIKit/MVC code into VIP/Clean Swift.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Refactor existing screen toward VIP / Clean Swift.

Find:
1. Business logic in ViewController.
2. API/DB/cache in ViewController.
3. Formatting in ViewController.
4. Navigation mixed with business.
5. DTO/DBModel in UI.
6. No testable Interactor/Presenter.
7. Massive Worker/God Service.
8. Overengineering risk.

Migration:
Step 1: Identify user interactions → Requests.
Step 2: Extract business logic to Interactor.
Step 3: Extract formatting to Presenter.
Step 4: Extract navigation to Router.
Step 5: Extract API/DB/cache to Worker/UseCase/Repository.
Step 6: Create Request/Response/ViewModel.
Step 7: Remove DTO/DBModel from UI.
Step 8: Add Interactor/Presenter tests.
Step 9: Keep behavior unchanged.

Rules:
- no big bang rewrite
- migrate one scene at a time
- keep UI behavior
- don't introduce VIP ceremony for trivial parts
```
