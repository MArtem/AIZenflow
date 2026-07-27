# 04_Data_Flow_Rules — RIBs

## 1. Purpose

Этот документ описывает data flow в RIBs.

---

## 2. Main Flow

```text
View
 → Interactor
 → UseCase/Repository/Domain
 → Interactor
 → View
```

Routing flow:

```text
Interactor
 → Router
 → attach/detach child RIB
```

Parent-child flow:

```text
Child Interactor
 → Listener
 → Parent Interactor
```

---

## 3. User Action Flow

```text
View event
 → Interactor method
 → business decision
 → update view or call router/listener
```

---

## 4. Child Attach Flow

```text
Parent Interactor decides child needed
 → Parent Router.attachChild()
 → Child Builder builds child RIB
 → Parent Router attaches child router/view
```

---

## 5. Child Result Flow

```text
Child flow completes
 → Child Interactor calls Listener
 → Parent Interactor receives result
 → Parent Router detaches child
 → Parent continues flow
```

---

## 6. Dependency Flow

```text
Parent Component
 → Child Dependency
 → Child Component
 → Child Interactor/Builder
```

Dependencies flow down. Events flow up.

---

## 7. Data Access Flow

Interactor should call:

```text
UseCase
Repository protocol
Domain service
```

not raw API/DB directly.

---

## 8. DTO/DBModel Rules

DTO/DBModel should not cross RIB boundaries as route/listener payloads.

Use:

```text
IDs
Domain models
small value objects
output structs
```

---

## 9. Sibling Communication

Forbidden:

```text
Child A directly calls Child B
```

Correct:

```text
Child A → Parent Listener → Parent decides → Child B
```

---

## 10. Rule

```text
Dependencies flow downward. Events flow upward. Siblings communicate through parent.
```
