# 15_Anti_Patterns — TCA

## 1. Purpose

Anti-patterns for TCA.

---

## 2. One Giant AppFeature

Bad:

```text
Entire app in one State/Action/Reducer.
```

Fix:

```text
Compose feature reducers.
```

---

## 3. DTO in State

Bad:

```swift
var articles: [ArticleDTO]
```

Fix:

```text
DTO → Domain/UI State before entering feature state.
```

---

## 4. Imperative Actions

Bad:

```text
callFetchAPI
setLoadingFalse
performLikeRequest
```

Good:

```text
onAppear
feedResponse
likeTapped
```

---

## 5. Effect Without Cancellation

Bad for search/pagination streams.

Fix:

```text
use cancellable/debounce lifecycle.
```

---

## 6. View Calls Dependency

Bad:

```swift
Button { Task { await client.like(id) } }
```

Fix:

```text
Button sends .likeTapped(id)
```

---

## 7. Reducer as God Object

Symptoms:

```text
huge State
huge Action
huge body
many unrelated concerns
```

Fix:

```text
child features, helper reducer methods, modular split
```

---

## 8. Child Feature for Every View

Bad:

```text
TitleFeature
IconFeature
DividerFeature
```

Fix:

```text
Only child feature when state/actions/effects justify it.
```

---

## 9. No Tests

TCA without tests wastes one of its core advantages.

---

## 10. Navigation Outside State

Bad:

```text
random closures and imperative navigation while state also exists
```

Fix:

```text
state-driven navigation
```

---

## 11. Singleton Dependencies

Bad:

```text
APIClient.shared in reducer
```

Fix:

```text
dependency clients
```

---

## 12. Final Rule

```text
TCA is not about boilerplate. It is about making feature behavior explicit, composable, testable, and effect-safe.
```
