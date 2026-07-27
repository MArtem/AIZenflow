# 15_Anti_Patterns — ReactorKit / Reactor-style Architecture

## 1. Purpose

Anti-patterns for ReactorKit/Reactor-style architecture.

---

## 2. Business Logic in View Binding

Bad:

```text
button.rx.tap
  .flatMap { api.call() }
  .map { business decision }
```

Fix:

```text
View binds tap to Action.
Reactor handles logic.
```

---

## 3. Side Effects in reduce()

Bad:

```text
reduce() calls API or writes DB
```

Fix:

```text
side effects in mutate()
```

---

## 4. DTO in State

Bad:

```swift
var articles: [ArticleDTO]
```

Fix:

```text
DTO → Domain/ViewState before State.
```

---

## 5. Mutation as User Event

Bad:

```text
Mutation.likeTapped
```

Fix:

```text
Action.likeTapped
Mutation.setLiked
```

---

## 6. Action as Implementation Command

Bad:

```text
Action.callLikeAPI
```

Fix:

```text
Action.likeTapped
```

---

## 7. Reactor for Tiny Component

Bad:

```text
DividerReactor
TitleLabelReactor
```

Fix:

```text
props/state/callbacks
```

---

## 8. Massive Reactor

Symptoms:

```text
huge Action/Mutation/State
15 dependencies
many unrelated flows
unreadable mutate()
```

Fix:

```text
split feature, child reactors, use cases
```

---

## 9. Singleton Dependencies

Bad:

```text
APIClient.shared in Reactor
```

Fix:

```text
inject dependency
```

---

## 10. Navigation Hidden in Subscriptions

Bad:

```text
state.map(...).subscribe { push(...) }
```

everywhere.

Fix:

```text
explicit route/output/coordinator
```

---

## 11. No Tests

Reactor-style without reduce/mutate tests loses much of its benefit.

---

## 12. Final Rule

```text
Reactor-style is valuable only when Action → Mutation → State remains clear, testable and readable.
```
