# 11_Review_Checklist — Clean Architecture / Layered Architecture

## 1. Purpose

Чеклист для ревью Clean Architecture кода.

---

## 2. Dependency Rule Checklist

```text
[ ] Domain не импортирует SwiftUI
[ ] Domain не импортирует UIKit
[ ] Domain не импортирует DTO
[ ] Domain не импортирует DBModel
[ ] Domain не импортирует APIClient
[ ] Data импортирует Domain, а не наоборот
[ ] Presentation импортирует Domain
[ ] Repository protocol в Domain
[ ] Repository implementation в Data
```

---

## 3. Model Checklist

```text
[ ] DTO отражает API/local JSON
[ ] DBModel отражает persistence
[ ] Domain model отражает business meaning
[ ] ViewState готов для UI
[ ] DTO не используется в UI
[ ] DBModel не используется в UI
[ ] ViewState не используется в Repository
```

---

## 4. UseCase Checklist

```text
[ ] UseCase имеет понятный business/application scenario
[ ] UseCase зависит от repository protocol
[ ] UseCase возвращает Domain result
[ ] UseCase не возвращает DTO
[ ] UseCase не знает ViewState
[ ] UseCase не знает SwiftUI
[ ] UseCase не делает raw API/DB calls
```

---

## 5. Repository Checklist

```text
[ ] Repository implementation скрывает remote/local/cache
[ ] Repository возвращает Domain
[ ] Repository не форматирует UI
[ ] Repository не создает ViewState
[ ] Cache policy explicit
[ ] Offline/stale handling defined
[ ] Errors mapped properly
```

---

## 6. DataSource Checklist

```text
[ ] RemoteDataSource возвращает DTO
[ ] LocalJSONDataSource возвращает DTO or local data contract
[ ] LocalDBDataSource возвращает DBModel
[ ] DataSource не знает ViewState
[ ] DataSource не знает SwiftUI
```

---

## 7. Presentation Checklist

```text
[ ] Presentation maps Domain → ViewState
[ ] Loading/error/empty states explicit
[ ] Navigation intent outside Domain
[ ] View не знает API/DB
[ ] ViewModel/Store не декодирует JSON
```

---

## 8. API/DB/Cache Checklist

```text
[ ] API endpoints hidden in Data/Infrastructure
[ ] DB schema hidden in Data/Infrastructure
[ ] Cache policy not in View
[ ] Cache policy not ad-hoc in ViewModel
[ ] Local JSON mock replaceable with RemoteDataSource
```

---

## 9. Testing Checklist

```text
[ ] UseCase tests
[ ] Mapper tests
[ ] Repository tests
[ ] Error mapping tests
[ ] Presentation state tests
[ ] Cache/offline tests if applicable
```

---

## 10. Overengineering Checklist

```text
[ ] No protocol without boundary/testing/multiple implementations
[ ] No use case explosion
[ ] No unnecessary layer for trivial UI
[ ] No full Clean ceremony for static screen
```

---

## 11. Red Flags

```text
- DTO in SwiftUI View
- DBModel in ViewState
- SwiftUI in Domain
- Repository returns ViewState
- UseCase returns DTO
- ViewModel uses URLSession
- APIClient.shared in Presentation
- Mapper missing between API and UI
```
