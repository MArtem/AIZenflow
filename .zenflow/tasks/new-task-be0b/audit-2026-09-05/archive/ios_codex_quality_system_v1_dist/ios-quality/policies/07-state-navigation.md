# 07 — State, Data Flow, and Navigation

## State modeling

MUST distinguish:

- domain/source data;
- derived presentation state;
- transient UI state;
- navigation state;
- persisted state.

Do not persist or synchronize data merely because a UI property exists.

## Single writer

Mutable state SHOULD have one clear writer/owner. Multiple components may request transitions, but hidden peer-to-peer mutation is discouraged.

## Explicit finite states

Prefer enum state machines when states are mutually exclusive or transitions matter.

Example:

```swift
enum FeedState {
    case idle
    case loading
    case content([FeedCard])
    case empty
    case error(ErrorViewState)
}
```

Avoid contradictory combinations such as `isLoading == true` plus `error != nil` unless that is intentionally valid.

## Navigation as state

For state-driven navigation:

```text
Route value -> path mutation -> NavigationStack reconciliation -> destination
```

A router SHOULD manipulate route state, not instantiate hidden view hierarchies unless UIKit/coordinator architecture requires it.

## Route design

- Route associated values should contain stable navigation input, not arbitrary heavyweight services.
- Avoid storing mutable view models directly in `Hashable` route values unless identity semantics are carefully designed.
- Deep links must validate external input before converting it to internal routes.

## Restoration

If state restoration/deep linking is required, route/state data must be reconstructible or codable as appropriate. Do not promise restoration without testing terminated/relaunch scenarios.

## Event ordering

Async state updates must protect against stale completion. Common solutions include cancellation of previous work, request IDs/generations, or actor-owned state machines.
