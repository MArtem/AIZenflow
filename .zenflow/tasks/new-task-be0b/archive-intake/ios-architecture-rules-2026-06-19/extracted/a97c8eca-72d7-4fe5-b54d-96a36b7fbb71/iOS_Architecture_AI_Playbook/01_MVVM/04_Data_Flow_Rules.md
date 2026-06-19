# 04_Data_Flow_Rules — MVVM

## 1. Purpose

Этот документ описывает правила движения данных в MVVM.

Цель — не допустить, чтобы ViewModel стала местом, где смешались API, DB, DTO, mapping, formatting, cache и navigation.

---

## 2. Default Data Flow

Production data flow:

```text
View
 → ViewModel
 → UseCase
 → Repository Protocol
 → Repository Implementation
 → RemoteDataSource / LocalDataSource
 → DTO / DBModel
 → Domain Model
 → ViewState
 → View
```

---

## 3. Local JSON First Flow

Если API еще не готов:

```text
Local JSON File
 → LocalJSONDataSource
 → DTO
 → Repository
 → Domain Model
 → ViewModel
 → ViewState
 → View
```

View и ViewModel не должны знать, что данные пришли из local JSON.

---

## 4. Real API Flow

После появления API:

```text
Remote API
 → RemoteDataSource
 → DTO
 → Repository
 → Domain Model
 → ViewModel
 → ViewState
 → View
```

Если изначально local JSON был реализован правильно, замена источника данных не должна менять View.

---

## 5. DB/Cache Flow

С persistent cache:

```text
Remote API
 → DTO
 → DBModel
 → Local DB
 → Domain Model
 → ViewState
```

или:

```text
Local DB
 → DBModel
 → Domain Model
 → ViewState
```

---

## 6. Mapping Boundaries

### DTO → Domain

Делается в Data layer:

```text
ArticleDTO → Article
```

или:

```text
ArticleDTO → ArticleDBModel → Article
```

### Domain → ViewState

Делается в Presentation layer:

```text
Article → ArticleCardViewState
```

ViewModel может использовать отдельный mapper:

```swift
let cards = articles.map(ArticleCardViewStateMapper.map)
```

---

## 7. Forbidden Mapping

Нельзя:

```text
View maps DTO → UI
ViewModel maps raw JSON → Domain
Repository maps Domain → ViewState
UseCase returns DTO
DBModel is rendered in SwiftUI
```

---

## 8. User Action Flow

Пример Like:

```text
ArticleCardView.onLikeTap
 → NewsFeedViewModel.send(.likeTapped(articleID))
 → ViewModel updates local optimistic state
 → LikeArticleUseCase.execute(articleID)
 → Repository sends remote request
 → success: keep state
 → failure: rollback state and show error
```

---

## 9. Refresh Flow

```text
User pulls to refresh
 → ViewModel.send(.refreshPulled)
 → state.refreshState = .refreshing
 → FetchArticlesUseCase.execute(policy: .networkFirstFallbackToCache)
 → Repository fetches remote
 → Repository updates cache
 → ViewModel receives Domain models
 → ViewModel maps to ViewState
 → state.refreshState = .idle
```

---

## 10. Pagination Flow

```text
Last item appears
 → View sends .loadNextPageIfNeeded(lastVisibleID)
 → ViewModel checks pagination state
 → ViewModel calls FetchNextPageUseCase
 → Repository fetches next page
 → ViewModel appends mapped cards
```

View must not directly decide if next page should load except triggering visibility event.

---

## 11. Search Flow

```text
Search query changed
 → ViewModel receives query
 → debounce/cancel previous task
 → SearchArticlesUseCase.execute(query)
 → Repository searches remote/local
 → ViewModel maps results
 → View renders new ViewState
```

---

## 12. Optimistic Update Flow

```text
Initial state: article liked = false
User taps like
 → immediately set liked = true
 → set likeButtonState = .loading
 → send API
Success:
 → likeButtonState = .idle
Failure:
 → liked = false
 → likeButtonState = .failed
 → show inline/toast error
```

---

## 13. Error Mapping Flow

```text
Repository/Data error
 → Domain/App error
 → Presentation error
 → ErrorViewState
 → View
```

Нельзя показывать raw error напрямую:

```swift
error.localizedDescription
```

если это не осознанное debug-only поведение.

---

## 14. ViewState as Output Contract

ViewModel должна отдавать ViewState, который готов к отображению:

```swift
struct NewsFeedViewState: Equatable {
    var title: String
    var searchQuery: String
    var content: ContentState
    var isRefreshEnabled: Bool
}
```

View не должна сама собирать сложный state из domain models.

---

## 15. Rule

```text
The ViewModel coordinates presentation data flow.
It does not own infrastructure data flow.
```
