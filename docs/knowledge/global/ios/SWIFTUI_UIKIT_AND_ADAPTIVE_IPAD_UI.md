# SwiftUI, UIKit, And Adaptive iPad UI

## Load When
Use for SwiftUI/UIKit composition, state and navigation ownership, custom layout, text/input, animation, scrolling, multiple windows, iPad adaptation, keyboard/pointer, drag and drop, or framework interoperability.

## UI Runtime Model
SwiftUI view values describe desired output. They are recreated frequently; identity and external state determine continuity. `body` must stay deterministic and side-effect free. UIKit uses long-lived object identity and explicit lifecycle callbacks. Interoperability must translate ownership and lifecycle rather than pretending the two models are identical.

## State Placement
- Local transient presentation state belongs near the view that owns it.
- Shared transient presentation state belongs at the least common ancestor that genuinely owns
  its lifetime; children receive read-only values or bindings to that same storage according
  to their mutation authority. Derive deterministic values instead of synchronizing mutable copies.
- Feature state belongs to the feature owner, not a reusable leaf component.
- Durable domain state belongs in a persistence/domain owner and is projected into UI state.
- Environment values are for truly ambient dependencies; avoid hidden feature inputs.
- Bindings expose mutation authority. Pass the narrowest binding or explicit intent needed.

## Invalidation And Preview Evidence
Trace Observation dependencies and invalidation for a concrete state transition: the intended
consumer must update without relying on accidental redraws or repeated work. Check duplicated
derived state, contradictory presentation flags, conditional identity resets and repeated
onAppear/task creation. Diagnose ownership and identity before adding refresh hacks; syntax alone
is not a defect. Approved incremental UI migrations preserve identity, lifetime, binding ownership
and supported deployment behavior; novelty alone does not justify replacing observation.

Previews use controlled fixtures and relevant loading/error/light-dark/Dynamic Type/text/locale
states. They are not observed interaction or lifecycle evidence. Keep environment dependencies genuinely scoped.

## Identity And Collections
List identity must be stable, unique within its collection, and domain-derived. Indexes, random identifiers, and mutable display text are not durable identity. Identity changes intentionally reset view state; accidental changes cause animation, focus, task, cache, and navigation defects.

## Ownership And Identity Review
View-value recreation is distinct from ending an identity's lifetime. Inspect expensive or
side-effecting state initialization, observable-reference ownership and optional navigation
state; do not assume a reference shares the ephemeral view value's lifetime. Across a real
ownership boundary, prefer an explicit command to granting a two-way binding. Async completion
must still belong to the current owning identity before publishing.

For an authorized verification plan, distinguish identity-preserving updates from replacement;
cover insertion/deletion/reordering, parent/child edits, navigation away/back and stale completion.
Include restoration or persistence/relaunch only when relevant. A render snapshot does not prove
ownership; update-frequency claims need permitted measured evidence. Actual project deployment,
toolchain and observation model control API choice. These examples grant no verification execution.

## Navigation And Presentation
- Model navigation destination identity separately from loaded detail data.
- Keep one owner for each sheet, popover, alert, or navigation path.
- Handle deep links as validated inputs that resolve through the same navigation contract.
- Avoid mutually competing boolean presentation flags.
- Restoration requires serializable destination state and graceful handling of removed content.

Internal destinations/actions use typed value contracts where appropriate to the existing flow,
carrying identifiers rather than whole views, database objects or secrets. Separate untrusted
route parsing from presentation. Validate malformed/unknown/versioned input, feature availability
and destination authorization/state preconditions; revalidate when deferred delivery is consumed.

One actual navigation owner handles duplicate delivery and app/extension/widget handoff without
repeating a destination or side effect. Trace cold/warm launch, authentication/loading deferral,
modal competition and restoration. Scene-specific route/document/session state must not leak across
windows. Version restoration and retire old route forms only under a defined compatibility window
and evidence. Associated-domain fallback belongs to the server/app contract. These review concerns
do not mandate a coordinator, API replacement or new routing layer.

## iPhone And iPad Core
Production UI must account for:

- compact and regular widths without assuming a fixed device model;
- portrait, landscape, Split View, Stage Manager, and freely resized windows where supported;
- multiple scenes/windows when the product permits them;
- hardware keyboard commands, focus movement, pointer/hover, context menus, and drag and drop when relevant;
- sidebar/detail and multi-column information architecture on larger canvases;
- popover versus sheet behavior, source anchoring, and dismissal;
- safe areas, keyboard avoidance, Dynamic Type, localization expansion, and right-to-left layout.

Do not implement iPad as a scaled-up phone screen when the workflow benefits from simultaneous context, selection persistence, or keyboard-driven actions.

For actually supported Apple-platform consumers, shared code preserves the platform's meaningful
size/resizing, input and windowing interactions instead of forcing a lowest-common-denominator
UI. Establish the product/platform profile first; this criterion does not add visionOS/iPad support,
modernize apps or reopen excluded iPad/physical verification.

## UIKit Interoperability
- `UIViewRepresentable`/`UIViewControllerRepresentable` owns creation and update; coordinators own delegate bridges only when required.
- Keep update methods idempotent and avoid feeding unchanged values back into SwiftUI.
- Define who owns delegates, observations, child controllers, and asynchronous operations.
- Respect UIKit containment and appearance transitions.
- When embedding SwiftUI in UIKit, define hosting-controller lifetime and environment updates explicitly.

## UIKit Lifecycle And Reuse Review
Separate one-time setup, binding/loading, repeated appearance and teardown. Review balanced child
add/remove and appearance forwarding, safe areas and ownership; view hierarchy alone is not the
containment contract. Trace constraint ambiguity/conflicts, self-sizing and layout invalidation
for repeated side effects or feedback loops. For reused cells, keep stable item identity and diff
application consistent with cancellation and stale-result publication guards.

Inspect delegates, closures, timers, observations, display links and child-controller/cell captures
as an ownership graph. Verify actual MainActor ownership/crossings for UI mutation; a main-thread
check is not actor-isolation proof. Custom transitions need completion/cancellation ownership,
rotation and Reduce Motion. Diffable sources, compositional layouts and cell registration are
supported-project options, not required replacements. Approved UIKit/SwiftUI migration defines
hosting/shared-model seams and rollback before widening adoption.

## Text, Input, And Focus
- Use semantic text content types, submit behavior, validation timing, and secure-entry rules.
- Preserve marked text and composition for international keyboards.
- Avoid formatting that moves the cursor unexpectedly or rejects intermediate valid input.
- Treat focus as state with restoration and accessibility implications.
- Keyboard shortcuts must not conflict with text editing or system commands.

Search review names local versus server filtering and debounce ownership where appropriate,
then traces cancellation, stale completion, focus and empty/error states. Form review connects
validation timing and formatting to keyboard, submit, secure entry and accessible errors.

## Layout And Rendering
- Prefer adaptive constraints and semantic containers over device-name checks.
- Use stable dimensions for controls and repeated content to avoid layout shifts.
- Measure custom layout and geometry dependencies; avoid broad invalidation from frequently changing state.
- Keep expensive parsing, image decoding, and persistence work out of `body` and layout callbacks.
- State-driven animations have intentional state/transaction boundaries. All animation has a
  product purpose and respects Reduce Motion.

For layer animations, distinguish model target state from current presentation state; define
transaction/timing, completion/cancellation and offscreen/rasterization costs without assuming
visual completion commits product state. Preserve Reduce Motion behavior.

## Accessible And Localized Interaction Review
Review wrapping/reflow, scalable metrics, truncation and access to clipped content at supported
text-size extremes; use an appropriate scroll fallback where the existing interaction needs it.
Meaning must not rely solely on color, motion, sound or haptics. Review relevant contrast,
transparency and alternative cues without inventing product behavior. Custom components expose
semantic traits/actions, usable hit targets, focus and state announcements, with keyboard/Switch
Control actions relevant to their consumers.

Define semantic element boundaries, localized labels/values/hints, grouping and focus order from
user intent. Prefer existing native controls when their semantics already express the action.
Custom gestures need equivalent accessible actions; inspect dynamic insertion, repeated labels,
decorative content, modal focus and announcements after async/presentation transitions. Critical
inaccessible actions and hidden/unlabeled destructive actions block readiness under the current
quality gate; visual/view-tree order alone is not evidence of actual traversal or action behavior.

Trace the value producer and accessible-label consumer against information actually known to
the user. An internal empty/default value on a hidden or pending surface can mean unknown;
do not announce it as a confirmed negative fact.

Keep user-facing and accessibility text in the project's localization resources or supported
String Catalog workflow. Include plural/grammatical variation and translator context; avoid
English-length or concatenated locale-sensitive assumptions. Use leading/trailing semantics and
inspect mirrored assets and mixed-direction text for supported RTL markets. Date/number display
uses defined Locale/Calendar/TimeZone and supported formatting; parsing and wire contracts remain
separate. Preserve actual translation/resource consumers during an approved change.

For asset/string changes, trace file ownership, target/package bundle lookup and affected app/
extension consumers. Review the complete code/resource/project diff. An approved UI rewrite
preserves required accessibility identifiers/semantics at real consumers; localization-key changes
retain the actual translation workflow. These criteria grant no source/resource rewrite.

## Evidence Matrix
Visual fidelity claims require actual supplied design and authorized comparison evidence. Static
review cannot prove interaction correctness or absence of jank; report unobserved states/consumers.
Select permitted verification by affected flow/states, supported iPhone Simulator OS/class and
relevant locale/RTL/accessibility setting; build/runtime/screenshots remain separate permissions.

- Representative small and large iPhone Simulators.
- Current user exclusions remove all iPad, physical-device and actual VoiceOver checks from plans
  and exit gates: OMITTED_BY_USER, never PASS; preserve historical results and implementation requirements.
- Dynamic Type through supported accessibility sizes and source-level focus/semantic review;
  static layout/hierarchy evidence does not establish actual assistive traversal.
- Light/dark, RTL, long localization, keyboard appearance, and content-size transitions.
- Keyboard and pointer workflows where supported.
- Navigation restoration, deep links, scene activation, modal conflicts, and rotation/resizing during work.
- Instruments or SwiftUI diagnostics for rendering/performance claims.

## Primary Sources
- [Apple: Custom container view controllers](https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller)
- [Apple: Demystify SwiftUI — identity, lifetime and dependencies](https://developer.apple.com/videos/play/wwdc2021/10022/)
- [Apple: Managing user interface state](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
- [Apple app design and UI overview](https://developer.apple.com/documentation/technologyoverviews/app-design-and-ui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui)
- [UIKit documentation](https://developer.apple.com/documentation/uikit)

Review after major SwiftUI/UIKit releases or any change to iPad windowing, input, or navigation behavior.
