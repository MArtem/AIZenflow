# 05 — SwiftUI

## Data flow first

SwiftUI views are transient value descriptions. Persistent state must live in the correct SwiftUI/Observation storage or an external owner, not in assumptions about struct lifetime.

## Ownership

For Observation (`@Observable`, iOS 17+ when supported by project):

- a view that creates/owns an observable reference model SHOULD store it using `@State`;
- downstream consumers normally receive the reference as `let`;
- use `@Bindable` when the child needs bindings to observable properties;
- use `Environment` for intentionally shared environment-scoped models.

For `ObservableObject` projects:

- creator/owner uses `@StateObject`;
- downstream observer uses `@ObservedObject`;
- app-wide/environment ownership may use `@EnvironmentObject` if that is established project architecture.

Do not construct a reference ViewModel inline in a frequently recomputed body and assume it will persist.

## Source of truth

MUST avoid duplicated writable sources of truth. Derive display state where possible. If a local editable copy is required, define synchronization/commit semantics explicitly.

## Body purity

`body` SHOULD describe UI and avoid side effects, network calls, persistence writes, logging storms, or expensive work.

Side effects belong in explicit actions/lifecycle APIs such as `.task`, `onChange`, commands, or model/service layers as appropriate.

## Identity

MUST preserve stable identity for dynamic collections/navigation. Do not generate a new `UUID()` on every render to satisfy `Identifiable`.

Changing `.id(...)` deliberately resets SwiftUI identity/state and is a review trigger when used as a workaround.

## Lists

- Use stable IDs.
- Avoid expensive transformation repeatedly inside row `body` when it can be precomputed/derived efficiently.
- Do not rely on array index identity for mutable/reordered collections unless index is truly the semantic identity.

## Navigation

Prefer value-driven `NavigationStack(path:)` when programmatic navigation/deep links/state restoration are requirements. Route values should be data, not hidden view-controller side effects.

Navigation manager/router must define who owns path state and how pop/deep-link/reset behave.

## Async work

Use `.task`/`.task(id:)` for view-lifetime async operations. Make repeated loads idempotent/cancellable where view identity changes can trigger new work.

## Animation

- `.animation(_:value:)` attaches animation behavior to view updates triggered by a value change; scope the modifier carefully because multiple changes in the same transaction may animate.
- `withAnimation` should be used when a specific state mutation is the semantic animation event.
- Respect Reduce Motion where custom motion is significant.

## Performance

- Avoid large synchronous work in `body`.
- Avoid unnecessary observation breadth; Observation can update only views reading changed observable properties.
- Use Xcode/SwiftUI Instruments for non-trivial performance issues rather than speculative micro-optimization.

## Previews

Previews SHOULD use deterministic sample dependencies/data and must not require production credentials or mutate production backends.
