# 08_Error_Loading_Empty_State_Rules — VIP / Clean Swift

## 1. Purpose

Rules for loading/error/empty in VIP.

---

## 2. Main Rule

```text
Interactor knows operation status.
Presenter formats user-facing state.
View displays.
```

---

## 3. Loading Flow

```text
View sends Load.Request
 → Interactor asks Presenter.presentLoading()
 → Presenter creates Loading ViewModel
 → View displays loading
 → Interactor performs work
 → Presenter presents result
```

---

## 4. Error Flow

```text
Worker/UseCase error
 → Interactor creates Response with error
 → Presenter maps to ErrorViewModel
 → View displays error
```

---

## 5. Empty Flow

```text
Interactor receives empty domain result
 → Response empty
 → Presenter creates EmptyViewModel
 → View displays empty
```

---

## 6. Refresh

Refresh should not erase existing content unless intended.

Presenter should create refresh-specific ViewModel.

---

## 7. Pagination

Pagination loading/error should be separate from full-screen state.

---

## 8. Per-item Loading

Interactor tracks per-item operation.

Presenter formats per-item ViewModel update.

---

## 9. Rule

```text
Never let View invent loading/error/empty semantics that belong to business/presentation flow.
```
