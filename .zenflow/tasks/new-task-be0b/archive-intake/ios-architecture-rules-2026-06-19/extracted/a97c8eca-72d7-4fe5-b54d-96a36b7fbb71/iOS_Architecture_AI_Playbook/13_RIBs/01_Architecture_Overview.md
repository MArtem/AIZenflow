# 01_Architecture_Overview — RIBs

## 1. Purpose

RIBs — это архитектура для построения приложения как дерева независимых business-driven units.

RIB расшифровывается как:

```text
Router
Interactor
Builder
```

На практике рядом часто есть:

```text
Component
View
Presenter / ViewController
Listener
Dependency
```

Главная цель RIBs — управлять большим приложением через строгое дерево parent-child узлов, где каждый RIB имеет свой lifecycle, dependencies и communication boundaries.

---

## 2. Core Idea

Главная идея:

```text
App is a tree of RIBs.
Each RIB owns a business responsibility and can attach/detach child RIBs.
```

Пример дерева:

```text
RootRIB
├── LoggedOutRIB
│   └── LoginRIB
└── LoggedInRIB
    ├── HomeRIB
    │   ├── FeedRIB
    │   └── ArticleDetailsRIB
    ├── ProfileRIB
    └── SettingsRIB
```

---

## 3. Main Components

### Router

Router отвечает за:

```text
- attaching child RIBs
- detaching child RIBs
- navigation mechanics
- lifecycle of child RIBs
- view hierarchy integration
```

Router не должен содержать business logic.

---

### Interactor

Interactor отвечает за:

```text
- business logic
- reacting to user/system events
- communicating with parent via Listener
- deciding when to attach/detach child RIBs
- calling domain/use case/repository boundaries
```

Interactor не должен напрямую строить child modules.

---

### Builder

Builder отвечает за:

```text
- creating RIB graph node
- wiring Router, Interactor, View, Component
- injecting dependencies
- creating child builders
```

---

### Component

Component отвечает за dependency graph внутри RIB.

```text
Parent Dependency
 → Component
 → child dependencies
```

Component не должен стать service locator для всего приложения.

---

### View

View отвечает за UI.

В UIKit:

```text
ViewController
```

В SwiftUI:

```text
View + hosting/container strategy
```

View не должна содержать business logic.

---

### Listener

Listener — protocol, через который child Interactor сообщает parent о событиях.

```text
Child → Parent communication
```

Пример:

```swift
protocol LoginListener: AnyObject {
    func loginDidSucceed(userID: UserID)
}
```

---

## 4. RIB Lifecycle

```text
Parent Interactor decides child is needed
 → Parent Router attaches child RIB
 → Child Interactor becomes active
 → Child handles business/UI flow
 → Child informs parent via Listener
 → Parent Router detaches child RIB
```

---

## 5. What RIBs Solves

RIBs помогает:

```text
- build huge apps with strict boundaries
- model app as business tree
- isolate features and flows
- manage child lifecycle
- control dependency propagation
- avoid hidden sibling communication
- improve testability of business flows
```

---

## 6. What RIBs Does Not Solve

RIBs не решает автоматически:

```text
- DTO/Domain/DB separation
- data/cache/offline architecture
- SwiftUI state ownership
- UI design system
- local component state
```

RIBs нужно комбинировать с:

```text
Clean Architecture
Repository
Hexagonal Ports/Adapters
Modular Architecture
SwiftUI/MVVM/TCA inside view layer if needed
```

---

## 7. RIBs vs Coordinator

Coordinator focuses on navigation flow.

RIBs focuses on:

```text
- business tree
- lifecycle
- dependency graph
- parent-child communication
```

Coordinator может быть легче. RIBs тяжелее, но сильнее для large-scale apps.

---

## 8. Healthy RIBs

Healthy RIBs:

```text
- clear parent-child tree
- Router owns attach/detach
- Interactor owns business decisions
- Builder wires dependencies
- Component scopes dependencies
- child communicates via Listener
- siblings do not know each other
```

---

## 9. Unhealthy RIBs

Unhealthy RIBs:

```text
- Router has business logic
- Component is global service locator
- child knows siblings
- too deep tree for simple app
- every tiny screen is a RIB
- no clear attach/detach lifecycle
- listeners become huge
```

---

## 10. Summary

RIBs is powerful but heavy.

Rule:

```text
Use RIBs when app complexity, lifecycle boundaries and parent-child flow ownership justify the ceremony.
```
