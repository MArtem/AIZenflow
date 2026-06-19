# 05_State_Management_Rules — VIP / Clean Swift

## 1. Purpose

Этот документ описывает state ownership in VIP/Clean Swift.

---

## 2. Main Rule

```text
Interactor owns business/session state for the scene.
View owns rendered UI state.
Presenter creates display state.
```

---

## 3. View State

View holds:

```text
displayed ViewModel
local UI-only state
UIKit control state
SwiftUI local state
```

But should not hold business state.

---

## 4. Interactor State

Interactor can hold:

```text
current domain entities
pagination cursor
selected IDs
validation state
business process state
```

Avoid storing UI-formatted strings here.

---

## 5. Presenter State

Presenter should usually be stateless.

It maps Response to ViewModel.

If it has state, it must be presentation-only and justified.

---

## 6. Router State

Router may hold navigation references:

```text
weak view controller
navigation controller
route context
```

Not business state.

---

## 7. Worker State

Worker may hold technical dependencies:

```text
repository
api client
database client
```

Not UI state.

---

## 8. Loading State

Interactor decides operation starts/ends.

Presenter creates loading ViewModel.

View displays loading.

---

## 9. Error State

Interactor gets domain/app error.

Presenter maps to user-facing error view model.

View displays.

---

## 10. Rule

```text
Business state belongs near Interactor. Display state belongs near Presenter/View.
```
