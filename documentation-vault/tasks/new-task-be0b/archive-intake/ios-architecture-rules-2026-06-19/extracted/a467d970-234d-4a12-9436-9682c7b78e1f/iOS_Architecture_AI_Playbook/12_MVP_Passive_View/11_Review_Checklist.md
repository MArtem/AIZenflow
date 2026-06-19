# 11_Review_Checklist — MVP / Passive View

## 1. Purpose

Review checklist for MVP/Passive View.

---

## 2. View Checklist

```text
[ ] View only displays
[ ] View forwards events
[ ] No business logic
[ ] No API/DB/cache
[ ] No navigation decisions
[ ] No DTO/DBModel rendering
```

---

## 3. Presenter Checklist

```text
[ ] Handles user events
[ ] Calls UseCase/Repository boundary
[ ] Maps Domain/App result to ViewState
[ ] Calls Router/Coordinator for navigation
[ ] Does not become God Object
[ ] Does not know layout internals too deeply
```

---

## 4. View Protocol Checklist

```text
[ ] Small enough
[ ] Not 100 tiny setters unless justified
[ ] Uses ViewState where useful
[ ] Test spy easy to implement
```

---

## 5. Router Checklist

```text
[ ] Router owns navigation mechanics
[ ] Route payload uses IDs/value objects
[ ] No DTO/DBModel in route
[ ] No business logic
```

---

## 6. Data Boundary Checklist

```text
[ ] Presenter does not decode JSON
[ ] Presenter does not query DB
[ ] DTO/DBModel hidden
[ ] Repository/UseCase handles data access
```

---

## 7. Testing Checklist

```text
[ ] Presenter loading test
[ ] Presenter success test
[ ] Presenter failure test
[ ] Empty test
[ ] Navigation test
[ ] Validation test if needed
```

---

## 8. Red Flags

```text
- View protocol has 80 methods
- Presenter calls APIClient.shared
- View still validates business rules
- Presenter builds UIViewController
- MVP for static text
- no Presenter tests
```
