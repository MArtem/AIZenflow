# 05_State_Management_Rules — VIPER

## 1. Purpose

Этот документ описывает state ownership in VIPER.

---

## 2. Main Rule

```text
View owns visible UI controls.
Presenter owns presentation state.
Interactor owns business/domain state.
Router owns navigation context.
```

---

## 3. View State

View may own:

```text
- UIKit control state
- local visual state
- current displayed ViewModel
```

View must not own business state.

---

## 4. Presenter State

Presenter may own:

```text
- currently displayed view model
- selected UI state
- screen presentation flags
- route intent before routing
```

Presenter should not own API/cache/business persistence state.

---

## 5. Interactor State

Interactor may own:

```text
- loaded entities
- pagination cursor
- validation results
- current business operation state
```

Interactor should not own formatted UI strings.

---

## 6. Router State

Router may own:

```text
- weak view controller reference
- navigation controller reference
- active child module reference if needed
```

Router should not own domain state.

---

## 7. Entity State

Entity represents business state.

It should be independent from UI and infrastructure.

---

## 8. Loading State

Presenter formats loading state for View.

Interactor starts/finishes operation.

---

## 9. Per-item State

If per-item action is business-related:

```text
Interactor tracks operation
Presenter maps to item view model
```

If purely visual:

```text
View can own local state
```

---

## 10. Rule

```text
State should live with the role that understands its meaning.
```
