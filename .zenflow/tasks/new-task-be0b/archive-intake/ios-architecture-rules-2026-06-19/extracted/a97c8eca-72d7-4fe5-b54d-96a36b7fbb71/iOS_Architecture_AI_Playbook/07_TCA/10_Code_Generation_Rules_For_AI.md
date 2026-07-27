# 10_Code_Generation_Rules_For_AI — TCA

## 1. Purpose

Rules for AI generating TCA code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior/Staff iOS Architect
TCA Feature Author
Reducer Reviewer
TestStore Specialist
```

---

## 3. Before Generating

ИИ обязан определить:

```text
- feature state
- actions
- effects
- dependencies
- child features
- navigation state
- cancellation/debounce needs
- tests
```

---

## 4. Default Assumption

```text
Use modern TCA style with @Reducer, @ObservableState when appropriate, dependency clients, explicit effects, and TestStore tests.
```

---

## 5. Allowed Files

```text
FeatureNameFeature.swift
FeatureNameView.swift
FeatureNameClient.swift
FeatureNameClient+Live.swift
FeatureNameMapper.swift
ChildFeature.swift
FeatureNameFeatureTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put APIClient.shared in reducer
- store DTO/DBModel in State
- mutate state from View directly
- put side effects in View
- use closures for navigation when state should drive it
- create child reducer for every tiny view
- create one huge AppFeature by default
- ignore tests
```

---

## 7. Action Rules

Actions should describe:

```text
user events
lifecycle events
internal events
effect responses
child actions
navigation actions
```

Avoid imperative names:

```text
callAPI
setLoadingFalse
doLikeRequest
```

Prefer:

```text
onAppear
refreshPulled
likeTapped
feedResponse
```

---

## 8. State Rules

State must be:

```text
explicit
minimal
equatable/testable where useful
free of infrastructure types
```

---

## 9. Effect Rules

Effects must:

```text
- use dependencies
- handle errors
- send result actions
- support cancellation for long/search effects
```

---

## 10. Testing Rules

ИИ must generate tests for:

```text
success
failure
empty
refresh
pagination
optimistic update
navigation
cancellation/debounce when present
```

---

## 11. Self-review

Check:

```text
- actions event-like
- reducer readable
- dependencies injected
- no DTO/DBModel in State
- no API/DB in View
- effects cancellable where needed
- tests cover important flows
```
