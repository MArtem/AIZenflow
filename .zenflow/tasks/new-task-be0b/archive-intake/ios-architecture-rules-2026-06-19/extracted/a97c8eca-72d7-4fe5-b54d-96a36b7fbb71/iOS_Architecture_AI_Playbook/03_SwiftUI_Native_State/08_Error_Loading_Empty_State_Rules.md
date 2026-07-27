# 08_Error_Loading_Empty_State_Rules — SwiftUI Native State Architecture

## 1. Purpose

Этот документ задает правила loading/error/empty state при нативном SwiftUI state.

---

## 2. Main Rule

```text
Do not model complex screen state as unrelated booleans.
```

---

## 3. Simple Local Loading

For simple UI-only operation:

```swift
@State private var isLoading = false
```

Acceptable if:

```text
- one operation
- no content preservation issue
- no pagination/refresh/per-item loading
```

---

## 4. Complex Loading

Use explicit state:

```swift
enum ContentState<Content> {
    case idle
    case loading
    case loaded(Content)
    case empty
    case failed(ErrorViewState)
}
```

---

## 5. Refresh State

Refresh should not erase content:

```swift
struct ScreenState {
    var content: ContentState<[ItemViewState]>
    var refreshState: RefreshState
}
```

---

## 6. Pagination State

```swift
enum PaginationState {
    case idle
    case loading
    case reachedEnd
    case failed(ErrorViewState)
}
```

---

## 7. Per-item Loading

For server-driven card action:

```text
parent/screen state owns per-item loading
```

Not local card `@State`, unless purely visual.

---

## 8. Error State

For simple local alert:

```swift
@State private var errorMessage: String?
```

For production:

```swift
struct ErrorViewState: Identifiable, Equatable {
    let id: String
    let title: String
    let message: String
    let retryAction: RetryAction?
}
```

---

## 9. Empty State

Empty state should be explicit:

```swift
struct EmptyViewState: Equatable {
    let title: String
    let message: String
    let actionTitle: String?
}
```

---

## 10. No Search Results

Do not treat no search results as generic empty.

```text
content exists? yes
search query filters all? noSearchResults state
```

---

## 11. Offline State

Offline with cache:

```text
show content + banner
```

Offline without cache:

```text
show full-screen error/empty offline state
```

---

## 12. Boolean Explosion

Bad:

```swift
@State var isLoading = false
@State var isEmpty = false
@State var hasError = false
@State var isRefreshing = false
```

Better:

```swift
@State var state: ScreenState
```

---

## 13. Alert/Toast State

One-shot UI events should be modeled carefully:

```swift
@State private var toast: ToastState?
```

or emitted from model and cleared after handling.

---

## 14. Rule

```text
Simple booleans are fine for simple UI.
Explicit state machines are required for complex screens.
```
