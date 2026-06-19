# 08_Error_Loading_Empty_State_Rules — ReactorKit / Reactor-style Architecture

## 1. Purpose

Rules for loading/error/empty state in Reactor-style architecture.

---

## 2. Main Rule

```text
Loading, error, empty and content must be explicit State.
```

---

## 3. Loading Mutations

```swift
enum Mutation {
    case setInitialLoading(Bool)
    case setRefreshLoading(Bool)
    case setPaginationLoading(Bool)
    case setCardLoading(ArticleID, Bool)
}
```

---

## 4. Error Mutations

```swift
case setError(ErrorState?)
case setCardError(ArticleID, ErrorState?)
```

---

## 5. Empty State

Empty should be represented in State:

```text
server empty
search empty
filter empty
offline no cache
```

---

## 6. Refresh

Refresh should not erase existing content.

---

## 7. Pagination

Pagination error should not replace whole content.

---

## 8. One-shot Alerts

Use Pulse/event pattern or explicit state with clearing.

Do not rely on repeated full State emissions accidentally triggering alerts.

---

## 9. Rule

```text
Every visible UI state must be reproducible from Reactor State or explicit event output.
```
