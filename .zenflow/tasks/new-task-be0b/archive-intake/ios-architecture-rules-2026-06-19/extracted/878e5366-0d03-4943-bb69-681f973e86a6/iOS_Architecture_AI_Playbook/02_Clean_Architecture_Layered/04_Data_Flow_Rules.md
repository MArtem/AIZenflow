# 04_Data_Flow_Rules — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ описывает движение данных в Clean Architecture.

---

## 2. Main Rule

```text
Data can move outward to UI only through stable domain/presentation boundaries.
```

---

## 3. Basic Read Flow

```text
View
 → ViewModel/Presenter/Store
 → UseCase
 → Repository Protocol
 → Repository Implementation
 → DataSource
 → API/DB/Cache/Local JSON
```

Response flow:

```text
API/DB/Cache
 → DTO/DBModel
 → Domain Model
 → UseCase result
 → ViewModel
 → ViewState
 → View
```

---

## 4. Basic Write Flow

```text
User Action
 → ViewModel/Store
 → UseCase
 → Repository
 → RemoteDataSource / LocalDataSource
 → API/DB
 → Result
 → Domain/Error
 → ViewState update
```

---

## 5. Local JSON Flow

```text
Local JSON File
 → LocalJSONDataSource
 → DTO
 → Repository
 → Domain Entity
 → UseCase
 → Presentation
```

Local JSON should mimic API DTO contract when possible.

---

## 6. API Flow

```text
HTTPClient
 → RemoteDataSource
 → DTO
 → Repository
 → Domain
```

RemoteDataSource should not return ViewState.

---

## 7. DB Flow

```text
Database
 → DBModel
 → LocalDataSource
 → Repository
 → Domain
```

DBModel must not leave Data layer.

---

## 8. Cache First Flow

```text
UseCase.execute(policy: .cacheFirstThenRefresh)
 → Repository reads local cache
 → returns cached domain result
 → Repository refreshes remote if needed
 → updates local cache
 → returns fresh domain result or emits update
```

Implementation style depends on project:

```text
async result
AsyncSequence
callback
store effect
repository observer
```

---

## 9. Network First Fallback Flow

```text
UseCase.execute(policy: .networkFirstFallbackToCache)
 → Repository tries remote
 → if success: save to cache and return fresh domain data
 → if failure: read local cache
 → if cache exists: return stale/cached data
 → if no cache: return error
```

---

## 10. Mapping Rules

### API DTO → Domain

```text
Data/Mappers
```

### API DTO → DBModel

```text
Data/Mappers
```

### DBModel → Domain

```text
Data/Mappers
```

### Domain → ViewState

```text
Presentation/Mappers
```

---

## 11. Forbidden Flow

```text
API → DTO → View
```

```text
DB → DBModel → SwiftUI View
```

```text
Repository → ViewState
```

```text
UseCase → DTO
```

```text
Domain → APIClient
```

---

## 12. Pagination Flow

```text
View detects near-bottom
 → Presentation sends loadNextPage action
 → UseCase requests next page
 → Repository fetches page
 → Repository updates cache if needed
 → Domain Page result
 → Presentation appends ViewState items
```

Page domain result:

```swift
struct Page<Item> {
    let items: [Item]
    let nextCursor: Cursor?
    let hasMore: Bool
}
```

---

## 13. Search Flow

```text
Search query
 → Presentation debounce/cancel
 → SearchUseCase
 → Repository search remote/local
 → Domain results
 → ViewState
```

Domain should not know about text field focus, but can know search query as input.

---

## 14. Optimistic Update Flow

```text
Presentation applies optimistic UI state
 → UseCase performs business operation
 → Repository syncs remote/local
 → success: confirm
 → failure: rollback or mark pending
```

For offline-first:

```text
optimistic local write
 → pending sync record
 → background sync
```

---

## 15. Rule

```text
Every layer must transform data into the language of the next inner/outer boundary.
```
