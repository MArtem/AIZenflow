# 09_Testing_Strategy — MVVM

## 1. Purpose

Этот документ задает testing strategy для MVVM.

Цель — сделать ViewModel, mapping, UseCase, Repository и navigation intent тестируемыми.

---

## 2. What to Test

В MVVM обязательно тестировать:

```text
- ViewModel state transitions
- ViewModel action handling
- loading/error/empty states
- search/debounce/cancellation behavior
- pagination logic
- optimistic updates
- rollback on failure
- Domain → ViewState mapping
- UseCase behavior
- Repository cache policy
- route intents
```

---

## 3. What Not to Over-test

Не нужно unit-тестировать:

```text
- каждый SwiftUI modifier
- trivial View layout
- plain DTO init
- generated boilerplate
- simple pass-through ViewModel without logic
```

---

## 4. ViewModel Test Shape

Пример:

```swift
@MainActor
final class NewsFeedViewModelTests: XCTestCase {
    func testInitialLoadSuccessShowsCards() async {
        let fetchArticles = FetchArticlesUseCaseMock()
        fetchArticles.result = .success([
            .fixture(id: ArticleID("1"), title: "First")
        ])

        let viewModel = NewsFeedViewModel(fetchArticles: fetchArticles)

        await viewModel.send(.onAppear)

        XCTAssertEqual(viewModel.state.cards.count, 1)
        XCTAssertEqual(viewModel.state.cards.first?.title, "First")
    }
}
```

---

## 5. Loading Test

```swift
func testLoadSetsLoadingState() async {
    let fetchArticles = FetchArticlesUseCaseMock()
    fetchArticles.delay = .milliseconds(100)

    let viewModel = NewsFeedViewModel(fetchArticles: fetchArticles)

    let task = Task { await viewModel.send(.onAppear) }

    XCTAssertEqual(viewModel.state.content, .loading)

    await task.value
}
```

---

## 6. Error Test

```swift
func testLoadFailureShowsErrorState() async {
    let fetchArticles = FetchArticlesUseCaseMock()
    fetchArticles.result = .failure(AppError.networkUnavailable)

    let viewModel = NewsFeedViewModel(fetchArticles: fetchArticles)

    await viewModel.send(.onAppear)

    XCTAssertTrue(viewModel.state.content.isFailed)
}
```

---

## 7. Empty Test

```swift
func testLoadEmptyShowsEmptyState() async {
    let fetchArticles = FetchArticlesUseCaseMock()
    fetchArticles.result = .success([])

    let viewModel = NewsFeedViewModel(fetchArticles: fetchArticles)

    await viewModel.send(.onAppear)

    XCTAssertTrue(viewModel.state.content.isEmpty)
}
```

---

## 8. Optimistic Update Test

```swift
func testLikeOptimisticallyUpdatesCard() async {
    let likeArticle = LikeArticleUseCaseMock()
    likeArticle.result = .success(())

    let viewModel = NewsFeedViewModel.fixture(
        cards: [.fixture(id: ArticleID("1"), isLiked: false)],
        likeArticle: likeArticle
    )

    await viewModel.send(.likeTapped(ArticleID("1")))

    XCTAssertEqual(viewModel.state.card(id: ArticleID("1"))?.isLiked, true)
}
```

---

## 9. Rollback Test

```swift
func testLikeFailureRollsBackOptimisticState() async {
    let likeArticle = LikeArticleUseCaseMock()
    likeArticle.result = .failure(AppError.networkUnavailable)

    let viewModel = NewsFeedViewModel.fixture(
        cards: [.fixture(id: ArticleID("1"), isLiked: false)],
        likeArticle: likeArticle
    )

    await viewModel.send(.likeTapped(ArticleID("1")))

    XCTAssertEqual(viewModel.state.card(id: ArticleID("1"))?.isLiked, false)
    XCTAssertEqual(viewModel.state.card(id: ArticleID("1"))?.likeState.isFailed, true)
}
```

---

## 10. Route Test

```swift
func testArticleTapEmitsDetailsRoute() {
    let viewModel = NewsFeedViewModel.fixture()

    viewModel.send(.articleTapped(ArticleID("1")))

    XCTAssertEqual(viewModel.state.route, .articleDetails(ArticleID("1")))
}
```

---

## 11. Mapper Tests

Test Domain → ViewState separately:

```swift
func testMapsArticleToCardViewState() {
    let article = Article.fixture(
        title: "Architecture",
        publishedAt: fixedDate
    )

    let state = ArticleCardViewStateMapper.map(article)

    XCTAssertEqual(state.title, "Architecture")
    XCTAssertEqual(state.publishedDateText, "19 Jun 2026")
}
```

---

## 12. Repository Tests

Repository tests should not depend on ViewModel.

Тестировать:

```text
- cache first
- network first
- fallback
- stale data
- save remote response to local
- decoding failure
```

---

## 13. Mock Rules

Mocks should be explicit:

```swift
final class FetchArticlesUseCaseMock: FetchArticlesUseCaseProtocol {
    var result: Result<[Article], Error> = .success([])

    func execute() async throws -> [Article] {
        try result.get()
    }
}
```

Не использовать global shared mocks.

---

## 14. Test Data Builders

Использовать fixtures:

```swift
extension ArticleCardViewState {
    static func fixture(
        id: ArticleID = ArticleID("1"),
        isLiked: Bool = false
    ) -> Self {
        .init(
            id: id,
            title: "Title",
            summary: "Summary",
            isLiked: isLiked,
            likeState: .idle
        )
    }
}
```

---

## 15. Rule

```text
A MVVM ViewModel is acceptable only if its important behavior can be tested without rendering SwiftUI.
```
