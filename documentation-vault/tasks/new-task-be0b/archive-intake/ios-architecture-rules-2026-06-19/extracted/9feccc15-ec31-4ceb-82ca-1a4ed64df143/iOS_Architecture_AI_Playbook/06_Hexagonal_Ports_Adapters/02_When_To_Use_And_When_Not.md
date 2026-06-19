# 02_When_To_Use_And_When_Not — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Этот документ объясняет, когда использовать Hexagonal Architecture в iOS-проекте.

---

## 2. Use Hexagonal When

Используй, если есть:

```text
- важная domain/business logic
- API/DB/SDK dependencies
- need to replace infrastructure
- local JSON now, real API later
- offline/cache/sync
- several data sources
- need for testable domain core
- strong boundary between business and technology
```

---

## 3. Strong Fit Scenarios

```text
- payments
- auth/session
- offline feed
- subscriptions
- sync engine
- analytics boundary
- feature flags
- file import/export
- domain-rich enterprise features
```

---

## 4. Use Light Ports When

Для feature средней сложности:

```text
Domain Port
Adapter
UseCase
```

Без чрезмерного количества ports.

---

## 5. Use Full Hexagonal When

Full approach нужен, если:

```text
- несколько adapters для одного port
- fake/local/remote implementations
- нужно тестировать domain без infrastructure
- SDK/provider может меняться
- есть plugin-like integrations
```

---

## 6. Do Not Use Full Hexagonal When

Не нужно, если:

```text
- UI-only компонент
- static screen
- trivial local logic
- no external dependency
- no meaningful domain core
```

---

## 7. Overengineering Signals

```text
- port для каждого маленького helper
- один port с одной implementation без boundary value
- adapter просто вызывает один метод без причины
- 10 файлов ради local toggle
```

---

## 8. Underengineering Signals

```text
- Domain imports Firebase/SwiftData/APIClient
- business rules inside API adapter
- ViewModel talks to SDK directly
- tests require real database/network
- local JSON replacement requires UI rewrite
```

---

## 9. Decision Rule

```text
Use Hexagonal when business logic should survive changes in technology.
```
