# 14_Refactoring_Prompt — VIPER

## 1. Purpose

Prompt for refactoring existing code into VIPER.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Refactor existing screen toward VIPER if justified.

Find:
1. Massive ViewController.
2. Business logic in View.
3. API/DB/cache in View/Presenter.
4. Navigation mixed with business.
5. DTO/DBModel in UI.
6. No testable Presenter/Interactor.
7. Presenter already exists but is God Object.
8. Protocol ceremony without value.

Migration:
Step 1: Identify user events → Presenter methods.
Step 2: Move business logic to Interactor.
Step 3: Move navigation to Router.
Step 4: Create Entity/domain models.
Step 5: Move API/DB/cache behind UseCase/Repository.
Step 6: Create Builder/Assembly.
Step 7: Add Presenter/Interactor tests.
Step 8: Remove unnecessary protocols.
Step 9: Keep behavior unchanged.

Rules:
- no big bang rewrite
- one module at a time
- no VIPER for trivial parts
- preserve UI behavior
```
