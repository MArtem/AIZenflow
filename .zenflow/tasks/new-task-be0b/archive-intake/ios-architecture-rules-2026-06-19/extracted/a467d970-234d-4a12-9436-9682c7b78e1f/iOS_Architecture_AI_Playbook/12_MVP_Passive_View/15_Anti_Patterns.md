# 15_Anti_Patterns — MVP / Passive View

## 1. Purpose

Anti-patterns for MVP/Passive View.

---

## 2. View Still Does Business Logic

Bad:

```text
View validates business rules after Presenter added.
```

Fix:

```text
Move to Presenter or UseCase depending on rule type.
```

---

## 3. Presenter Calls APIClient Directly

Bad:

```text
Presenter → APIClient.shared
```

Fix:

```text
Presenter → UseCase/Repository boundary.
```

---

## 4. Huge View Protocol

Bad:

```text
80 methods like setTitle, setSubtitle, setButton, setColor...
```

Fix:

```text
display(ViewState)
```

---

## 5. Presenter God Object

Symptoms:

```text
API
DB
formatting
navigation
business rules
cache
analytics
```

Fix:

```text
split UseCase/Repository/Router/Analytics boundary.
```

---

## 6. Presenter Knows Layout Too Deeply

Bad:

```text
Presenter decides exact constraints, stack layout, font metrics.
```

Fix:

```text
Presenter decides display state, View owns layout.
```

---

## 7. DTO in View

Bad:

```text
View displays ArticleDTO.
```

Fix:

```text
Domain → ViewState.
```

---

## 8. MVP for Tiny Component

Bad:

```text
IconPresenter for static icon.
```

Fix:

```text
simple View props.
```

---

## 9. No Presenter Tests

MVP without Presenter tests loses main benefit.

---

## 10. Final Rule

```text
MVP is useful when Presenter has real presentation decisions and View can stay passive.
```
