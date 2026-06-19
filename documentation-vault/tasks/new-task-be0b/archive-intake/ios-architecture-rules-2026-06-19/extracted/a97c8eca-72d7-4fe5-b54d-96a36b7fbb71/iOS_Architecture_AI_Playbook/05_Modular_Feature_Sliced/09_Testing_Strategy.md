# 09_Testing_Strategy — Modular / Feature-Sliced Architecture

## 1. Purpose

Testing strategy for modular/feature-sliced iOS project.

---

## 2. Main Rule

```text
Test modules through their public contracts and important internal boundaries.
```

---

## 3. Feature Tests

Each feature should test:

```text
- presentation logic
- use cases
- repositories
- mappers
- route/output behavior
```

---

## 4. Shared Module Tests

Shared modules should test:

```text
- reusable formatters
- primitives
- design system snapshots
- networking abstractions
- persistence abstractions
```

---

## 5. Core Tests

Core tests:

```text
- value objects
- app errors
- concurrency utilities
- feature flag logic
```

---

## 6. Infrastructure Tests

Infrastructure tests:

```text
- API client behavior
- database adapter
- keychain adapter
- analytics adapter
```

Use fake servers/in-memory stores where possible.

---

## 7. Module Boundary Tests

Test that public API is enough.

A feature should be creatable through assembly/public builder without importing internals.

---

## 8. Dependency Tests

For SPM/modules, enforce:

```text
- no cyclic dependencies
- no forbidden imports
- feature does not import sibling internals
```

---

## 9. Integration Tests

App-level integration tests can cover:

```text
Auth → Main
News → Profile route
Deep link → Feature
```

---

## 10. Rule

```text
A modular project is testable when modules can be tested without the whole app.
```
