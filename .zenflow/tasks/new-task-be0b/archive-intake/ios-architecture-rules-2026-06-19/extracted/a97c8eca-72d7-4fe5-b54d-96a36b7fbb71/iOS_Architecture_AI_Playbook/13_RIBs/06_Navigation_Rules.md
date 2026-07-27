# 06_Navigation_Rules — RIBs

## 1. Purpose

Этот документ описывает navigation and routing in RIBs.

---

## 2. Main Rule

```text
Router owns attach/detach and navigation mechanics.
Interactor decides when navigation should happen.
```

---

## 3. Router Responsibilities

Router:

```text
- attach child RIB
- detach child RIB
- push/present/dismiss views
- maintain child router references
- integrate view hierarchy
```

---

## 4. Interactor Responsibilities

Interactor decides:

```text
- login needed
- child flow should start
- checkout completed
- profile should open
- flow should finish
```

Then calls Router or Listener.

---

## 5. Child Routing

```swift
func routeToLogin() {
    let login = loginBuilder.build(withListener: interactor)
    attachChild(login)
    viewController.present(login.viewControllable)
}
```

---

## 6. Detach Rule

Every attach path should have a detach path.

```text
attachLogin
detachLogin
```

---

## 7. Navigation Payload

Use:

```text
IDs
Domain value objects
small input models
```

Avoid:

```text
DTO
DBModel
ViewModel
Repository
```

---

## 8. Deep Links

Deep links should enter at Root/App RIB or AppCoordinator, then route down the tree.

---

## 9. SwiftUI

SwiftUI RIBs require a clear hosting strategy.

Do not let SwiftUI View own child RIB lifecycle.

---

## 10. Rule

```text
Interactor decides route intent. Router owns route mechanics and child lifecycle.
```
