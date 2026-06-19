# 09_Testing_Strategy — Coordinator / Flow Architecture

## 1. Purpose

Testing strategy for Coordinator / Flow Architecture.

---

## 2. What to Test

Test:

```text
- route handling
- deep link parsing
- route guard behavior
- child coordinator lifecycle
- flow completion
- protected route redirects
- tab selection
- modal presentation decisions
```

---

## 3. What Not to Test

Do not over-test:

```text
- Apple NavigationStack internals
- UIKit push animation
- trivial NavigationLink
- SwiftUI rendering of destination if already tested elsewhere
```

---

## 4. Route Tests

```swift
func testArticleTapRouteOpensArticleDetails() {
    let coordinator = NewsCoordinator(router: routerSpy)

    coordinator.handle(.articleDetails(ArticleID("1")))

    XCTAssertEqual(routerSpy.pushedRoute, .articleDetails(ArticleID("1")))
}
```

---

## 5. Deep Link Parser Tests

```swift
func testParsesArticleDeepLink() throws {
    let route = try parser.parse(URL(string: "app://article/123")!)

    XCTAssertEqual(route, .articleDetails(ArticleID("123")))
}
```

---

## 6. Auth Gate Tests

```swift
func testProtectedRouteRedirectsToLoginWhenGuest() async {
    let guard = RouteGuardMock(result: .requiresLogin)
    let coordinator = AppCoordinator(routeGuard: guard, router: routerSpy)

    await coordinator.open(.comments(ArticleID("1")))

    XCTAssertEqual(routerSpy.presented, .login)
}
```

---

## 7. Child Coordinator Lifecycle Tests

Test:

```text
- child retained after start
- child removed after finish
- parent receives result
```

---

## 8. Router Spy

Use spy router:

```swift
final class RouterSpy: Router {
    var pushed: [Route] = []
    var presented: [Route] = []

    func push(_ route: Route) {
        pushed.append(route)
    }
}
```

---

## 9. Assembly Tests

If assemblies are complex, test that route creates expected feature with dependencies.

Often smoke/integration test is enough.

---

## 10. Rule

```text
Test decisions and lifecycle, not framework navigation internals.
```
