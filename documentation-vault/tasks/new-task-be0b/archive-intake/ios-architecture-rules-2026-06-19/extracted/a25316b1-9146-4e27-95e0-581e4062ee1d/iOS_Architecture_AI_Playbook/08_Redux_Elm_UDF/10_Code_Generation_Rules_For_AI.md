# 10_Code_Generation_Rules_For_AI — Redux / Elm / UDF

## 1. Purpose

Rules for AI generating Redux/Elm/UDF code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior/Staff iOS Architect
UDF State Architecture Reviewer
Reducer/Effect Designer
```

---

## 3. Before Generating

ИИ обязан определить:

```text
- State
- Actions
- Reducer
- Effects
- Dependencies
- Store ownership
- Navigation state/output
- Tests
```

---

## 4. Default Assumption

```text
Use feature-level UDF, not one giant global AppState, unless app-wide state is explicitly required.
```

---

## 5. Allowed Files

```text
FeatureState.swift
FeatureAction.swift
FeatureReducer.swift
FeatureStore.swift
FeatureEffects.swift
FeatureEnvironment.swift
FeatureView.swift
FeatureTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- mutate state outside store
- put side effects inside pure reducer
- store DTO/DBModel in State
- put APIClient in View
- use global store for local visual state
- make every tiny view a feature
- make action names imperative implementation commands
```

---

## 7. Action Rules

Actions should be events:

```text
onAppear
refreshPulled
searchQueryChanged
feedResponse
likeTapped
```

Avoid:

```text
callAPI
setLoadingFalse
doNetworkRequest
```

---

## 8. Reducer Rules

Reducer should:

```text
- be deterministic
- mutate state only from action
- return effect descriptor if needed
- not call external services directly
```

---

## 9. Effect Rules

Effects should:

```text
- use dependencies
- handle errors
- dispatch result actions
- support cancellation/debounce if needed
```

---

## 10. Self-review

Check:

```text
- every state change has action
- effects outside reducer
- no DTO/DBModel in state
- no global state abuse
- reducer tests exist
- effect tests exist
```
