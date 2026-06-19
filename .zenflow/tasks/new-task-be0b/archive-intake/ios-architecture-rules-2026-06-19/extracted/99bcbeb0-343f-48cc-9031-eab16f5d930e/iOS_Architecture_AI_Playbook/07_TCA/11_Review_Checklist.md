# 11_Review_Checklist — TCA

## 1. Purpose

Review checklist for TCA features.

---

## 2. State Checklist

```text
[ ] State is minimal
[ ] State is explicit
[ ] No DTO in State
[ ] No DBModel in State
[ ] No APIClient/Repository in State
[ ] Per-item state modeled correctly
[ ] Navigation state explicit
```

---

## 3. Action Checklist

```text
[ ] Actions describe events
[ ] Response actions exist for effects
[ ] Child actions scoped
[ ] Names not imperative implementation commands
[ ] No huge unstructured Action enum
```

---

## 4. Reducer Checklist

```text
[ ] Reducer mutates state synchronously
[ ] Effects returned for async work
[ ] Reducer readable
[ ] Large reducer split into child features/helpers
[ ] No business/data infrastructure details leaking
```

---

## 5. Effect Checklist

```text
[ ] Dependencies used
[ ] Errors handled
[ ] Cancellation where needed
[ ] Debounce where needed
[ ] Long-living effects cancellable
```

---

## 6. View Checklist

```text
[ ] View observes Store
[ ] View sends Actions
[ ] No API/DB calls in View
[ ] No state mutation outside Store
[ ] Child stores scoped properly
```

---

## 7. Dependency Checklist

```text
[ ] No singletons in reducer
[ ] Live/test dependencies separated
[ ] Clock/date/uuid controlled in tests when relevant
```

---

## 8. Testing Checklist

```text
[ ] TestStore tests success
[ ] TestStore tests failure
[ ] TestStore tests navigation
[ ] Cancellation/debounce tested
[ ] Optimistic update tested
[ ] Child feature tested if non-trivial
```

---

## 9. Red Flags

```text
- Reducer 2000 lines
- Action enum 300 cases
- State contains API DTO
- Effect without error handling
- View calls dependency directly
- No tests
- Global AppState for everything
```
