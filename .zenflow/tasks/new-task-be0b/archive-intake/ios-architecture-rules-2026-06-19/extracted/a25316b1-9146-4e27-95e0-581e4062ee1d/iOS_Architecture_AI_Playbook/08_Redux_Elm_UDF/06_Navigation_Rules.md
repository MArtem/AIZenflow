# 06_Navigation_Rules — Redux / Elm / UDF

## 1. Purpose

Этот документ описывает navigation в UDF.

---

## 2. Main Rule

```text
Navigation should be represented by State or explicit Output.
```

---

## 3. State-driven Navigation

```swift
struct NewsFeedState: Equatable {
    var route: NewsFeedRoute?
}
```

Action:

```swift
case articleTapped(ArticleID)
case routeHandled
```

Reducer:

```text
articleTapped → route = .details(id)
routeHandled → route = nil
```

---

## 4. Path Navigation

For stack:

```swift
var path: [Route] = []
```

Reducer mutates path.

---

## 5. Coordinator Boundary

For app-level flow:

```text
Reducer emits FeatureOutput
Coordinator handles output
```

---

## 6. Route Payload

Use IDs/value objects.

Avoid DTO/DBModel.

---

## 7. One-shot Navigation

If route is one-shot, clear after handling.

---

## 8. Deep Links

Deep links dispatch actions:

```text
DeepLinkParser → AppAction.deepLinkReceived(route)
```

Reducer/coordinator handles it.

---

## 9. Rule

```text
Navigation is either state or explicit output, not random hidden side effect.
```
