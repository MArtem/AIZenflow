# 11_Review_Checklist — Redux / Elm / UDF

## 1. Purpose

Review checklist for UDF features.

---

## 2. State Checklist

```text
[ ] State explicit
[ ] State minimal
[ ] No DTO in State
[ ] No DBModel in State
[ ] No service instances in State
[ ] Local UI state not forced global
```

---

## 3. Action Checklist

```text
[ ] Actions describe events
[ ] Response actions exist
[ ] Action enum not random command list
[ ] Names not implementation commands
```

---

## 4. Reducer Checklist

```text
[ ] Reducer deterministic
[ ] No API/DB calls inside reducer
[ ] State changes only through reducer
[ ] Reducer not huge
[ ] Derived state handled intentionally
```

---

## 5. Effect Checklist

```text
[ ] Effects use dependencies
[ ] Effects send result actions
[ ] Errors handled
[ ] Cancellation/debounce where needed
```

---

## 6. View Checklist

```text
[ ] View renders State
[ ] View dispatches Actions
[ ] View does not call API/DB
[ ] View does not mutate State directly
```

---

## 7. Testing Checklist

```text
[ ] Reducer success tests
[ ] Reducer failure tests
[ ] Effect tests
[ ] Navigation state tests
[ ] Optimistic update tests if needed
```

---

## 8. Red Flags

```text
- Global AppState for everything
- Reducer calls API
- Action names like setLoadingFalse
- State contains DTO
- No tests
- Middleware God Object
```
