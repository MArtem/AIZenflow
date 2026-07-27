# 06_Global_Testing_Rules

## 1. Purpose

Этот документ задает глобальную testing strategy.

---

## 2. Main Rule

```text
Test behavior and boundaries, not implementation details.
```

---

## 3. What Must Be Tested

Обязательно тестировать:

```text
- mappers
- use cases
- reducers
- ViewModels with logic
- presenters
- interactors
- repositories
- cache policy
- error mapping
- pagination logic
- optimistic updates
- retry behavior
- navigation route decisions
```

Не обязательно unit-тестировать:

```text
- каждый простой SwiftUI View
- каждый plain DTO
- каждый trivial init
- каждый private helper
```

---

## 4. Mapper Tests

Мапперы должны быть deterministic.

Пример теста:

```swift
func testMapsArticleDTOToDomain() throws {
    let dto = ArticleDTO(
        id: "123",
        title: "Title",
        summary: nil,
        publishedAt: "2026-06-19T10:00:00Z",
        author: nil
    )

    let article = try ArticleMapper.map(dto)

    XCTAssertEqual(article.id, ArticleID("123"))
    XCTAssertEqual(article.title, "Title")
    XCTAssertEqual(article.summary, "")
}
```

---

## 5. UseCase Tests

UseCase тестируется через mock repository.

```swift
func testFetchArticlesReturnsSortedArticles() async throws {
    let repository = ArticleRepositoryMock()
    repository.articles = [
        .fixture(id: "2", publishedAt: oldDate),
        .fixture(id: "1", publishedAt: newDate)
    ]

    let useCase = FetchArticlesUseCase(repository: repository)

    let result = try await useCase.execute()

    XCTAssertEqual(result.map(\.id), ["1", "2"])
}
```

---

## 6. Repository Tests

Repository tests должны проверять:

```text
- cache first behavior
- network first behavior
- fallback to cache
- saving remote data to DB
- stale data handling
- decoding errors
- server errors
- offline behavior
```

---

## 7. ViewModel / Store Tests

Тестировать:

```text
- initial state
- loading state
- success state
- error state
- retry
- search
- pagination
- cancellation
- optimistic update
- rollback
```

Пример:

```swift
func testLoadSuccessUpdatesState() async {
    let useCase = FetchArticlesUseCaseMock()
    useCase.result = .success([.fixture()])

    let viewModel = NewsFeedViewModel(fetchArticles: useCase)

    await viewModel.load()

    XCTAssertEqual(viewModel.state.isLoaded, true)
}
```

---

## 8. Navigation Tests

Navigation tests нужны, если route logic нетривиальная.

Тестировать:

```text
- tapping card opens detail route
- unauthorized action opens login
- completed onboarding opens main app
- deep link maps to correct route
- invalid deep link maps to fallback
```

---

## 9. Snapshot/UI Tests

Snapshot tests полезны для:

```text
- design system components
- cards
- empty states
- error states
- complex layout states
```

UI tests полезны для:

```text
- critical user flows
- auth
- purchase/subscription
- onboarding
- main navigation
- search flow
```

---

## 10. Test Data Builders

Использовать fixtures/builders:

```swift
extension Article {
    static func fixture(
        id: ArticleID = ArticleID("article-1"),
        title: String = "Test Article",
        summary: String = "Summary",
        publishedAt: Date = Date()
    ) -> Article {
        Article(
            id: id,
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            author: nil
        )
    }
}
```

Нельзя копировать огромные JSON в каждый тест.
