# 09_Testing_Strategy — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ задает testing strategy для Clean Architecture.

---

## 2. Main Rule

```text
Test each boundary independently.
```

---

## 3. Domain Tests

Test:

```text
- use cases
- business rules
- value objects
- domain services
- domain validation
```

Domain tests should not require:

```text
- SwiftUI
- API
- database
- network
```

---

## 4. UseCase Test Example

```swift
func testFetchArticlesSortsByPublicationDate() async throws {
    let repository = ArticleRepositoryMock()
    repository.articles = [
        .fixture(id: "old", publishedAt: oldDate),
        .fixture(id: "new", publishedAt: newDate)
    ]

    let useCase = FetchArticlesUseCase(repository: repository)

    let result = try await useCase.execute()

    XCTAssertEqual(result.map(\.id.rawValue), ["new", "old"])
}
```

---

## 5. Data Mapper Tests

Test:

```text
- DTO → Domain
- DTO → DBModel
- DBModel → Domain
- error mapping
- date parsing
- optional fallback
```

---

## 6. Repository Tests

Repository tests should use fake data sources.

Test:

```text
- cacheOnly
- networkOnly
- cacheFirstThenRefresh
- networkFirstFallbackToCache
- staleWhileRevalidate
- remote success saves local
- remote failure falls back local
- no local + remote failure returns error
```

---

## 7. RemoteDataSource Tests

Test:

```text
- endpoint
- request method
- decoding
- status code mapping
- network error mapping
```

Use mock HTTPClient.

---

## 8. LocalDataSource Tests

Test:

```text
- save
- fetch
- delete
- query/filter
- migration assumptions if needed
```

Use in-memory DB/fake storage where possible.

---

## 9. Presentation Tests

Depending on presentation pattern:

```text
MVVM → ViewModel tests
TCA → reducer tests
VIP → Interactor/Presenter tests
MVP → Presenter tests
```

Test mapping Domain → ViewState.

---

## 10. Integration Tests

Integration tests can cover:

```text
UseCase + Repository + FakeRemote + InMemoryLocal
```

Useful for cache/offline behavior.

---

## 11. Contract Tests

If API contract is unstable:

```text
- DTO decoding tests with sample JSON
- local JSON fixtures
- backward compatibility
- missing optional fields
```

---

## 12. Navigation Tests

Test route decisions in Presentation/Coordinator, not Domain.

---

## 13. Test Data Builders

Use fixtures:

```swift
extension Article {
    static func fixture(
        id: ArticleID = ArticleID("1"),
        title: String = "Title"
    ) -> Article {
        Article(id: id, title: title)
    }
}
```

---

## 14. What Not to Test

Do not over-test:

```text
- trivial DTO storage
- one-line pass-through use case unless boundary matters
- SwiftUI layout internals
- generated boilerplate
```

---

## 15. Rule

```text
If a layer cannot be tested without a more outer layer, the dependency direction is probably wrong.
```
