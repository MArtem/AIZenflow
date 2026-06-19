# 13_Feature_Implementation_Prompt — VIPER

## 1. Purpose

Prompt for implementing VIPER module.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Implement feature using VIPER.

First produce plan:

1. Is VIPER justified?
2. View:
   - UI rendering
   - user input forwarding
3. Presenter:
   - event handling
   - coordination
   - display formatting
   - route intent
4. Interactor:
   - business logic
   - use case/repository calls
5. Entity:
   - domain/value objects
   - no DTO/DBModel
6. Router:
   - navigation
   - route parameters
   - destination building
7. Builder:
   - module assembly
8. Tests:
   - Presenter
   - Interactor
   - Router
   - Builder if needed

Rules:
- no business logic in View
- no UIKit/SwiftUI in Interactor
- no API/DB in Presenter/Router
- no DTO/DBModel in View output
- no protocols without reason
- no VIPER for trivial screen
```
