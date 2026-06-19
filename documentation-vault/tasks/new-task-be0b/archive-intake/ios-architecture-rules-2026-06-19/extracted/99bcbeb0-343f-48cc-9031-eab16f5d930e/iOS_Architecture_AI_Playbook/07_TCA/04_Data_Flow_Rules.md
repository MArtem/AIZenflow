# 04_Data_Flow_Rules — TCA

## 1. Purpose

Этот документ описывает data flow в TCA.

---

## 2. Main Flow

```text
View sends Action
 → Store runs Reducer
 → Reducer mutates State
 → Reducer returns Effect
 → Effect uses Dependency
 → Dependency returns result
 → Effect sends result Action
 → Reducer mutates State
 → View updates
```

---

## 3. Load Flow

```text
.onAppear action
 → state.content = .loading
 → return .run effect
 → dependency.fetch()
 → send .feedResponse(result)
 → reducer handles success/failure
```

---

## 4. Search Flow

```text
.searchQueryChanged(query)
 → state.searchQuery = query
 → cancel previous search effect
 → debounce
 → dependency.search(query)
 → .searchResponse(result)
```

---

## 5. Pagination Flow

```text
.loadNextPageIfNeeded(lastVisibleID)
 → reducer checks state.pagination
 → if allowed: state.pagination = .loading
 → effect fetches next page
 → response appends items
```

Reducer must guard against duplicate pagination loads.

---

## 6. Optimistic Update Flow

```text
.likeTapped(id)
 → update state immediately
 → effect calls dependency.like(id)
 → success action confirms
 → failure action rolls back
```

---

## 7. Mapping Rules

Dependencies/Data layer:

```text
DTO → Domain
DBModel → Domain
```

Reducer/Presentation:

```text
Domain → ViewState if needed
```

State should not store raw DTO/DBModel.

---

## 8. Error Flow

```text
Dependency error
 → map to AppError/domain error
 → response action
 → reducer maps to ErrorState/ViewState
```

---

## 9. Navigation Flow

```text
Action says user tapped item
 → reducer sets destination/path state
 → View observes navigation state
 → navigationDestination/sheet renders child store
```

---

## 10. Rule

```text
All feature behavior must flow through Actions and Reducers.
```
