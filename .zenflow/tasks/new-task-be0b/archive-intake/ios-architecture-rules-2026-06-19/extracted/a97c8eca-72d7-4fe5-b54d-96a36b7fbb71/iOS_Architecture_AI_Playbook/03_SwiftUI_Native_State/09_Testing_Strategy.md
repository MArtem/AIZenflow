# 09_Testing_Strategy — SwiftUI Native State Architecture

## 1. Purpose

Этот документ описывает тестирование SwiftUI Native State подхода.

---

## 2. Main Rule

```text
Test state logic outside View body whenever possible.
```

---

## 3. What to Test

Test:

```text
- observable model logic
- state transitions
- route decisions
- validation logic
- derived state generation
- Domain → ViewState mapping
- async load behavior if model owns it
```

---

## 4. What Not to Over-test

Do not over-test:

```text
- simple @State toggle
- SwiftUI body internals
- simple Binding wiring
- default system behavior
```

---

## 5. Observable Model Tests

```swift
@MainActor
func testIncrementUpdatesCount() {
    let model = CounterModel()

    model.increment()

    XCTAssertEqual(model.count, 1)
}
```

---

## 6. State Machine Tests

```swift
func testLoadingSuccessMovesToLoaded() async {
    let model = ScreenModel(service: .success([.fixture()]))

    await model.load()

    XCTAssertTrue(model.state.isLoaded)
}
```

---

## 7. Binding-sensitive Logic

If binding directly mutates business state, refactor to actions and test actions.

---

## 8. Derived State Tests

```swift
func testSearchFiltersItems() {
    let model = ItemsModel(items: [.fixture(title: "Swift")])

    model.searchQuery = "swi"

    XCTAssertEqual(model.visibleItems.count, 1)
}
```

If filtering is heavy, test the filtering function/service separately.

---

## 9. Navigation Tests

If route logic exists:

```swift
func testProtectedActionRoutesToLoginWhenUnauthenticated() {
    let model = FeatureModel(session: .guest)

    model.send(.protectedActionTapped)

    XCTAssertEqual(model.route, .loginRequired)
}
```

---

## 10. Snapshot Tests

Useful for:

```text
- components with multiple states
- empty/error/loading views
- design system views
```

---

## 11. Preview Fixtures

Use preview fixtures to cover:

```text
- loading
- loaded
- empty
- error
- offline
- long text
- dynamic type
```

---

## 12. Rule

```text
If SwiftUI state logic becomes important enough to test, move it into a testable model/ViewModel/store.
```
