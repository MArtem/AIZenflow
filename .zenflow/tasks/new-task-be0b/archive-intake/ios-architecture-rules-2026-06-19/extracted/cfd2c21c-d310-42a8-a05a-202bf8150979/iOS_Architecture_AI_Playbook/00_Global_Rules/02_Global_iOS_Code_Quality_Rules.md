# 02_Global_iOS_Code_Quality_Rules

## 1. Purpose

Этот документ описывает глобальные правила качества iOS-кода.

Он применяется ко всем архитектурам.

Архитектура может отличаться, но базовые правила качества остаются одинаковыми.

---

## 2. Main Rule

```text
Readable, testable, maintainable code is more important than architectural purity.
```

Нельзя делать код “архитектурно красивым”, если он:

```text
- трудно читается
- трудно тестируется
- требует слишком много файлов
- усложняет простые изменения
- создает boilerplate без пользы
- непонятен команде
```

---

## 3. Naming Rules

Имена должны отражать роль объекта.

### Хорошо

```swift
ArticleRepository
ArticleRemoteDataSource
ArticleLocalDataSource
FetchArticlesUseCase
NewsFeedViewModel
NewsFeedViewState
ArticleCardViewState
ArticleDTO
ArticleEntity
ArticleDBModel
ArticleRoute
```

### Плохо

```swift
ArticleManager
ArticleHelper
ArticleServiceManager
DataManager
CommonHelper
Utils
MainModel
ScreenData
```

---

## 4. Forbidden Generic Names

ИИ не должен создавать новые типы с именами:

```text
Manager
Helper
Utils
Common
Base
Generic
Main
Data
ServiceManager
Logic
Handler
Processor
```

Исключение возможно только если название уточнено доменом и роль действительно понятна.

Например:

```swift
ImageProcessingService
AnalyticsEventProcessor
DeepLinkHandler
```

---

## 5. Access Control Rules

По умолчанию:

```swift
struct SomeType {
    private let dependency: Dependency
}
```

Правила:

```text
- private для внутренних деталей
- fileprivate почти никогда
- internal по умолчанию для module-level API
- public только для стабильных module boundaries
- open почти никогда
```

ИИ не должен делать все `public`.

---

## 6. Protocol Rules

Протокол нужен, если есть хотя бы одна причина:

```text
- нужно подменять реализацию в тестах
- есть несколько реализаций
- это module boundary
- это domain port
- это dependency inversion point
- это public contract между feature и infrastructure
```

Протокол не нужен, если:

```text
- есть только один конкретный тип
- тип не тестируется через mock
- нет boundary
- протокол просто дублирует методы класса
```

---

## 7. Dependency Injection Rules

Предпочтительный порядок:

```text
1. Initializer injection
2. Factory / Assembly injection
3. Environment injection for app-wide dependencies
4. Service locator only as last resort
```

Хорошо:

```swift
final class NewsFeedViewModel {
    private let fetchArticles: FetchArticlesUseCase

    init(fetchArticles: FetchArticlesUseCase) {
        self.fetchArticles = fetchArticles
    }
}
```

Плохо:

```swift
final class NewsFeedViewModel {
    private let api = APIClient.shared
    private let db = Database.shared
}
```

---

## 8. Singleton Rules

Singleton допустим только для действительно глобальных infrastructure concerns:

```text
- logger
- analytics transport
- crash reporter
- app configuration provider
```

Но даже singleton должен быть спрятан за abstraction, если используется в бизнес-логике.

Нельзя:

```swift
ArticleRepository(api: APIClient.shared)
```

Лучше:

```swift
ArticleRepository(apiClient: apiClient)
```

---

## 9. Error Handling Rules

Ошибки должны быть типизированы на границах.

Пример:

```swift
enum AppError: Error, Equatable {
    case networkUnavailable
    case unauthorized
    case serverError
    case decodingFailed
    case cacheUnavailable
    case unknown
}
```

Нельзя показывать raw technical error прямо в UI.

Плохо:

```swift
viewState.errorMessage = error.localizedDescription
```

Лучше:

```swift
viewState.error = ErrorViewState(
    title: "Something went wrong",
    message: errorMapper.userMessage(for: error),
    retryAction: .reload
)
```

---

## 10. Logging Rules

Логи не должны содержать:

```text
- токены
- пароли
- персональные данные
- полный body приватных API-запросов
- банковские данные
- приватные user identifiers
```

Логи должны помогать понять:

```text
- какой use case выполнялся
- какой request failed
- какой cache policy сработал
- была ли retry попытка
- был ли fallback на local data
```

---

## 11. Analytics Rules

Analytics не должна протекать во View напрямую.

Плохо:

```swift
Button("Like") {
    Analytics.shared.track("like_tapped")
    viewModel.like()
}
```

Лучше:

```swift
Button("Like") {
    viewModel.send(.likeTapped(articleID))
}
```

А уже внутри feature boundary:

```swift
analytics.track(.articleLikeTapped(articleID))
```

---

## 12. File Size Rules

Ориентиры:

```text
SwiftUI View: ideally < 250 lines
ViewModel/Store/Presenter: ideally < 400 lines
Reducer: split when action/state becomes hard to scan
Repository: split by responsibility when too many methods
Mapper: small and deterministic
```

Это не жесткие лимиты, но сигнал для ревью.

---

## 13. Comment Rules

Комментарии нужны для:

```text
- неочевидных решений
- workaround
- business rule
- architectural exception
- temporary migration note
```

Комментарии не нужны для очевидного:

```swift
// Fetch articles
fetchArticles()
```

Лучше:

```swift
// We intentionally read from local cache first to render stale content
// immediately while remote refresh is running in parallel.
```
