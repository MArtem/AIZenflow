# 11_Review_Checklist — MVC / Massive ViewController / Migration

## 1. Purpose

Review checklist for MVC/Massive ViewController migration.

---

## 2. ViewController Checklist

```text
[ ] ViewController mostly UI glue
[ ] No raw API call
[ ] No JSON decoding
[ ] No DB/cache policy
[ ] No business validation
[ ] No complex formatting
[ ] No destination graph construction
```

---

## 3. Extraction Checklist

```text
[ ] API moved to Repository/DataSource
[ ] DTO moved to Data
[ ] Mapping extracted
[ ] Business rules moved to UseCase/Interactor
[ ] ViewState introduced
[ ] Navigation route/coordinator introduced if needed
```

---

## 4. State Checklist

```text
[ ] Loading/error/empty explicit
[ ] Refresh not mixed with initial loading
[ ] Pagination separate
[ ] Per-item server state not hidden in cell
```

---

## 5. Testing Checklist

```text
[ ] Characterization tests if risky
[ ] Mapper tests
[ ] UseCase tests
[ ] ViewModel/Presenter tests
[ ] Navigation tests if extracted
```

---

## 6. Risk Checklist

```text
[ ] Refactor does not change behavior accidentally
[ ] Migration steps small
[ ] No new Helper/Manager God Object
[ ] No big bang rewrite
```

---

## 7. Red Flags

```text
- Massive ViewController became Massive ViewModel
- logic moved to CommonHelper
- DTO still rendered in cell
- Coordinator calls API
- no tests after risky refactor
- static screen over-architected
```
