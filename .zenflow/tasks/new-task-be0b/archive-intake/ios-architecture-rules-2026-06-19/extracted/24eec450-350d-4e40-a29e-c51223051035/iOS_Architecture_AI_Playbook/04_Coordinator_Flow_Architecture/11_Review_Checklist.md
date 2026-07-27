# 11_Review_Checklist — Coordinator / Flow Architecture

## 1. Purpose

Review checklist for Coordinator / Flow Architecture.

---

## 2. Route Checklist

```text
[ ] Routes are explicit
[ ] Routes carry IDs/value objects
[ ] No DTO in route
[ ] No DBModel in route
[ ] No View/ViewModel in route
[ ] Routes are Equatable/Hashable where useful
```

---

## 3. Coordinator Checklist

```text
[ ] Coordinator owns flow
[ ] Coordinator uses Assembly for destination
[ ] Coordinator does not call API
[ ] Coordinator does not query DB
[ ] Coordinator does not format UI
[ ] Coordinator does not contain business rules
[ ] Child coordinators retained/released correctly
```

---

## 4. View Checklist

```text
[ ] View does not create complex destination
[ ] View emits user actions
[ ] Simple local NavigationLink only when appropriate
[ ] No deep link parsing in View
```

---

## 5. ViewModel/Store Checklist

```text
[ ] Emits route intent
[ ] Does not create destination View
[ ] Does not access navigation controller
[ ] Clears one-shot route after handling
```

---

## 6. Deep Link Checklist

```text
[ ] Deep links centralized
[ ] Parser separated from View
[ ] Invalid links handled
[ ] Auth/protected links handled
[ ] Route uses IDs not DTO
```

---

## 7. Flow Checklist

```text
[ ] Flow has clear start
[ ] Flow has clear finish
[ ] Parent-child ownership clear
[ ] Modal cancellation handled
[ ] Result returned cleanly if needed
```

---

## 8. Red Flags

```text
- Coordinator named Manager
- Coordinator has APIClient
- Route contains DTO
- ViewModel returns SwiftUI View
- Deep links parsed in random screens
- one AppCoordinator with 1000 lines
- child coordinators never released
```
