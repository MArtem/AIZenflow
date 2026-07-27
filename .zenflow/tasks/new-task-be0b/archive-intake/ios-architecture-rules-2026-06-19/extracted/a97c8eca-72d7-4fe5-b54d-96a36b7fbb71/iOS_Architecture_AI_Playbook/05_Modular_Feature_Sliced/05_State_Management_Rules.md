# 05_State_Management_Rules — Modular / Feature-Sliced Architecture

## 1. Purpose

Этот документ определяет state ownership в модульном проекте.

---

## 2. Main Rule

```text
State should be owned by the smallest module that legitimately needs it.
```

---

## 3. Local Feature State

Feature owns:

```text
- screen state
- feature-specific filters
- local pagination state
- per-card loading
- feature navigation state
```

---

## 4. App-wide State

App/Core owns:

```text
- auth session
- app settings
- selected locale
- feature flags
- global network status
```

Do not duplicate app-wide state in multiple features.

---

## 5. Shared State

Shared state must have clear ownership.

Bad:

```text
SharedState.shared.anything
```

Good:

```text
SessionStore
SettingsStore
FeatureFlagStore
NetworkStatusStore
```

---

## 6. Cross-feature State

If two features need same state:

```text
- lift state to parent/app layer
- create shared store with clear API
- use domain event/output
- pass IDs and reload in destination
```

Avoid direct state sharing between feature internals.

---

## 7. Persistent State

Persistence module provides mechanics.

Feature repository owns policy:

```text
NewsRepository decides how News cache works.
Persistence module only stores/fetches.
```

---

## 8. Navigation State

Navigation state may live in:

```text
AppCoordinator
FlowCoordinator
FeatureCoordinator
NavigationModel
```

not in random shared singleton.

---

## 9. Rule

```text
State ownership follows product ownership and lifetime, not convenience.
```
