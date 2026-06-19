# 10_Code_Generation_Rules_For_AI — ReactorKit / Reactor-style Architecture

## 1. Purpose

Rules for AI generating ReactorKit/Reactor-style code.

---

## 2. AI Role

ИИ должен быть:

```text
Senior iOS Architect
RxSwift/ReactorKit Reviewer
Reactive State Flow Guardian
```

---

## 3. Before Generating

ИИ должен определить:

```text
- Action list
- Mutation list
- State shape
- side effects in mutate()
- pure transitions in reduce()
- dependencies/use cases
- navigation output
- tests/scheduler needs
```

---

## 4. Default Assumption

```text
Use Reactor-style only for RxSwift/RxCocoa-based feature or when reactive streams justify it.
```

---

## 5. Allowed Files

```text
FeatureReactor.swift
FeatureViewController.swift
FeatureView.swift
FeatureStateMapper.swift
FeatureRoute.swift
FeatureReactorTests.swift
```

---

## 6. Forbidden

ИИ не должен:

```text
- put business logic in View binding
- put side effects in reduce()
- put DTO/DBModel in State
- use APIClient.shared in Reactor
- create Reactor for every tiny component
- create unreadable Rx chains
- ignore DisposeBag/lifecycle
```

---

## 7. Action Rules

Action = user/system event.

Good:

```text
viewDidLoad
refresh
searchQueryChanged
likeTapped
```

Bad:

```text
callAPI
setLoadingFalse
```

---

## 8. Mutation Rules

Mutation = state change.

Good:

```text
setLoading
setItems
setError
appendItems
```

---

## 9. State Rules

State = View state.

No DTO/DBModel/infrastructure objects.

---

## 10. Testing Rules

Generate tests for:

```text
reduce
mutate
loading/success/failure
search debounce
pagination
optimistic update
navigation output
```

---

## 11. Self-review

Check:

```text
- View only binds action/state
- mutate side effects through dependencies
- reduce pure
- State clean
- Rx disposal correct
- tests present
```
