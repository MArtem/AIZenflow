# 09_Testing_Strategy — VIPER

## 1. Purpose

Testing strategy for VIPER.

---

## 2. What to Test

Test:

```text
- Presenter behavior
- Interactor business flow
- Router navigation decisions
- Builder wiring smoke tests
- data mapping if used
```

---

## 3. Presenter Tests

Use ViewSpy and InteractorMock/RouterSpy.

```swift
func testViewDidLoadShowsLoadingAndRequestsData() {
    let view = ViewSpy()
    let interactor = InteractorMock()
    let router = RouterSpy()
    let presenter = FeaturePresenter(view: view, interactor: interactor, router: router)

    presenter.viewDidLoad()

    XCTAssertTrue(view.didShowLoading)
    XCTAssertTrue(interactor.didLoad)
}
```

---

## 4. Interactor Tests

Use repository/use case mocks.

```swift
func testLoadSuccessReturnsEntities() async {
    let repository = RepositoryMock(result: .success([.fixture()]))
    let interactor = FeatureInteractor(repository: repository)

    let result = await interactor.load()

    XCTAssertEqual(result.items.count, 1)
}
```

---

## 5. Router Tests

Test:

```text
- correct destination
- correct route parameter
- no DTO/DBModel passed
```

---

## 6. Builder Tests

Smoke test module construction if builder is complex.

---

## 7. View Tests

Use snapshot/UI tests for important states.

Unit-test View only if it has non-trivial display logic.

---

## 8. Rule

```text
VIPER should make Presenter and Interactor testable without rendering UI.
```
