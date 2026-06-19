# 15_Anti_Patterns — SwiftUI Native State Architecture

## 1. Purpose

Этот документ описывает типовые анти-паттерны SwiftUI Native State.

---

## 2. APIClient in View

Плохо:

```swift
.task {
    articles = try await APIClient.shared.fetchArticles()
}
```

Решение:

```text
.task calls model/ViewModel/Store
data logic behind UseCase/Repository
```

---

## 3. DTO in @State

Плохо:

```swift
@State private var article: ArticleDTO?
```

Решение:

```text
Domain/ViewState in UI
DTO stays in Data layer
```

---

## 4. DBModel in View

Плохо для complex features:

```swift
let article: ArticleDBModel
```

Решение:

```text
DBModel → Domain → ViewState
```

---

## 5. Environment as Service Locator

Плохо:

```swift
@Environment(\.articleRepository) var repository
@Environment(\.paymentService) var payment
@Environment(\.apiClient) var api
```

в случайных components.

Решение:

```text
Inject screen model/store or use assembly.
```

---

## 6. Too Many @State Vars

Симптом:

```swift
@State var isLoading
@State var isRefreshing
@State var isEmpty
@State var error
@State var items
@State var selectedItem
@State var showSheet
@State var showAlert
```

Решение:

```text
ScreenState
Observable model
ViewModel/Store
```

---

## 7. Boolean State Conflicts

Плохо:

```text
isLoading = true
isEmpty = true
hasError = true
```

одновременно.

Решение:

```text
enum state machine
```

---

## 8. Heavy Work in body

Плохо:

```swift
var body: some View {
    ForEach(items.sorted().filter(...)) { item in
        ...
    }
}
```

Решение:

```text
prepare visibleItems outside body
```

---

## 9. Side Effects in body

Плохо:

```swift
var body: some View {
    analytics.track("opened")
    return Text("Hello")
}
```

body must be side-effect free.

---

## 10. Binding Business Logic Leak

Плохо:

```swift
Toggle("Subscribe", isOn: $user.isSubscribed)
```

если это должно вызвать API/payment/business rules.

Решение:

```text
send action
```

---

## 11. Local State for Server Action

Плохо:

```swift
ArticleCardView has @State var isLiked
```

если like должен синхронизироваться с сервером.

Решение:

```text
parent feature state owns isLiked and like loading
card sends action
```

---

## 12. Task.detached in View

Плохо:

```swift
Task.detached {
    await sync()
}
```

Решение:

```text
model/service owns task lifecycle
```

---

## 13. Random .onChange Business Logic

Плохо:

```swift
.onChange(of: query) {
    callAPI($0)
}
```

Решение:

```text
model.searchQueryChanged
debounce/cancel inside model/store
```

---

## 14. Navigation with DTO

Плохо:

```swift
path.append(.details(articleDTO))
```

Решение:

```text
path.append(.details(articleID))
```

---

## 15. ViewModel for Every Tiny View

Плохо:

```text
IconViewModel
TitleViewModel
DividerViewModel
```

Решение:

```text
props/ViewState/callbacks
```

---

## 16. Final Rule

```text
SwiftUI Native State is powerful when ownership is clear.
It becomes dangerous when every state becomes local mutable magic.
```
