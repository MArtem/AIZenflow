# 15_Anti_Patterns — MVVM

## 1. Purpose

Этот документ описывает типовые ошибки MVVM в iOS/SwiftUI production проектах.

---

## 2. Massive ViewModel

Симптомы:

```text
- 800+ строк
- 10–20 dependencies
- API + DB + formatting + navigation + analytics в одном классе
- слишком много public methods
- трудно тестировать
- любое изменение ломает экран
```

Решение:

```text
- UseCases
- Repository
- ViewStateMapper
- Route/Coordinator
- child state
- reducer-like actions
```

---

## 3. Repository in View

Плохо:

```swift
struct NewsFeedView: View {
    let repository: ArticleRepository

    var body: some View {
        Button("Load") {
            Task {
                try await repository.fetch()
            }
        }
    }
}
```

Почему плохо:

```text
- View знает data layer
- трудно тестировать
- UI связан с источником данных
- нарушен MVVM boundary
```

---

## 4. DTO in View

Плохо:

```swift
struct ArticleCardView: View {
    let dto: ArticleDTO
}
```

Почему плохо:

```text
- API contract протекает в UI
- backend change ломает View
- UI formatting размазывается
- невозможно нормально поддерживать offline/DB mapping
```

---

## 5. DBModel in View

Плохо:

```swift
struct ArticleCardView: View {
    let article: ArticleDBModel
}
```

Почему плохо:

```text
- persistence schema протекает в UI
- SwiftData/CoreData детали влияют на View
- UI становится зависимым от DB
```

---

## 6. ViewModel Calls APIClient.shared

Плохо:

```swift
final class NewsFeedViewModel {
    func load() async {
        let articles = try await APIClient.shared.fetchArticles()
    }
}
```

Решение:

```text
UseCase / Repository через init injection
```

---

## 7. ViewModel Creates Destination View

Плохо:

```swift
func makeDetailsView(id: ArticleID) -> ArticleDetailsView
```

Решение:

```text
ViewModel emits Route
Coordinator creates destination
```

---

## 8. Boolean State Explosion

Плохо:

```swift
var isLoading: Bool
var isRefreshing: Bool
var isError: Bool
var isEmpty: Bool
var showAlert: Bool
var showSheet: Bool
```

Если флаги могут конфликтовать, нужен enum state.

Лучше:

```swift
enum ContentState {
    case loading
    case loaded
    case empty
    case failed
}
```

---

## 9. One isLoading for Everything

Плохо:

```swift
isLoading = true
```

и непонятно, что грузится:

```text
- initial load
- refresh
- pagination
- like button
- comments
```

Решение:

```text
separate loading states
```

---

## 10. ViewModel as Service Locator

Плохо:

```swift
final class AppViewModel {
    let authService: AuthService
    let articleRepository: ArticleRepository
    let paymentService: PaymentService
    let analytics: Analytics
    let settings: Settings
    let database: Database
}
```

ViewModel не должна быть глобальным контейнером зависимостей.

---

## 11. Protocol for Every ViewModel

Плохо:

```swift
protocol NewsFeedViewModelProtocol {
    func load()
    func refresh()
}
```

если:

```text
- нет тестовой подмены
- нет нескольких реализаций
- нет module boundary
```

---

## 12. ViewModel for Every Tiny View

Плохо:

```text
TitleViewModel
SubtitleViewModel
IconViewModel
DividerViewModel
ButtonLabelViewModel
```

Для dumb components достаточно:

```text
ViewState
let props
callbacks
```

---

## 13. Business Logic in View

Плохо:

```swift
Button("Buy") {
    if user.balance > product.price && product.isAvailable {
        viewModel.buy()
    }
}
```

View не должна принимать бизнес-решение.

---

## 14. Heavy Work in body

Плохо:

```swift
var body: some View {
    let grouped = articles.groupedAndSortedByDate()
    ...
}
```

Решение:

```text
prepare ViewState outside body
```

---

## 15. Silent Error Swallowing

Плохо:

```swift
try? await fetchArticles()
```

если ошибка влияет на UX.

---

## 16. No Tests

MVVM без тестов часто превращается просто в перенос кода из View во ViewModel.

Минимум:

```text
- load success
- load failure
- empty
- retry
- important actions
- route intents
```

---

## 17. Architecture Drift

MVVM деградирует постепенно:

```text
Week 1:
ViewModel calls UseCase

Week 4:
ViewModel calls Repository directly

Week 8:
ViewModel calls APIClient

Week 12:
ViewModel parses JSON and creates routes

Week 20:
Massive ViewModel
```

Нужен регулярный review checklist.

---

## 18. Final Rule

```text
MVVM is healthy when ViewModel is an orchestrator of presentation state,
not a replacement for the entire architecture.
```
