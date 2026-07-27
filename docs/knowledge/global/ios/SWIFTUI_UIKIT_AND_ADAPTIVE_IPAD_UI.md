# SwiftUI, UIKit, And Adaptive iPad UI

## Load When
Use for SwiftUI/UIKit composition, state and navigation ownership, custom layout, text/input, animation, scrolling, multiple windows, iPad adaptation, keyboard/pointer, drag and drop, or framework interoperability.

## UI Runtime Model
SwiftUI view values describe desired output. They are recreated frequently; identity and external state determine continuity. `body` must stay deterministic and side-effect free. UIKit uses long-lived object identity and explicit lifecycle callbacks. Interoperability must translate ownership and lifecycle rather than pretending the two models are identical.

## State Placement
- Local transient presentation state belongs near the view that owns it.
- Feature state belongs to the feature owner, not a reusable leaf component.
- Durable domain state belongs in a persistence/domain owner and is projected into UI state.
- Environment values are for truly ambient dependencies; avoid hidden feature inputs.
- Bindings expose mutation authority. Pass the narrowest binding or explicit intent needed.

## Identity And Collections
List identity must be stable and domain-derived. Indexes, random identifiers, and mutable display text are not durable identity. Identity changes intentionally reset view state; accidental changes cause animation, focus, task, cache, and navigation defects.

## Navigation And Presentation
- Model navigation destination identity separately from loaded detail data.
- Keep one owner for each sheet, popover, alert, or navigation path.
- Handle deep links as validated inputs that resolve through the same navigation contract.
- Avoid mutually competing boolean presentation flags.
- Restoration requires serializable destination state and graceful handling of removed content.

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

## UIKit Interoperability
- `UIViewRepresentable`/`UIViewControllerRepresentable` owns creation and update; coordinators own delegate bridges only when required.
- Keep update methods idempotent and avoid feeding unchanged values back into SwiftUI.
- Define who owns delegates, observations, child controllers, and asynchronous operations.
- Respect UIKit containment and appearance transitions.
- When embedding SwiftUI in UIKit, define hosting-controller lifetime and environment updates explicitly.

## Text, Input, And Focus
- Use semantic text content types, submit behavior, validation timing, and secure-entry rules.
- Preserve marked text and composition for international keyboards.
- Avoid formatting that moves the cursor unexpectedly or rejects intermediate valid input.
- Treat focus as state with restoration and accessibility implications.
- Keyboard shortcuts must not conflict with text editing or system commands.

## Layout And Rendering
- Prefer adaptive constraints and semantic containers over device-name checks.
- Use stable dimensions for controls and repeated content to avoid layout shifts.
- Measure custom layout and geometry dependencies; avoid broad invalidation from frequently changing state.
- Keep expensive parsing, image decoding, and persistence work out of `body` and layout callbacks.
- Animation must have a product purpose and respect Reduce Motion.

## Evidence Matrix
- Representative small and large iPhone Simulators.
- At least one iPad size in portrait, landscape, and split/resized configurations.
- Dynamic Type through accessibility sizes; VoiceOver/focus order where interactive.
- Light/dark, RTL, long localization, keyboard appearance, and content-size transitions.
- Keyboard and pointer workflows where supported.
- Navigation restoration, deep links, scene activation, modal conflicts, and rotation/resizing during work.
- Instruments or SwiftUI diagnostics for rendering/performance claims.

## Primary Sources
- [Apple app design and UI overview](https://developer.apple.com/documentation/technologyoverviews/app-design-and-ui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui)
- [UIKit documentation](https://developer.apple.com/documentation/uikit)

Review after major SwiftUI/UIKit releases or any change to iPad windowing, input, or navigation behavior.
