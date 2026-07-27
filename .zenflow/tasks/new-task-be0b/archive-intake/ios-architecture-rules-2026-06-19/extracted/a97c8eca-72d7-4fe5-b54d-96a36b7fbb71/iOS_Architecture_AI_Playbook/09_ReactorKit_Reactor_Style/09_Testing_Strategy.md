# 09_Testing_Strategy — ReactorKit / Reactor-style Architecture

## 1. Purpose

Testing strategy for Reactor-style features.

---

## 2. Main Rule

```text
Test Action → Mutation → State behavior.
```

---

## 3. What to Test

```text
- mutate() emits expected mutations
- reduce() transforms state correctly
- loading/success/failure
- search debounce/cancel
- pagination guards
- optimistic update/rollback
- navigation output
```

---

## 4. reduce() Tests

```swift
func testReduceSetLoading() {
    let reactor = NewsFeedReactor(...)
    let state = reactor.reduce(
        state: reactor.initialState,
        mutation: .setLoading(true)
    )

    XCTAssertEqual(state.isLoading, true)
}
```

---

## 5. mutate() Tests

Use fake use cases and Rx test scheduler if needed.

```text
Action.viewDidLoad
 → expected mutations:
   setLoading(true)
   setItems(...)
   setLoading(false)
```

---

## 6. Search Tests

Test debounce/distinct/cancellation with scheduler.

---

## 7. Optimistic Tests

```text
likeTapped
 → setLiked(true)
 → failure
 → setLiked(false)
```

---

## 8. View Binding Tests

Usually avoid unit testing every binding.

Test binding only if important behavior exists there. Prefer moving logic to Reactor.

---

## 9. Rule

```text
If behavior lives in Rx binding instead of Reactor, it becomes harder to test and review.
```
