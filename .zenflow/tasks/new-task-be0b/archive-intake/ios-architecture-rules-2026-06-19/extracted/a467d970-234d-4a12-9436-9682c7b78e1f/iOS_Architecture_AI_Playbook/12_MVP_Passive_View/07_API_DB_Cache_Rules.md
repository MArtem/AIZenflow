# 07_API_DB_Cache_Rules — MVP / Passive View

## 1. Purpose

Этот документ описывает API/DB/cache boundaries in MVP.

---

## 2. Main Rule

```text
Presenter may call UseCase/Repository boundary, but must not implement API/DB/cache mechanics.
```

---

## 3. Good Dependency

```swift
final class ProfilePresenter {
    private let loadProfileUseCase: LoadProfileUseCase
}
```

---

## 4. Bad Dependency

```swift
final class ProfilePresenter {
    private let apiClient = APIClient.shared
    private let database = Database.shared
}
```

---

## 5. DTO/DBModel Rules

DTO/DBModel should not reach:

```text
View
ViewState
Presenter display output
```

Presenter should receive Domain models or App results.

---

## 6. Cache Policy

Presenter can express user intent:

```text
initial load
refresh
retry
```

Repository/Data layer implements policy.

---

## 7. Offline/Stale

UseCase/Repository returns:

```text
Domain result + freshness
```

Presenter maps to:

```text
offline banner
stale text
retry state
```

---

## 8. Error Mapping

```text
Infrastructure error
 → Repository/AppError
 → Presenter ErrorViewState
 → View
```

---

## 9. Rule

```text
MVP separates presentation from UI, but still needs Clean/Data boundaries for API/DB/cache.
```
