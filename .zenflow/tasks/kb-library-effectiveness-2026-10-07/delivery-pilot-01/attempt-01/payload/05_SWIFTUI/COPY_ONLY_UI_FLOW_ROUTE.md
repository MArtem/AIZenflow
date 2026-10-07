# iOS UI state, rendering and navigation — curated copy-only route

Use after project-local UI rules for a SwiftUI, UIKit or mixed screen change. This route selects
app-neutral concerns from `IOS-05-01` through `IOS-05-16`, `IOS-06-01` through `IOS-06-10`, and
`IOS-07-01` through `IOS-07-06`. It does not assume SwiftUI, a specific architecture, the newest
SDK, or a mandated API replacement. Confirm the actual toolchain and supported OS range first.

- Name the state owner and user/system intents. Keep loading, empty, content, failure, retry,
  offline and permission states coherent when applicable. An old async result must not overwrite
  newer input; leaving a screen must not silently retain work without an owner.
- SwiftUI: distinguish owned from injected state; keep `body` and layout evaluation side-effect
  free and cheap; use stable identity for changing collections; review presentation bindings,
  focus, animation and availability against the actual project. Avoid a per-child ViewModel when
  narrow immutable input and callbacks suffice.
  Trace Observation dependencies and invalidation: a state change must update the intended
  consumer without relying on accidental redraws or causing unnecessary repeated work.
  Look for duplicated derived state, contradictory presentation flags, conditional-tree identity
  resets and repeated onAppear/task creation. Tie each concern to an actual state transition;
  a syntax pattern alone is not a defect. Diagnose ownership/identity before adding refresh hacks.
  For an approved incremental UI migration, preserve identity, lifetime and binding ownership at
  actual bridge boundaries and keep the supported deployment behavior; novelty alone is no reason
  to replace the project's existing observation mechanism.
  For search/forms, inspect debounce, local/server filtering, cancellation, stale completion,
  keyboard/focus/submit and validation ownership. Environment dependencies need a real scope,
  not hidden mutable global state. Useful previews use controlled fixtures and relevant loading,
  error/theme/text/locale states; they are not observed interaction or lifecycle evidence.
- UIKit: review view-controller containment and lifecycle, constraint behavior, cell reuse,
  delegate ownership, main-thread UI updates and cleanup. Mixed SwiftUI/UIKit hosting must have
  clear data and dismissal ownership across the bridge.
  Verify actual MainActor ownership and crossings for UI mutation; a main-thread check alone
  does not establish actor isolation. Trace constraint/layout invalidation and update cycles
  for repeated side effects, stale reused state and unintended feedback loops.
  Check balanced child add/remove and appearance forwarding, one-time versus repeated setup,
  safe areas/self-sizing and reuse-bound task/prefetch cancellation. Review stable item identity
  and diff application against stale cell updates. Custom transitions need completion/cancellation
  ownership, rotation and Reduce Motion behavior. Modern registration/diffable APIs are options
  only when they fit the supported project, not mandatory replacements.
- Navigation and deep links: inspect route parsing, validation, restoration, scene/window
  ownership and the target destination's authorization/state preconditions. A route should not
  carry a whole view, database object or secret merely for convenience.
  Check duplicate navigation and app/extension/widget handoff against the same route owner;
  repeated delivery must not silently create a second destination or repeat a side effect.
  Where external entry is affected, trace cold/warm launch, deferred authenticated/unauthenticated
  delivery, modal competition and restoration through the actual navigation owner. Validation
  and current authorization must still hold when a deferred route is finally consumed.
  Keep parsing separate from presentation; check malformed/unknown/versioned routes, feature
  availability, associated-domain fallback and version-aware restoration. Scene-specific route,
  document/session state must not leak across windows. Retire old route forms only under a defined
  compatibility window and evidence, not because a new parser compiles.
- For every screen change, include supported device sizes, iPad/window behavior where relevant,
  keyboard/focus, accessibility, localization and resource ownership in the final review.
  Visual fidelity requires actual supplied design and authorized comparison evidence.

Select UI tests, manual device/Simulator checks and performance observation based on risk and
permission; never start them automatically. Static code review cannot prove visual correctness,
interaction behavior or absence of jank. Report unobserved states and affected consumers.
