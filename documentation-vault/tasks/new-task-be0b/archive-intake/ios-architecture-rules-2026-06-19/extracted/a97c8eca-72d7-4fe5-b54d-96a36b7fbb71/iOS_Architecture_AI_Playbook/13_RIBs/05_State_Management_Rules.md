# 05_State_Management_Rules — RIBs

## 1. Purpose

Этот документ описывает state ownership в RIBs.

---

## 2. Main Rule

```text
A RIB owns state for its business responsibility and lifecycle.
```

---

## 3. Interactor State

Interactor may own:

```text
- business flow state
- active child flow state
- loaded domain state
- selected IDs
- validation state
- pending operations
```

Interactor should not own raw UIKit/SwiftUI layout state.

---

## 4. Router State

Router owns:

```text
- attached child routers
- navigation references
- current child lifecycle
```

Router should not own business state.

---

## 5. Component State

Component owns dependency graph/scoped dependencies.

Component should not be mutable app state store.

---

## 6. View State

View owns:

```text
- visual state
- control state
- animations
- local UI flags
```

For complex UI state, use Presenter/ViewModel/Store inside RIB if needed.

---

## 7. Child State

Child RIB owns its own business state.

Parent should not directly mutate child internals.

---

## 8. App-wide State

Use scoped dependencies:

```text
SessionStore
SettingsStore
FeatureFlagStore
NetworkStatusStore
```

passed through Components.

Avoid global singleton access from random RIBs.

---

## 9. Persistent State

Persistence belongs to repositories/adapters, not directly to RIB state.

---

## 10. Rule

```text
State belongs to the RIB whose lifecycle and business responsibility define it.
```
