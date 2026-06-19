# 09_Testing_Strategy — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Testing strategy for Hexagonal Architecture.

---

## 2. Main Rule

```text
Test the core with fake ports.
Test adapters against fake external systems.
```

---

## 3. Domain/Core Tests

Use fake ports:

```swift
final class ArticleFeedPortFake: ArticleFeedPort {
    var result: Result<ArticleFeed, Error> = .success(.fixture())

    func loadFeed(policy: FeedLoadPolicy) async throws -> ArticleFeed {
        try result.get()
    }
}
```

---

## 4. UseCase Tests

Test without API/DB:

```swift
func testLoadFeedReturnsArticles() async throws {
    let port = ArticleFeedPortFake()
    port.result = .success(.fixture(count: 3))

    let useCase = LoadArticleFeedUseCase(feedPort: port)

    let feed = try await useCase.execute()

    XCTAssertEqual(feed.articles.count, 3)
}
```

---

## 5. Adapter Tests

API adapter tests:

```text
- request path/method
- decoding
- error mapping
- DTO → Domain mapping
```

DB adapter tests:

```text
- save/fetch
- DBModel → Domain mapping
- persistence errors
```

---

## 6. Contract Tests

If API/local JSON contract matters:

```text
- sample JSON decodes
- missing optional fields
- version compatibility
```

---

## 7. Port Contract Tests

For multiple adapters implementing same port, use shared tests if possible:

```text
ArticleAPIAdapter
ArticleLocalJSONAdapter
ArticleMockAdapter
```

should all satisfy the same behavior contract.

---

## 8. Presentation Tests

Presentation tests use fake use cases/ports, not real adapters.

---

## 9. Rule

```text
If testing the domain requires a real SDK, the hexagon boundary is broken.
```
