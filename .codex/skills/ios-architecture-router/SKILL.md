---
name: ios-architecture-router
description: Use this skill for iOS architecture style detection, architecture review routing, or migration planning across MVVM, SwiftUI Native State, Clean/Layered, Coordinator, Modular, Hexagonal, TCA, Redux/Elm/UDF, ReactorKit, VIP/Clean Swift, VIPER, MVP, RIBs, and MVC migration. Trigger when the user asks to review architecture, compare architecture styles, adopt rules from architecture playbooks, or decide which architecture-specific review gate applies.
---

# iOS Architecture Router

## Workflow
1. Read active project rules before applying any architecture-specific guidance.
2. Identify the architecture style already present in the code or requested by the user.
3. Apply `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` and only the matching review gate.
4. Reject external rules that conflict with current project rules, especially speculative layers, decorative protocols/factories/adapters/use cases, and generic `send(_:)` as default MVVM API.
5. If the requested change would alter long-lived architecture, require user approval and an ADR/rationale before implementation.

## Output
- Detected architecture style and evidence.
- Applicable gate from `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`.
- Conflicts with active project rules.
- Findings prioritized as must do now / should do next / later / do not do.
- Verification needs.

## References
- `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`
- `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`
- `./docs/IOS_MVVM_INTENT_API_STANDARD.md`
- `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`
- `./docs/MODULAR_ARCHITECTURE_STANDARD.md`
