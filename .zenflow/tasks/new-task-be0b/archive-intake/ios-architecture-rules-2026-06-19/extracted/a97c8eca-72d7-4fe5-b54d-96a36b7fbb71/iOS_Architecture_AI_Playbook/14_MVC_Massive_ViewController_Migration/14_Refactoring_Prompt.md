# 14_Refactoring_Prompt — MVC / Massive ViewController / Migration

## 1. Purpose

Prompt for refactoring Massive ViewController.

---

## 2. Full Prompt

```text
Ты Senior iOS Refactoring Architect.

Refactor this Massive ViewController incrementally.

First analyze and classify responsibilities:

- UI setup/rendering
- user input
- state
- API
- JSON parsing
- DB/cache
- business rules
- formatting
- navigation
- analytics
- validation

Then produce:

1. Current problems.
2. Risk level.
3. Target architecture recommendation:
   - MVVM
   - Clean + MVVM
   - Coordinator
   - VIP/MVP/VIPER
   - TCA/UDF
4. Migration steps.
5. First safe extraction.
6. Files to create/change.
7. Tests to add.
8. What should stay in ViewController.
9. What must not move into a new God Object.

Rules:
- no big bang rewrite
- behavior-preserving
- one responsibility per step
- tests before risky changes
- no Helpers/Managers dumping ground
- no DTO/DBModel in UI after data extraction
```
