# 08_Error_Loading_Empty_State_Rules — VIPER

## 1. Purpose

Rules for loading/error/empty state in VIPER.

---

## 2. Main Rule

```text
Interactor determines operation outcome.
Presenter creates display state.
View renders display state.
```

---

## 3. Loading Flow

```text
View → Presenter: viewDidLoad
Presenter → View: showLoading
Presenter → Interactor: load
Interactor → Presenter: didLoad result
Presenter → View: showContent/showError/showEmpty
```

Alternative style can route loading via Interactor output; choose one project-wide style.

---

## 4. Error Flow

```text
Interactor receives error
 → Presenter formats ErrorViewModel
 → View displays
```

---

## 5. Empty Flow

```text
Interactor receives empty domain result
 → Presenter creates EmptyViewModel
 → View displays
```

---

## 6. Refresh

Refresh state should be separate from initial loading.

---

## 7. Pagination

Pagination loading/error should not replace whole content.

---

## 8. Per-item Loading

Presenter should be able to create item-level loading ViewModel.

---

## 9. Rule

```text
View should not invent semantic loading/error/empty meaning.
```
