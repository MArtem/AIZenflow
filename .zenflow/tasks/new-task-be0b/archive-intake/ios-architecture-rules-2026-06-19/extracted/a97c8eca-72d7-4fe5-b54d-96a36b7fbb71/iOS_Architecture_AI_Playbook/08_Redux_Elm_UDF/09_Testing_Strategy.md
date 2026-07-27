# 09_Testing_Strategy — Redux / Elm / UDF

## 1. Purpose

Testing strategy for UDF.

---

## 2. Main Rule

```text
Test reducers as pure state transition functions.
Test effects with fake dependencies.
```

---

## 3. Reducer Tests

```swift
func testOnAppearSetsLoading() {
    var state = NewsFeedState()

    let effect = newsFeedReducer(state: &state, action: .onAppear)

    XCTAssertEqual(state.content, .loading)
    XCTAssertNotNil(effect)
}
```

---

## 4. Success Test

```swift
func testFeedResponseSuccessLoadsCards() {
    var state = NewsFeedState(content: .loading)

    _ = newsFeedReducer(
        state: &state,
        action: .feedResponse(.success([.fixture()]))
    )

    XCTAssertTrue(state.content.isLoaded)
}
```

---

## 5. Failure Test

Test failure action maps to ErrorState.

---

## 6. Effect Tests

Use fake client:

```text
client.fetchFeed returns fixture/error
run effect
assert dispatched response action
```

---

## 7. Search Cancellation Test

Test:

```text
query A
query B
A cancelled
B result accepted
```

---

## 8. Optimistic Update Test

```text
likeTapped → optimistic liked
likeFailed → rollback
```

---

## 9. Navigation Test

```text
articleTapped → route/details state
routeHandled → nil
```

---

## 10. Rule

```text
A UDF feature is only as reliable as its reducer/effect tests.
```
