# 15_Anti_Patterns — RIBs

## 1. Purpose

Anti-patterns for RIBs.

---

## 2. RIB for Every Screen

Bad:

```text
Tiny static screen becomes Builder/Router/Interactor/Component/View.
```

Fix:

```text
Use simple feature/view unless lifecycle boundary matters.
```

---

## 3. Router with Business Logic

Bad:

```text
Router decides if user can checkout.
```

Fix:

```text
Interactor/UseCase decides. Router attaches/detaches.
```

---

## 4. Component as Service Locator

Bad:

```text
Component exposes everything in app.
```

Fix:

```text
Expose only required dependencies.
```

---

## 5. Child Knows Sibling

Bad:

```text
FeedRIB directly calls ProfileRIB.
```

Fix:

```text
Feed → Parent Listener → Parent routes/communicates.
```

---

## 6. Missing Detach

Bad:

```text
attach child but never detach.
```

Fix:

```text
pair every attach with detach and tests.
```

---

## 7. Listener God Protocol

Bad:

```text
Listener with 30 unrelated methods.
```

Fix:

```text
split flows or outputs.
```

---

## 8. DTO Through Listener

Bad:

```text
listener.didSelect(articleDTO)
```

Fix:

```text
listener.didSelect(articleID)
```

---

## 9. Builder Logic

Bad:

```text
Builder has business decisions.
```

Fix:

```text
Builder wires objects only.
```

---

## 10. Final Rule

```text
RIBs are for lifecycle and dependency boundaries. If those boundaries do not matter, RIBs become ceremony.
```
