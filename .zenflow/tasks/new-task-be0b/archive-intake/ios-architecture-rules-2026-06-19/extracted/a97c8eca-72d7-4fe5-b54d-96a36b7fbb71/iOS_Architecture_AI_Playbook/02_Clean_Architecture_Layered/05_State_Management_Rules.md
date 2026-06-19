# 05_State_Management_Rules — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ определяет, где живет состояние при Clean Architecture.

Clean Architecture не является state management framework. Она задает границы, а состояние может управляться через MVVM, TCA, VIP, Presenter, Store или SwiftUI Native State.

---

## 2. State Ownership by Layer

### Presentation

Владеет:

```text
- UI state
- ViewState
- loading/error/empty states
- navigation intent
- form input state
- per-card UI state
- selected filters/search/sort
```

### Domain

Владеет:

```text
- business rules
- domain entities
- value objects
- business invariants
```

Domain не должен владеть UI loading state.

### Data

Владеет:

```text
- cache state
- sync state
- persistence state
- data freshness metadata
```

Data не должен владеть ViewState.

---

## 3. ViewState Rule

Presentation state should be explicit:

```swift
struct NewsFeedViewState: Equatable {
    var content: NewsFeedContentState
    var refreshState: RefreshState
    var paginationState: PaginationState
    var offlineBanner: OfflineBannerViewState?
}
```

---

## 4. Domain State

Domain entity example:

```swift
struct Article: Equatable, Identifiable {
    let id: ArticleID
    let title: String
    let publicationStatus: PublicationStatus
}
```

Domain state is business meaningful, not UI meaningful.

Good:

```text
PublicationStatus.draft
PublicationStatus.published
PublicationStatus.archived
```

Bad in Domain:

```text
isCardExpanded
isSkeletonVisible
likeButtonSpinnerVisible
```

---

## 5. Persistent State

Persistent state belongs to Data/Persistence:

```text
- saved articles
- cached feed
- pending sync operations
- last updated timestamp
- offline queue
```

Expose to Domain/Presentation through repository result models.

---

## 6. Data Freshness

Data freshness can cross boundary as domain/data metadata:

```swift
struct DataResult<Value> {
    let value: Value
    let freshness: DataFreshness
}

enum DataFreshness: Equatable {
    case fresh
    case stale(lastUpdated: Date)
    case cached
}
```

Presentation maps it to:

```text
offline banner
stale label
refresh hint
```

---

## 7. App State

App-wide state:

```text
- auth session
- user profile
- settings
- feature flags
- network status
```

should live in app-level stores/services and be injected as dependency.

Do not hide app state inside a feature repository or feature ViewModel.

---

## 8. Per-item State

Per-item UI state belongs to Presentation:

```text
- like button loading
- comments loading
- display mode
- local expansion
```

Persistent per-item state belongs to Data/Domain:

```text
- isLiked from server/cache
- comments count
- saved status
```

---

## 9. Derived State

Domain-derived data can be computed in UseCase if it is business logic.

UI-derived data should be computed in Presentation mapper.

Examples:

```text
Business: article is premium-accessible for current user → Domain/UseCase
UI: "3 min read" text → Presentation mapper
```

---

## 10. Error State

Error mapping:

```text
InfrastructureError
 → DataError
 → DomainError/AppError
 → Presentation ErrorViewState
```

Do not expose raw infrastructure errors to View.

---

## 11. Loading State

Loading belongs to Presentation.

Repository should not know about spinners.

Repository can expose operation progress for long operations, but UI decides how to render it.

---

## 12. Navigation State

Navigation belongs to Presentation/Navigation layer.

Domain should not know about screens.

Data should not know about routes.

---

## 13. State Escalation Rule

State should live at the lowest correct level:

```text
View local state if purely visual.
Presentation state if screen behavior.
Feature/App state if shared.
Domain state if business invariant.
Data state if persistence/cache/sync.
```

---

## 14. Rule

```text
Clean Architecture separates what state means from how state is displayed or persisted.
```
