# 08_Error_Loading_Empty_State_Rules — RIBs

## 1. Purpose

Rules for loading/error/empty state in RIBs.

---

## 2. Main Rule

```text
Business operation state belongs to Interactor. Display rendering belongs to View/Presenter/ViewModel.
```

---

## 3. Loading

Interactor starts operation.

View/Presenter displays loading.

For child flow loading, parent Interactor may attach loading child RIB if it is a separate flow.

---

## 4. Error

Interactor receives AppError/DomainError.

Then:

```text
- show error in current view
- attach error flow
- notify parent listener
- detach child
```

depending on flow.

---

## 5. Empty

Empty content is usually local display state.

Empty flow may become child RIB only if it has business lifecycle.

---

## 6. Flow Failure

Child failure:

```text
Child Interactor → Listener → Parent Interactor
```

Parent decides whether to retry, detach or route elsewhere.

---

## 7. Offline

Offline state can be:

```text
current RIB display state
app-level NetworkStatus dependency
separate offline flow RIB if major app behavior
```

---

## 8. Rule

```text
Do not create child RIBs for every UI state. Create child RIBs for real lifecycle/business flows.
```
