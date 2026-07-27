# 09_Testing_Strategy — TCA

## 1. Purpose

Testing strategy for TCA.

---

## 2. Main Rule

```text
Test Action → State → Effect → Action.
```

---

## 3. Use TestStore

TCA features should be tested with TestStore where practical.

Test:

```text
- state mutations
- effect outputs
- dependency calls
- cancellation
- debounce
- navigation state
- child feature actions
```

---

## 4. Load Success Test

```swift
@MainActor
func testLoadSuccess() async {
    let store = TestStore(initialState: NewsFeedFeature.State()) {
        NewsFeedFeature()
    } withDependencies: {
        $0.articleClient.fetchFeed = { _ in
            ArticleFeedResult(articles: [.fixture()], freshness: .fresh)
        }
    }

    await store.send(.onAppear) {
        $0.content = .loading
    }

    await store.receive(.feedResponse(.success(.fixtureWithOneArticle))) {
        $0.content = .loaded([.fixture()])
    }
}
```

---

## 5. Failure Test

Test error response action and state.

---

## 6. Cancellation Test

For search/debounce:

```text
send query A
send query B
assert A cancelled
assert only B result handled
```

---

## 7. Optimistic Update Test

```text
send likeTapped
assert state optimistic
receive failure
assert rollback
```

---

## 8. Navigation Test

```text
send articleTapped
assert destination/path state set
```

---

## 9. Dependency Test

Use controlled:

```text
Clock
UUID
Date
API clients
DB clients
```

---

## 10. Rule

```text
If a TCA feature has effects and no tests, one of TCA's biggest benefits is wasted.
```
