# 10_Code_Generation_Rules_For_AI — Coordinator / Flow Architecture

## 1. Purpose

Rules for AI generating Coordinator / Flow Architecture code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior/Staff iOS Architect
Navigation Architect
Flow Coordinator Reviewer
```

---

## 3. Before Generating

ИИ должен определить:

```text
- simple route or full coordinator
- SwiftUI or UIKit navigation
- flow boundaries
- route models
- child coordinators
- deep link needs
- auth/permission gates
- modal/push/tab requirements
- assembly dependencies
```

---

## 4. Default Assumption

```text
Use Route enum + Coordinator for non-trivial flows. Route carries IDs/value objects. Coordinator handles navigation. Feature owns state/data.
```

---

## 5. Allowed Files

```text
FeatureRoute.swift
FeatureCoordinator.swift
FeatureRouter.swift
AppRoute.swift
AppCoordinator.swift
DeepLinkParser.swift
RouteGuard.swift
FeatureAssembly.swift
CoordinatorTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put API calls in Coordinator
- pass DTO/DBModel in Route
- create ViewModel inside View when Coordinator should use Assembly
- make ViewModel return SwiftUI View
- parse deep links in random View
- create Coordinator for every tiny component
- put business logic in Coordinator
```

---

## 7. Route Rules

Route should be:

```text
- explicit
- Equatable/Hashable where useful
- small
- ID/value-object based
```

---

## 8. Coordinator Rules

Coordinator should:

```text
- handle routes
- call assemblies
- own navigation path/modal state or router
- manage child coordinators
- finish cleanly
```

---

## 9. Router Rules

Router should:

```text
- perform mechanics
- have spy/mock for tests
- not know business rules
```

---

## 10. SwiftUI Generation Rules

Use:

```text
NavigationStack
navigationDestination
sheet(item:)
fullScreenCover(item:)
Observable coordinator/navigation model if needed
```

---

## 11. UIKit Generation Rules

Use:

```text
UINavigationController
present/dismiss
child coordinator retention
weak parent callbacks where needed
```

---

## 12. Self-review

Check:

```text
- no DTO/DBModel in routes
- no API/DB in coordinator
- coordinator not God Object
- views do not construct complex destinations
- child lifecycle handled
- deep links centralized
- tests for route decisions
```
