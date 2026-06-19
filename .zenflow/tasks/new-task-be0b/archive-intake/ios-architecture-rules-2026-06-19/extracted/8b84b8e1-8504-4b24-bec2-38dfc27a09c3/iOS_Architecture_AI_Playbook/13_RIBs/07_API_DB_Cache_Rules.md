# 07_API_DB_Cache_Rules — RIBs

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in RIBs.

---

## 2. Main Rule

```text
Interactor can use domain/data boundaries. Router/Builder/View must not implement API/DB/cache.
```

---

## 3. Dependency Injection

Dependencies should be provided through Component/Dependency protocols.

```text
Parent Component
 → Child Dependency
 → Child Component
 → Interactor
```

---

## 4. Good Interactor Dependency

```swift
final class FeedInteractor {
    private let loadFeedUseCase: LoadFeedUseCase
}
```

---

## 5. Bad Interactor Dependency

```swift
final class FeedInteractor {
    private let apiClient = APIClient.shared
}
```

---

## 6. Repository Boundary

Interactor calls:

```text
UseCase
Repository protocol
Domain service
```

Repository handles:

```text
API
DB
cache
offline
```

---

## 7. DTO/DBModel

DTO/DBModel should not cross:

```text
Listener boundary
Router boundary
View boundary
Parent-child boundary
```

---

## 8. Offline/Stale

UseCase returns:

```text
Domain result + freshness/sync metadata
```

Interactor updates View or child flow.

---

## 9. Rule

```text
RIBs define lifecycle boundaries. Clean/Data architecture defines data-source boundaries.
```
