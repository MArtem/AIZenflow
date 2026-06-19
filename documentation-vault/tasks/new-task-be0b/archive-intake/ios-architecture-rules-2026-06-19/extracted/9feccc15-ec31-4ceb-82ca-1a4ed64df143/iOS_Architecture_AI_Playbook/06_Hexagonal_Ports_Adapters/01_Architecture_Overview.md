# 01_Architecture_Overview — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Hexagonal Architecture, also known as Ports & Adapters, защищает бизнес-ядро приложения от внешних деталей:

```text
- REST API
- GraphQL
- database
- SwiftData/CoreData
- Firebase
- Keychain
- analytics SDK
- push SDK
- file storage
- third-party services
```

Цель — сделать так, чтобы Domain не зависел от того, откуда пришли данные и каким SDK они были получены.

---

## 2. Core Idea

Главная идея:

```text
Domain defines what it needs.
Adapters define how this need is implemented.
```

Вместо:

```text
Domain → APIClient
```

делаем:

```text
Domain → Port Protocol
Adapter → implements Port Protocol using APIClient
```

---

## 3. Main Terms

### Domain Core

Бизнес-ядро:

```text
- entities
- value objects
- business rules
- use cases
- domain services
```

### Port

Интерфейс, через который Domain общается с внешним миром.

```swift
protocol ArticleRepositoryPort {
    func fetchArticles() async throws -> [Article]
}
```

### Adapter

Реализация port через конкретную технологию.

```swift
final class RemoteArticleRepositoryAdapter: ArticleRepositoryPort {
    private let apiClient: APIClient
}
```

---

## 4. Driving vs Driven Adapters

### Driving Adapters

То, что вызывает приложение:

```text
- SwiftUI View
- ViewModel
- Store
- Controller
- CLI/test harness
```

### Driven Adapters

То, что приложение вызывает:

```text
- API
- DB
- Cache
- Keychain
- Analytics
- Push
- File system
```

---

## 5. iOS Shape

```text
Presentation Adapter
    SwiftUI View / ViewModel / Store
        ↓
Application / UseCase Port
        ↓
Domain Core
        ↓
Output Port
        ↑
Driven Adapter
    API / DB / Cache / SDK
```

---

## 6. Relation to Clean Architecture

Hexagonal Architecture близка к Clean Architecture.

Clean чаще говорит про слои:

```text
Presentation → Domain ← Data
```

Hexagonal чаще говорит про границы:

```text
Core
Ports
Adapters
```

В iOS они хорошо комбинируются:

```text
Domain: Core + Ports
Data/Infrastructure: Adapters
Presentation: Driving Adapter
```

---

## 7. What Hexagonal Solves

Помогает:

```text
- защитить Domain от API/DB/SDK
- заменить API provider
- заменить database
- тестировать Domain без infrastructure
- иметь local JSON adapter вместо real API
- поддержать offline/cache через adapters
- не привязывать бизнес-логику к фреймворкам
```

---

## 8. What Hexagonal Does Not Solve

Hexagonal не решает сам по себе:

```text
- UI state management
- SwiftUI rendering
- navigation flow
- module folder structure
- reducer/action architecture
```

Для этого нужны:

```text
MVVM
TCA/UDF
Coordinator
Modular Architecture
SwiftUI Native State
```

---

## 9. Example

Domain port:

```swift
protocol ArticleFeedPort {
    func loadFeed(policy: FeedLoadPolicy) async throws -> ArticleFeed
}
```

Adapter:

```swift
final class ArticleFeedAPIAdapter: ArticleFeedPort {
    private let remoteDataSource: ArticleRemoteDataSource
    private let localDataSource: ArticleLocalDataSource

    func loadFeed(policy: FeedLoadPolicy) async throws -> ArticleFeed {
        // API/DB/cache implementation hidden here
    }
}
```

UseCase:

```swift
final class LoadArticleFeedUseCase {
    private let feedPort: ArticleFeedPort

    init(feedPort: ArticleFeedPort) {
        self.feedPort = feedPort
    }

    func execute(policy: FeedLoadPolicy) async throws -> ArticleFeed {
        try await feedPort.loadFeed(policy: policy)
    }
}
```

---

## 10. Summary

Hexagonal Architecture здорова, если:

```text
- Domain defines ports
- Adapters implement ports
- Domain does not know SDK/API/DB
- DTO/DBModel do not enter Domain/UI
- tests can replace adapters with fakes
- infrastructure can change without rewriting business logic
```

Нездорова, если:

```text
- protocols are created without boundary
- Domain imports API/DB frameworks
- adapter dictates domain model
- every trivial class has a port
- ports become vague Manager protocols
```
