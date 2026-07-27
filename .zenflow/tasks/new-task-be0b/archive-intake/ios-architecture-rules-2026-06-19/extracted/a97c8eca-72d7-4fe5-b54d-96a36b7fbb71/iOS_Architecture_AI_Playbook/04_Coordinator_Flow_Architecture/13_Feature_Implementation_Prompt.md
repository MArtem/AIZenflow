# 13_Feature_Implementation_Prompt — Coordinator / Flow Architecture

## 1. Purpose

Prompt for implementing a navigation flow with Coordinator.

---

## 2. Full Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно реализовать navigation/flow для iOS feature using Coordinator / Flow Architecture.

Сначала не пиши код. Сначала определи:

1. Navigation complexity:
   - simple NavigationStack
   - route-only
   - feature coordinator
   - app/flow coordinator
   - UIKit coordinator

2. Flow boundaries:
   - start screen
   - destination screens
   - modal screens
   - finish condition
   - child flows

3. Route model:
   - route cases
   - parameters
   - IDs/value objects only
   - no DTO/DBModel/ViewModel

4. Coordinator responsibilities:
   - handle routes
   - create destinations through Assembly
   - manage child coordinators
   - handle finish/result

5. Router responsibilities:
   - push/pop/present/dismiss
   - NavigationStack/path/sheet if SwiftUI
   - UINavigationController if UIKit

6. Deep links/auth:
   - needed or not
   - parser/guard location
   - pending route behavior

7. Testing plan:
   - route tests
   - deep link parser tests
   - auth redirect tests
   - child lifecycle tests

Then generate:
- Route enum
- Coordinator
- Router or navigation model
- Assembly integration
- Feature output callbacks
- Tests

Rules:
- no API/DB/cache in Coordinator
- no DTO/DBModel in Route
- no destination View creation in ViewModel
- no business logic in Coordinator
- child coordinators retained and removed
```
