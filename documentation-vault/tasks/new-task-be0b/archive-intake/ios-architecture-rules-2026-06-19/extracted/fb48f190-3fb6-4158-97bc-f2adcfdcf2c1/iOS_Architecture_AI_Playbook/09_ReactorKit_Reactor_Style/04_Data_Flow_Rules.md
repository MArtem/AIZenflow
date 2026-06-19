# 04_Data_Flow_Rules — ReactorKit / Reactor-style Architecture

## 1. Purpose

Этот документ описывает data flow в Reactor-style architecture.

---

## 2. Main Flow

```text
View binds UI event
 → Action
 → mutate(action:)
 → Observable<Mutation>
 → reduce(state:mutation:)
 → State
 → View binds State
```

---

## 3. Load Flow

```text
Action.viewDidLoad
 → mutate starts useCase/API effect
 → emits .setLoading(true)
 → emits .setArticles(result)
 → emits .setLoading(false)
 → reduce updates State
```

---

## 4. Search Flow

```text
search text binding
 → Action.searchQueryChanged
 → mutate debounce/distinct/cancel
 → search use case
 → Mutation.setSearchResults
 → State
```

---

## 5. Pagination Flow

```text
scroll near bottom
 → Action.loadNextPage
 → mutate checks current state or guarded logic
 → fetch next page
 → Mutation.appendItems
```

Avoid duplicate page requests.

---

## 6. Optimistic Update Flow

```text
Action.likeTapped(id)
 → Mutation.setLiked(id, true)
 → API/use case call
 → success: Mutation.setLikeLoading(id, false)
 → failure: Mutation.setLiked(id, false), Mutation.setError
```

---

## 7. Mapping Rules

```text
DTO/DBModel → Domain in Data
Domain → State/ViewState in Presentation/Reactor mapper
```

State should not contain DTO/DBModel.

---

## 8. Error Flow

```text
UseCase error
 → Reactor maps to Mutation.setError
 → reduce updates State.error
 → View displays error
```

---

## 9. Navigation Flow

Options:

```text
State route
Output relay
Coordinator
RxFlow Step
```

Avoid navigating directly from View binding logic if it contains business decisions.

---

## 10. Rule

```text
Reactor is the transformation boundary from user interaction to view state.
```
