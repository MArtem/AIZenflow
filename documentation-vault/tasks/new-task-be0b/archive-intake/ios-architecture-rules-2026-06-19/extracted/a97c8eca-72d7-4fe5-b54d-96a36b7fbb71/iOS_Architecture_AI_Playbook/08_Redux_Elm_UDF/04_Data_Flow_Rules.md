# 04_Data_Flow_Rules — Redux / Elm / UDF

## 1. Purpose

Этот документ описывает data flow в Redux/Elm/UDF.

---

## 2. Main Flow

```text
View renders State
 → View dispatches Action
 → Store receives Action
 → Reducer mutates State
 → Reducer returns Effect
 → Effect calls Dependency
 → Effect dispatches result Action
 → Reducer updates State
 → View renders new State
```

---

## 3. Load Flow

```text
onAppear
 → Action.onAppear
 → Reducer sets content = .loading
 → Effect fetches data
 → Action.feedResponse(result)
 → Reducer sets loaded/empty/error
```

---

## 4. Search Flow

```text
searchQueryChanged
 → Reducer updates query
 → Effect debounce/cancel previous
 → search dependency
 → searchResponse
 → Reducer updates results
```

---

## 5. Pagination Flow

```text
loadNextPageIfNeeded(lastID)
 → Reducer checks pagination state
 → if allowed: pagination = .loading
 → Effect fetch next page
 → nextPageResponse
 → Reducer appends
```

---

## 6. Optimistic Flow

```text
likeTapped(id)
 → Reducer immediately changes state
 → Effect calls like API
 → likeResponse success/failure
 → Reducer confirms or rolls back
```

---

## 7. DTO/Data Flow

```text
API/DB
 → DTO/DBModel
 → Domain
 → State/ViewState
```

State should not store DTO/DBModel.

---

## 8. Derived State Flow

Derived state should be:

```text
computed from State
or updated by reducer when inputs change
```

Not computed heavily in View body.

---

## 9. Navigation Flow

```text
user action
 → reducer sets route/path/destination state
 → View/Coordinator observes route
 → navigation executes
```

---

## 10. Rule

```text
Every state change should be explainable by an Action.
```
