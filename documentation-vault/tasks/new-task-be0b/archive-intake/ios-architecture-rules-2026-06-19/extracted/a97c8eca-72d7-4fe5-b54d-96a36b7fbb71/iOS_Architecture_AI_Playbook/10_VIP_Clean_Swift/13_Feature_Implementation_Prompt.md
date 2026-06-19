# 13_Feature_Implementation_Prompt — VIP / Clean Swift

## 1. Purpose

Prompt for implementing a VIP/Clean Swift scene.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Implement scene using VIP / Clean Swift.

First produce plan:

1. Is VIP justified?
2. View responsibility:
   - display methods
   - user input forwarding
3. Interactor:
   - business logic
   - workers/use cases
   - response creation
4. Presenter:
   - response to view model formatting
5. Router:
   - routes
   - destination creation
   - data passing
6. Worker:
   - API/DB/cache/use case boundary
7. Models:
   - Request
   - Response
   - ViewModel
8. Tests:
   - Interactor
   - Presenter
   - Router
   - Worker if needed

Rules:
- View no business logic
- Interactor no UI formatting
- Presenter no business/API/navigation
- Router no business/API
- Worker no UI formatting
- no DTO/DBModel in ViewModel
- no full VIP for trivial screen
```
