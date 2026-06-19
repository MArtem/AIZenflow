# 11_Review_Checklist — VIP / Clean Swift

## 1. Purpose

Review checklist for VIP/Clean Swift.

---

## 2. View Checklist

```text
[ ] View displays ViewModel
[ ] View sends Request/user event
[ ] No business logic
[ ] No API/DB/cache
[ ] No DTO/DBModel rendering
```

---

## 3. Interactor Checklist

```text
[ ] Business logic here
[ ] Calls Worker/UseCase
[ ] Does not format UI strings
[ ] Does not import UIKit/SwiftUI unnecessarily
[ ] Produces Response
```

---

## 4. Presenter Checklist

```text
[ ] Formats Response to ViewModel
[ ] Handles date/number/text formatting
[ ] No business decisions
[ ] No API/DB calls
[ ] No navigation mechanics
```

---

## 5. Router Checklist

```text
[ ] Owns navigation
[ ] Uses IDs/value objects
[ ] No DTO/DBModel in route
[ ] No business logic
[ ] No data fetching
```

---

## 6. Worker Checklist

```text
[ ] Handles external operations
[ ] Delegates to Repository/UseCase if appropriate
[ ] Does not format UI
[ ] Does not become God Service
```

---

## 7. Models Checklist

```text
[ ] Request contains input
[ ] Response contains domain result
[ ] ViewModel display-ready
[ ] DTO/DBModel hidden
```

---

## 8. Testing Checklist

```text
[ ] Interactor tests
[ ] Presenter tests
[ ] Router tests
[ ] Worker tests if needed
[ ] Loading/error/empty covered
```

---

## 9. Red Flags

```text
- Presenter validates business rule
- Interactor formats date text
- View calls Worker
- Router calls API
- Worker is 1000-line God Service
- Full VIP for static screen
```
