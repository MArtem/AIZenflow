# 09_Testing_Strategy — MVP / Passive View

## 1. Purpose

Testing strategy for MVP.

---

## 2. Main Rule

```text
Presenter should be testable without rendering UI.
```

---

## 3. Presenter Tests

Use:

```text
ViewSpy
RouterSpy
UseCaseMock
```

---

## 4. Example

```swift
func testViewDidLoadDisplaysLoadingThenContent() async {
    let view = ViewSpy()
    let useCase = LoadItemsUseCaseMock(result: .success([.fixture()]))
    let router = RouterSpy()
    let presenter = ItemsPresenter(view: view, useCase: useCase, router: router)

    await presenter.viewDidLoad()

    XCTAssertTrue(view.didDisplayLoading)
    XCTAssertEqual(view.displayedContent?.items.count, 1)
}
```

---

## 5. Error Test

```text
UseCase throws
 → Presenter displays ErrorViewState
```

---

## 6. Empty Test

```text
UseCase returns []
 → Presenter displays EmptyViewState
```

---

## 7. Navigation Test

```text
presenter.itemTapped(id)
 → router.openDetails(id)
```

---

## 8. View Tests

Mostly snapshot/UI tests.

Do not unit-test trivial UI setters.

---

## 9. UseCase/Data Tests

Keep separate from Presenter tests.

---

## 10. Rule

```text
If Presenter cannot be tested without real ViewController, MVP boundary is weak.
```
