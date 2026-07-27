# 08_Error_Loading_Empty_State_Rules — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ объясняет, как Clean Architecture должна моделировать ошибки, загрузку, пустые состояния, offline и stale data.

---

## 2. Main Rule

```text
Infrastructure errors are not UI errors.
Data absence is not always an error.
Offline is not always a failure.
```

---

## 3. Error Layers

```text
InfrastructureError
DataSourceError
RepositoryError
DomainError / AppError
Presentation ErrorViewState
```

---

## 4. Infrastructure Error

Examples:

```text
- HTTP timeout
- invalid status code
- decoding failed
- database write failed
- keychain failed
```

These should not appear directly in UI.

---

## 5. Domain/App Error

Examples:

```swift
enum AppError: Error, Equatable {
    case networkUnavailable
    case unauthorized
    case forbidden
    case notFound
    case validationFailed(String)
    case cacheUnavailable
    case unknown
}
```

---

## 6. Presentation Error

```swift
struct ErrorViewState: Equatable {
    let title: String
    let message: String
    let retryAction: RetryAction?
}
```

Presentation decides wording.

---

## 7. Loading State

Loading belongs to Presentation.

Domain/Repository can expose operation progress only when meaningful:

```swift
enum ImportProgress {
    case started
    case progress(Double)
    case finished
}
```

But spinner state is Presentation.

---

## 8. Empty State

Empty state can come from:

```text
- server returned empty list
- local cache empty
- no search results
- filters exclude all items
- user has not created content
```

UseCase/Repository may return empty data. Presentation maps reason to UI.

---

## 9. Offline State

Offline scenarios:

```text
- cached data exists → show data + offline/stale banner
- no cached data → full-screen offline error
- optimistic update pending → show pending state
- sync failed → show retry/sync warning
```

---

## 10. Stale Data

Repository can return:

```swift
enum DataFreshness: Equatable {
    case fresh
    case stale(lastUpdated: Date)
    case cached(lastUpdated: Date?)
}
```

Presentation maps it to UI.

---

## 11. Refresh Failure

If refresh fails but old data exists:

```text
Do not replace content with full-screen error.
Show inline/banner error.
Keep content.
```

---

## 12. Pagination Failure

Pagination failure should be inline at bottom:

```text
Loaded content remains.
Pagination footer shows retry.
```

---

## 13. Unauthorized

Repository returns unauthorized error.

Presentation decides:

```text
- show login route
- show inline message
- clear session
- ask app coordinator
```

Repository should not open login.

---

## 14. Validation Errors

Validation can exist in Domain:

```swift
enum FormValidationError: Equatable {
    case emptyTitle
    case titleTooLong(max: Int)
}
```

Presentation maps to field messages.

---

## 15. Rule

```text
Clean Architecture separates technical failure, business failure, and user-facing failure.
```
