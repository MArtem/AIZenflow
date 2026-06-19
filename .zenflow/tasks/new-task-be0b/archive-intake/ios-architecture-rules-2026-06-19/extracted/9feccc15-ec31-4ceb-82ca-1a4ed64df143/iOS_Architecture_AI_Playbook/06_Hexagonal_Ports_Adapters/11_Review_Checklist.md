# 11_Review_Checklist — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Review checklist for Hexagonal Architecture.

---

## 2. Domain/Core Checklist

```text
[ ] Domain imports no SDK/API/DB/UI framework
[ ] Domain contains business entities/value objects
[ ] Domain defines needed ports
[ ] Domain does not use DTO
[ ] Domain does not use DBModel
[ ] Domain does not use ViewState
```

---

## 3. Port Checklist

```text
[ ] Port represents real boundary
[ ] Port name describes capability
[ ] Port uses Domain types
[ ] Port does not expose SDK types
[ ] Port does not expose DTO/DBModel
[ ] Port is not created just for ceremony
```

---

## 4. Adapter Checklist

```text
[ ] Adapter implements port
[ ] Adapter owns technology details
[ ] Adapter maps external model to Domain
[ ] Adapter maps technology errors
[ ] Adapter does not contain UI logic
[ ] Adapter does not contain unrelated business rules
```

---

## 5. Presentation Checklist

```text
[ ] Presentation calls use cases/inbound ports
[ ] Presentation maps Domain → ViewState
[ ] Presentation owns loading/error/empty
[ ] Presentation handles navigation
```

---

## 6. Testing Checklist

```text
[ ] UseCases test with fake ports
[ ] Adapters test mapping/error behavior
[ ] No real SDK needed for domain tests
[ ] Multiple adapters satisfy same port contract
```

---

## 7. Red Flags

```text
- Domain imports Firebase
- Port returns DTO
- Adapter returns ViewState
- Every class has Protocol
- ManagerProtocol
- Business rules in API adapter
- ViewModel uses SDK directly
```
