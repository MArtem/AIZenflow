# 11_Review_Checklist — RIBs

## 1. Purpose

Review checklist for RIBs.

---

## 2. Tree Checklist

```text
[ ] RIB has clear parent
[ ] Child RIBs are justified
[ ] Tree is not unnecessarily deep
[ ] Siblings do not communicate directly
```

---

## 3. Router Checklist

```text
[ ] Router owns attach/detach
[ ] Router owns navigation mechanics
[ ] Router has detach path for each attach
[ ] Router contains no business logic
[ ] Router does not call API/DB
```

---

## 4. Interactor Checklist

```text
[ ] Interactor owns business flow
[ ] Interactor calls use cases/repositories
[ ] Interactor communicates upward through Listener
[ ] Interactor does not build child RIBs directly
[ ] Interactor does not import UI unnecessarily
```

---

## 5. Builder Checklist

```text
[ ] Builder wires all components
[ ] Dependencies injected
[ ] Listener passed correctly
[ ] Child builders created where needed
[ ] View does not build RIB graph
```

---

## 6. Component Checklist

```text
[ ] Component scope clear
[ ] No global service locator
[ ] Only required dependencies exposed
[ ] Dependencies flow downward
```

---

## 7. Boundary Checklist

```text
[ ] Listener payload has IDs/domain values
[ ] No DTO/DBModel through RIB boundary
[ ] No sibling internals access
[ ] App-wide stores injected clearly
```

---

## 8. Testing Checklist

```text
[ ] Interactor tests
[ ] Router attach/detach tests
[ ] Listener tests
[ ] Builder smoke test if complex
```

---

## 9. Red Flags

```text
- Router has business if statements
- Component exposes whole app container
- child references sibling
- every screen is RIB without lifecycle need
- detach missing
- Listener with 30 methods
```
