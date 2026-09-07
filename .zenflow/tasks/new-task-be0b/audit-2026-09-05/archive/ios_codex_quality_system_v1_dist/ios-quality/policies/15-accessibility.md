# 15 — Accessibility

Accessibility is product correctness, not polish.

## MUST for user-facing UI changes

- provide meaningful labels/values/hints for interactive/non-text elements where automatic semantics are insufficient;
- ensure tappable controls have appropriate semantics and usable hit areas;
- support Dynamic Type unless a documented product constraint prevents it;
- avoid clipped/overlapping text at larger accessibility sizes;
- avoid color as the only carrier of meaning;
- maintain sufficient contrast and understandable focus order;
- respect Reduce Motion for significant custom motion;
- ensure custom controls expose role/state/action appropriately.

## SwiftUI

Prefer semantic native controls (`Button`, `Toggle`, `TextField`, `Label`) over gesture-only custom constructs when behavior is equivalent. Native controls carry accessibility/interaction semantics automatically.

## UIKit

Custom views/controls must expose accessibility properties/traits/actions and update them when state changes.

## Verification

R2+ significant UI changes SHOULD run an Accessibility Inspector audit on affected screens when feasible. R3/R4 critical journeys SHOULD include manual VoiceOver/Dynamic Type checks or UI automation evidence where project infrastructure supports it.

Report what was actually tested; do not claim accessibility compliance from code review alone.
