# 04_Global_Concurrency_Rules

## 1. Purpose

Этот документ задает правила async/await, actors, MainActor, Task lifecycle и cancellation.

---

## 2. Main Rule

```text
UI updates happen on MainActor. Heavy work does not happen on MainActor.
```

---

## 3. MainActor Rules

Можно маркировать `@MainActor`:

```text
- ViewModel, если он управляет UI state
- Observable screen model
- UI-facing Store
- Presenter output adapter
```

Но нельзя бездумно класть всю работу внутрь MainActor.

Плохо:

```swift
@MainActor
final class NewsFeedViewModel {
    func load() async {
        let data = try await api.fetch()
        let mapped = data.map(heavyMapping)
        self.state = .loaded(mapped)
    }
}
```

Лучше:

```swift
@MainActor
final class NewsFeedViewModel {
    func load() async {
        state = .loading

        do {
            let articles = try await fetchArticlesUseCase.execute()
            state = .loaded(articles.map(ArticleCardViewState.init))
        } catch {
            state = .failed(errorMapper.map(error))
        }
    }
}
```

А тяжелый маппинг/DB/API — внутри use case/repository вне MainActor.

---

## 4. Actor Isolation Rule

Правило:

```text
Never bypass actor isolation to make code compile.
```

Нельзя:

```text
- использовать nonisolated без понимания
- делать unsafe shared mutable state
- мутировать общий cache из разных tasks без synchronization
```

---

## 5. Sendable Rules

Правила:

```text
- DTO желательно делать value types
- Domain models желательно делать value types
- UI state желательно делать value types
- mutable reference types не передавать между actors/tasks без причины
- shared mutable cache защищать actor/lock/serial queue
```

---

## 6. Task Lifecycle Rules

Task должен иметь владельца.

Допустимые владельцы:

```text
- SwiftUI .task lifecycle
- ViewModel method
- Store effect
- Interactor operation
- Repository operation
- Background sync service
```

Нельзя создавать detached task без очень веской причины.

Плохо:

```swift
Task.detached {
    await repository.sync()
}
```

Лучше:

```swift
syncTask = Task {
    await repository.sync()
}
```

или через effect system / background service.

---

## 7. Cancellation Rules

Каждая длительная операция должна учитывать cancellation.

Особенно:

```text
- search
- pagination
- image loading
- sync
- background refresh
- long DB read
- import/export
```

Пример:

```swift
func search(query: String) async {
    searchTask?.cancel()

    searchTask = Task {
        do {
            let result = try await searchUseCase.execute(query)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.state = .loaded(result)
            }
        } catch is CancellationError {
            return
        } catch {
            await MainActor.run {
                self.state = .failed(error)
            }
        }
    }
}
```

---

## 8. Search/Debounce Rules

Для search нельзя запускать API на каждый символ без debounce/cancellation.

Правильно:

```text
User typing
 → debounce
 → cancel previous request
 → start new request
 → update state only if request is still relevant
```

---

## 9. DB Loading Rules

Если нужно загрузить много данных, например 100,000 записей:

```text
- не грузить все сразу в UI
- использовать pagination/batching
- использовать fetch descriptors/predicates
- маппить вне MainActor, если маппинг тяжелый
- отдавать UI только видимый/нужный срез
- не создавать 100,000 SwiftUI rows без lazy strategy
```

---

## 10. Async Error Rules

Async operation должна явно маппить ошибку:

```swift
do {
    let articles = try await fetchArticles.execute()
    state = .loaded(articles)
} catch is CancellationError {
    return
} catch {
    state = .failed(errorMapper.map(error))
}
```

Нельзя:

```swift
try? await fetchArticles.execute()
```

если потеря ошибки влияет на UX.
