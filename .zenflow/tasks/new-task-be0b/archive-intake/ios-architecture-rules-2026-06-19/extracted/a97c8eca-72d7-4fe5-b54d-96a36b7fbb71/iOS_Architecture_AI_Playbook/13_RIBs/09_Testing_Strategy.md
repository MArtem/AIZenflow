# 09_Testing_Strategy — RIBs

## 1. Purpose

Testing strategy for RIBs.

---

## 2. What to Test

Test:

```text
- Interactor business logic
- Router attach/detach behavior
- Listener communication
- Builder wiring
- dependency propagation
- child lifecycle
```

---

## 3. Interactor Tests

Use:

```text
RouterMock
ListenerMock
UseCaseMock
```

Example:

```swift
func testLoginSuccessNotifiesListener() async {
    let listener = LoginListenerMock()
    let interactor = LoginInteractor(listener: listener, loginUseCase: .success)

    await interactor.loginTapped(email: "a@b.com", password: "123")

    XCTAssertEqual(listener.didLoginUserID, UserID("1"))
}
```

---

## 4. Router Tests

Test:

```text
attach child called
detach child called
child retained
child removed
view hierarchy operation called
```

---

## 5. Builder Tests

Smoke test:

```text
builder builds interactor/router/view
dependencies injected
listener assigned
child builders available
```

---

## 6. Listener Tests

Test child-to-parent communication.

---

## 7. View Tests

Use snapshot/UI tests for rendering.

Do not over-test RIB mechanics through UI.

---

## 8. Rule

```text
RIBs are valuable when business flow and lifecycle can be tested without full app UI.
```
