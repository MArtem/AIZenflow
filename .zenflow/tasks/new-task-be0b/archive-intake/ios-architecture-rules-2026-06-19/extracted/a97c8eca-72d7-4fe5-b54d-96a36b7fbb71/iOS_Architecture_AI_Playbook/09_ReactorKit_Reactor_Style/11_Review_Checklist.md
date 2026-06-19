# 11_Review_Checklist — ReactorKit / Reactor-style Architecture

## 1. Purpose

Review checklist for Reactor-style code.

---

## 2. Action Checklist

```text
[ ] Actions describe user/system events
[ ] No imperative API command names
[ ] No Mutation-like actions
```

---

## 3. Mutation Checklist

```text
[ ] Mutations describe state changes
[ ] Mutations are not raw user events
[ ] Mutations cover loading/error/content
```

---

## 4. State Checklist

```text
[ ] State is UI-facing
[ ] No DTO in State
[ ] No DBModel in State
[ ] No APIClient/Repository object in State
[ ] Loading/error/empty explicit
```

---

## 5. Reactor Checklist

```text
[ ] mutate() handles side effects
[ ] reduce() is pure
[ ] dependencies injected
[ ] no APIClient.shared
[ ] no business logic in transform/binding unnecessarily
```

---

## 6. View Checklist

```text
[ ] View binds actions
[ ] View binds state
[ ] View does not call API/DB
[ ] DisposeBag/lifecycle handled
[ ] Binding code not business-heavy
```

---

## 7. Navigation Checklist

```text
[ ] Navigation intent explicit
[ ] Route payload uses IDs
[ ] No DTO/DBModel in route
[ ] Coordinator/Flow handles mechanics if complex
```

---

## 8. Testing Checklist

```text
[ ] reduce tests
[ ] mutate tests
[ ] async success/failure tests
[ ] search/debounce tests if needed
[ ] optimistic update tests if needed
```

---

## 9. Red Flags

```text
- reduce() calls API
- State contains DTO
- View binding has business logic
- Reactor has 15 services
- Rx chains unreadable
- no tests
```
