# 09_Testing_Strategy — VIP / Clean Swift

## 1. Purpose

Testing strategy for VIP/Clean Swift.

---

## 2. What to Test

Test:

```text
- Interactor business flow
- Presenter formatting
- Router route decisions
- Worker/data mapping if needed
- validation
- error/empty/loading presentation
```

---

## 3. Interactor Tests

Use PresenterSpy and Worker/UseCase mocks.

```swift
func testLoadSuccessPresentsResponse() async {
    let presenter = PresenterSpy()
    let worker = WorkerMock(result: .success([.fixture()]))
    let interactor = FeatureInteractor(worker: worker, presenter: presenter)

    await interactor.load(Feature.Load.Request())

    XCTAssertEqual(presenter.presentedResponse?.items.count, 1)
}
```

---

## 4. Presenter Tests

Presenter tests check formatting:

```swift
func testPresenterFormatsDate() {
    let view = ViewSpy()
    let presenter = FeaturePresenter(view: view)

    presenter.present(Feature.Load.Response(items: [.fixture(date: fixedDate)]))

    XCTAssertEqual(view.displayedViewModel?.items.first?.dateText, "19 Jun 2026")
}
```

---

## 5. Router Tests

Test:

```text
- selected route
- payload IDs
- destination assembly called
- no DTO/DBModel passed
```

---

## 6. Worker Tests

Test:

```text
- API/DB/cache interaction
- DTO → Domain mapping
- error mapping
```

---

## 7. View Tests

Avoid over-testing ViewController UI mechanics unless critical.

Use UI/snapshot tests for important layout states.

---

## 8. Rule

```text
VIP is valuable when Interactor and Presenter can be tested without rendering UI.
```
