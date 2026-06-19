# 10_Code_Generation_Rules_For_AI — RIBs

## 1. Purpose

Rules for AI generating RIBs code.

---

## 2. AI Role

ИИ должен быть:

```text
Staff iOS Architect
RIB Tree Designer
Lifecycle Boundary Reviewer
```

---

## 3. Before Generating

ИИ должен определить:

```text
- is RIBs justified?
- parent RIB
- child RIBs
- Router responsibilities
- Interactor responsibilities
- Builder graph
- Component dependencies
- Listener outputs
- attach/detach lifecycle
- tests
```

---

## 4. Default Assumption

```text
Use RIBs only for large/business-flow-driven modules. Do not create RIB for tiny UI component.
```

---

## 5. Allowed Files

```text
FeatureBuilder.swift
FeatureRouter.swift
FeatureInteractor.swift
FeatureComponent.swift
FeatureViewController.swift
FeatureView.swift
FeatureProtocols.swift
FeatureTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put business logic in Router
- put API/DB/cache in Router/Builder/View
- let child know sibling directly
- use Component as global service locator
- pass DTO/DBModel through Listener/Router
- create RIB for every UI state
- forget detach lifecycle
```

---

## 7. Router Rules

Router handles:

```text
attach
detach
navigation mechanics
child router references
```

No business rules.

---

## 8. Interactor Rules

Interactor handles:

```text
business flow
use case calls
listener communication
route decisions as intent
```

---

## 9. Builder Rules

Builder wires graph.

View must not construct RIB graph.

---

## 10. Testing Rules

Generate tests for:

```text
Interactor
Router attach/detach
Listener communication
Builder smoke
```

---

## 11. Self-review

Check:

```text
- parent-child boundaries clear
- dependencies flow down
- events flow up
- no sibling direct communication
- detach exists
- no overengineering
```
