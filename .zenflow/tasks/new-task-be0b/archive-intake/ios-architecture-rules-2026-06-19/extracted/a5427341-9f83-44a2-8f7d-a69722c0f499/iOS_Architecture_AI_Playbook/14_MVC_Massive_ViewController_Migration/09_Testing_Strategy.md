# 09_Testing_Strategy — MVC / Massive ViewController / Migration

## 1. Purpose

Testing strategy for legacy MVC migration.

---

## 2. Main Rule

```text
Before refactoring risky legacy code, protect behavior with characterization tests where possible.
```

---

## 3. Characterization Tests

Test current behavior without judging design.

Examples:

```text
- given API success, cells count = N
- given empty response, empty view visible
- given error, error label visible
- tap item opens details
```

---

## 4. Mapper Tests

Extract and test:

```text
DTO → Domain
Domain → ViewState
Error → ErrorViewState
```

---

## 5. UseCase Tests

After extraction:

```text
business validation
sorting/filtering
permissions
domain decisions
```

---

## 6. ViewModel/Presenter Tests

Test:

```text
loading
success
failure
empty
navigation route
pagination
optimistic updates
```

---

## 7. Coordinator Tests

Test route decisions and payloads.

---

## 8. Snapshot/UI Tests

Useful for legacy screens to protect visible behavior.

---

## 9. Avoid

Do not over-test UIKit internals.

Focus on extracted logic.

---

## 10. Rule

```text
Every extracted responsibility should become easier to test than it was inside ViewController.
```
