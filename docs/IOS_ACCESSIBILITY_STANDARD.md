# iOS Accessibility Standard

## Purpose
Accessibility gate for production iOS UI.

Record supported iPhone/iPad/window, VoiceOver, Dynamic Type, RTL, keyboard/pointer, contrast and
Reduce Motion rows in `./docs/IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md`. A screenshot is supporting
visual evidence only; it does not prove assistive-technology or device behavior.

## Required Checks
- VoiceOver labels, traits, hints, and grouping.
- Logical focus order.
- Dynamic Type support and layout resilience.
- Sufficient contrast in light/dark modes.
- Tap targets meet platform guidance.
- Reduce Motion respected for non-essential animation.
- Important state changes are announced when needed.
- Forms expose validation errors accessibly.
- Media has accessible labels/metadata where product requires it.

## Blocking Issues
P1 by default:
- critical action inaccessible to VoiceOver
- unreadable layout under larger text
- hidden/unlabeled destructive action
- input/error state not exposed to assistive tech
