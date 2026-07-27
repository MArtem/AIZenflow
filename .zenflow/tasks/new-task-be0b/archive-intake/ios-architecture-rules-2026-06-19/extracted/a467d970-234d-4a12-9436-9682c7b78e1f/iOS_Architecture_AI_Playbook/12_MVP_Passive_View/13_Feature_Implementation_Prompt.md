# 13_Feature_Implementation_Prompt — MVP / Passive View

## 1. Purpose

Prompt for implementing MVP/Passive View feature.

---

## 2. Full Prompt

```text
Ты Senior iOS Architect.

Implement feature using MVP / Passive View.

First produce plan:

1. Is MVP justified?
2. View:
   - display responsibilities
   - event forwarding
   - local visual state
3. View protocol:
   - display methods
   - ViewState shape
4. Presenter:
   - user event handling
   - presentation logic
   - validation if presentation-level
   - UseCase calls
   - mapping to ViewState
5. Model/Domain:
   - entities
   - use cases
   - repositories
6. Router:
   - route methods
   - navigation payload
7. Tests:
   - loading
   - success
   - failure
   - empty
   - navigation
   - validation

Rules:
- View passive
- no API/DB/cache in View or Presenter implementation
- Presenter calls UseCase/Repository boundary
- no DTO/DBModel in View
- small View protocol
- no Presenter for tiny component
```
