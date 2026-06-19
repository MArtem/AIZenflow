# 05_State_Management_Rules — Hexagonal Architecture / Ports & Adapters

## 1. Purpose

Hexagonal Architecture separates state by boundary.

---

## 2. Main Rule

```text
Domain state is business state.
Adapter state is technical state.
Presentation state is UI state.
```

---

## 3. Domain State

Domain can contain:

```text
- entity lifecycle
- value object invariants
- business statuses
- domain errors
```

Examples:

```text
ArticleStatus.published
SubscriptionStatus.active
PaymentStatus.pending
```

---

## 4. Presentation State

Presentation owns:

```text
- loading
- error view state
- empty state
- selection
- search query
- per-card loading
- navigation route
```

---

## 5. Adapter State

Adapters can own:

```text
- token cache
- DB context
- HTTP client config
- sync queue
- cache metadata
- retry counters
```

But should expose domain-friendly results.

---

## 6. App-wide State

App-wide stores can be ports/adapters:

```text
SessionPort
SettingsPort
FeatureFlagPort
NetworkStatusPort
```

---

## 7. Persistent State

Persistence adapter owns mechanics.

Domain does not know persistence framework.

---

## 8. Sync State

Sync can be modeled through a port:

```swift
protocol SyncStatusPort {
    func currentStatus() async -> SyncStatus
}
```

Adapter implements through DB/background tasks.

---

## 9. Rule

```text
State should not cross boundaries in technology-specific form.
```
