# 15_Anti_Patterns — Redux / Elm / UDF

## 1. Purpose

Anti-patterns for Redux/Elm/UDF.

---

## 2. Giant Global AppState

Bad:

```text
One AppState contains everything by default.
```

Fix:

```text
feature-level stores/states unless app-wide state required
```

---

## 3. Side Effects in Reducer

Bad:

```text
Reducer calls API/DB directly.
```

Fix:

```text
Reducer returns effect; effect calls dependency.
```

---

## 4. Imperative Actions

Bad:

```text
callAPI
setErrorNil
setLoadingFalse
```

Good:

```text
onAppear
feedResponse
retryTapped
```

---

## 5. State Mutated Outside Store

Bad:

```text
view directly changes state.cards[0]
```

Fix:

```text
dispatch action
```

---

## 6. DTO in State

Bad:

```swift
var articles: [ArticleDTO]
```

Fix:

```text
DTO → Domain/UI state before Store.
```

---

## 7. Global Store for Local Toggle

Bad:

```text
isCardExpanded in AppState for purely local visual expansion.
```

Fix:

```text
@State in Card View.
```

---

## 8. Middleware God Object

Bad:

```text
one middleware handles API, DB, analytics, navigation, auth, cache, sync for everything
```

Fix:

```text
split effects/dependencies by feature/capability.
```

---

## 9. No Tests

UDF without reducer tests loses predictability benefit.

---

## 10. Final Rule

```text
UDF is valuable when every behavior-changing state transition can be traced to an action.
```
