# 08_Error_Loading_Empty_State_Rules — Coordinator / Flow Architecture

## 1. Purpose

Coordinator can participate in error/loading/empty flows only at navigation level.

---

## 2. Main Rule

```text
Screen errors belong to screen state.
Flow errors may belong to Coordinator.
```

---

## 3. Screen Error

Examples:

```text
feed load failed
article not found
comments failed
pagination failed
```

Owned by feature presentation.

---

## 4. Flow Error

Examples:

```text
deep link invalid
route forbidden
auth required
flow cancelled
payment flow unavailable
```

May be handled by Coordinator/AppCoordinator.

---

## 5. Loading

Coordinator should not own normal screen loading.

Coordinator may own transition/loading for:

```text
- app launch routing
- auth gate check
- deep link resolving
- remote config route decision
```

---

## 6. Empty State

Empty state is usually screen state, not Coordinator state.

---

## 7. Invalid Deep Link

Deep link failure can route to:

```text
- fallback screen
- not found screen
- alert/banner via app presentation
```

---

## 8. Unauthorized

Unauthorized can be:

```text
screen error → route login
```

Coordinator handles login route.

---

## 9. Cancelled Flow

Coordinator handles:

```text
- user cancelled login
- user cancelled checkout
- modal dismissed
- child flow finished
```

---

## 10. Rule

```text
Coordinator handles flow-level outcomes, not content-level UI states.
```
