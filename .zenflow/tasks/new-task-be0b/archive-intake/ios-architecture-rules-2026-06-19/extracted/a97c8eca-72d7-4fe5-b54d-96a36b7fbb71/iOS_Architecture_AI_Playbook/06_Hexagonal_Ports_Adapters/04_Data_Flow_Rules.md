# 04_Data_Flow_Rules — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Этот документ описывает data flow в Hexagonal Architecture.

---

## 2. Main Read Flow

```text
Driving Adapter
 → UseCase
 → Domain Core
 → Outbound Port
 → Driven Adapter
 → External system
```

Response:

```text
External system
 → Driven Adapter
 → Domain Model
 → UseCase result
 → Driving Adapter
 → ViewState
```

---

## 3. iOS Read Flow

```text
SwiftUI View
 → ViewModel
 → UseCase
 → ArticleFeedPort
 → ArticleFeedAPIAdapter / CacheAdapter / DBAdapter
 → DTO/DBModel
 → Domain Article
 → ViewState
```

---

## 4. Write Flow

```text
User Action
 → ViewModel/Store
 → UseCase
 → Domain validation
 → Outbound Port
 → Adapter
 → API/DB/SDK
 → Result
 → Domain/App Error or Success
 → Presentation state
```

---

## 5. Local JSON Adapter Flow

```text
Local JSON
 → LocalJSONAdapter
 → DTO
 → Domain
 → UseCase
 → Presentation
```

The core does not know whether data came from local JSON or API.

---

## 6. Composite Adapter Flow

For offline/cache:

```text
ArticleFeedPort
 → CompositeAdapter
   → LocalCacheAdapter
   → RemoteAPIAdapter
   → PersistenceAdapter
 → Domain result with freshness
```

---

## 7. Mapping Rules

Adapters own external mapping:

```text
DTO → Domain
DBModel → Domain
SDK model → Domain
Domain → API request DTO
```

Presentation owns:

```text
Domain → ViewState
```

---

## 8. Forbidden Flow

```text
Domain → APIClient
Domain → SwiftData
Domain → Firebase
View → SDK
ViewModel → DTO
Repository/Adapter → ViewState
```

---

## 9. Error Flow

```text
SDK/API/DB error
 → Adapter error
 → Domain/App error
 → Presentation error state
```

---

## 10. Rule

```text
Data crosses the hexagon boundary through ports, not through concrete technology types.
```
