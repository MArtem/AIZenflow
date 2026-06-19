# 08_Error_Loading_Empty_State_Rules — Modular / Feature-Sliced Architecture

## 1. Purpose

This document defines loading/error/empty ownership across modules.

---

## 2. Main Rule

```text
Feature owns user-facing state.
Shared/Core owns reusable primitives.
Infrastructure owns technical errors.
```

---

## 3. Shared Error Types

Core may define:

```swift
enum AppError: Error, Equatable {
    case networkUnavailable
    case unauthorized
    case forbidden
    case unknown
}
```

But feature maps to its own UI state.

---

## 4. Feature Error ViewState

```swift
struct NewsErrorViewState: Equatable {
    let title: String
    let message: String
    let retryAction: NewsAction?
}
```

---

## 5. Shared UI Components

DesignSystem/Shared UI can provide generic components:

```text
ErrorView
EmptyStateView
LoadingView
```

But feature supplies text/actions.

---

## 6. Loading Ownership

Feature owns:

```text
initial loading
refresh loading
pagination loading
per-item loading
```

Shared can provide reusable `LoadingState` enum if generic.

---

## 7. Empty State

Feature defines semantics:

```text
No news
No search results
No saved articles
```

Shared component renders generic layout.

---

## 8. Offline State

Infrastructure detects network state.
Repository determines data freshness.
Feature maps to offline banner/empty/error.

---

## 9. Rule

```text
Reusable components can be shared; user-facing meaning belongs to feature.
```
