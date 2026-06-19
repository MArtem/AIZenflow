# 11_Review_Checklist — VIPER

## 1. Purpose

Review checklist for VIPER modules.

---

## 2. View Checklist

```text
[ ] View renders only
[ ] View forwards user input to Presenter
[ ] No business logic
[ ] No API/DB/cache
[ ] No navigation construction
```

---

## 3. Presenter Checklist

```text
[ ] Coordinates View/Interactor/Router
[ ] Formats presentation output if needed
[ ] Does not call API/DB directly
[ ] Does not contain domain-heavy business logic
[ ] Does not become God Object
```

---

## 4. Interactor Checklist

```text
[ ] Owns business/use case logic
[ ] Calls UseCase/Repository boundary
[ ] No UIKit/SwiftUI dependency
[ ] No UI formatting
```

---

## 5. Entity Checklist

```text
[ ] Entity/domain models are not DTO
[ ] Entity/domain models are not DBModel
[ ] Value objects used where helpful
```

---

## 6. Router Checklist

```text
[ ] Owns navigation mechanics
[ ] Uses Builder/Assembly
[ ] Route payload uses IDs/value objects
[ ] No API/data fetching
[ ] No business rules
```

---

## 7. Builder Checklist

```text
[ ] Wires all VIPER components
[ ] Dependencies injected
[ ] View does not build module graph
[ ] Retain cycles avoided
```

---

## 8. Testing Checklist

```text
[ ] Presenter tests
[ ] Interactor tests
[ ] Router tests
[ ] Builder smoke test if needed
```

---

## 9. Red Flags

```text
- Presenter 1000 lines
- Interactor imports UIKit
- Router calls API
- Entity is DTO
- protocols everywhere with no test value
- VIPER for static screen
```
