# 05_State_Management_Rules — Coordinator / Flow Architecture

## 1. Purpose

Этот документ описывает состояние в Coordinator / Flow Architecture.

---

## 2. Main Rule

```text
Coordinator owns navigation state and flow lifecycle.
It does not own screen UI state or business state.
```

---

## 3. Coordinator-owned State

Coordinator может владеть:

```text
- current route/path
- active child coordinator
- active modal flow
- selected tab
- flow completion callback
- pending deep link route
```

---

## 4. Coordinator Must Not Own

Coordinator не должен владеть:

```text
- screen loading state
- API response
- DTO
- DBModel
- form state
- business validation state
- cache/sync state
```

---

## 5. SwiftUI Navigation State

Simple:

```swift
@Observable
final class NewsCoordinator {
    var path: [NewsRoute] = []
    var sheet: NewsSheet?
}
```

---

## 6. UIKit Navigation State

UIKit coordinator may own:

```text
- UINavigationController
- child coordinators
- modal presentation references
```

---

## 7. Child Coordinator State

Parent coordinator should retain child coordinator while flow is active.

```swift
private var childCoordinators: [Coordinator] = []
```

Remove child after finish.

---

## 8. Route State

Route state should be serializable or at least stable where possible.

Use IDs.

Avoid storing:

```text
- closures in route
- view instances in route
- repositories in route
- view models in route
```

---

## 9. One-shot Routes

One-shot routes from ViewModel should be cleared after handling:

```text
route emitted
 → coordinator handles
 → routeHandled action clears it
```

---

## 10. App Flow State

AppCoordinator can own high-level app phase:

```swift
enum AppFlowState {
    case launching
    case unauthenticated
    case onboarding
    case main
}
```

But auth session data should live in SessionStore/Auth domain.

---

## 11. Tab State

Tab selection can be app navigation state:

```swift
enum MainTab {
    case news
    case profile
    case settings
}
```

---

## 12. Rule

```text
Navigation state belongs to Coordinator.
Feature state belongs to feature presentation layer.
Business state belongs to Domain/Data/App stores.
```
