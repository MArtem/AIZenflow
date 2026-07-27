# iOS Agent Prompt Router

## Purpose
Route work to the correct prompt/skill so reviews are not accidentally narrow.

## Routing Rules
- Feature request → `./docs/agent-prompts/product-requirements-review.md` then relevant domain prompts.
- UI/scroll/performance → `./docs/agent-prompts/ios-ui-state-rendering-review.md` and `./docs/agent-prompts/ios-performance-audit.md`.
- Async/tasks/main-thread → `./docs/agent-prompts/ios-concurrency-review.md`.
- Swift language/runtime/public API/ABI → `./.codex/skills/ios-swift-runtime/SKILL.md`.
- Media/files/cache → `./docs/agent-prompts/ios-memory-cache-media-review.md`.
- API/network → `./docs/agent-prompts/ios-network-resilience-review.md` and `./docs/agent-prompts/ios-api-contract-review.md`.
- Offline/sync/extensions/widgets → `./docs/agent-prompts/ios-offline-sync-review.md` and `./docs/agent-prompts/ios-lifecycle-background-review.md`.
- Security/privacy/permissions → `./docs/agent-prompts/ios-security-privacy-review.md` and `./docs/agent-prompts/ios-input-validation-content-safety-review.md`.
- Identity/OAuth/passkeys/sessions/local authorization → `./.codex/skills/ios-identity-authentication/SKILL.md`.
- Xcode build/linking/binaries/dependency supply chain → `./.codex/skills/ios-build-system/SKILL.md`.
- Capabilities/entitlements/extensions/widgets/Live Activities/App Intents → `./.codex/skills/ios-platform-capabilities/SKILL.md`.
- Swift Testing/XCTest/debugging/LLDB/crash or hang diagnosis → `./.codex/skills/ios-testing-debugging/SKILL.md`.
- Accessibility → `./docs/agent-prompts/ios-accessibility-review.md`.
- Localization → `./docs/agent-prompts/localization-review.md`.
- Release/rollout → `./docs/agent-prompts/ios-release-readiness.md` and `./docs/agent-prompts/feature-flag-rollout-review.md`.
- App Review/privacy manifests/required reasons/compliance → `./.codex/skills/ios-app-store-compliance/SKILL.md`.
- Done/verified/production-ready claim → `./docs/agent-prompts/evidence-based-completion-review.md`.

## Stop Rule
If no route clearly fits, run `./docs/agent-prompts/ios-production-readiness-review.md` and list uncertain domains explicitly.

## Architecture Style Routing
- Use `./docs/agent-prompts/ios-architecture-style-review.md` with `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` when code or requirements mention MVVM, SwiftUI native state, Clean/Layered, Coordinator, Modular, Hexagonal, TCA, Redux/Elm/UDF, ReactorKit, VIP/Clean Swift, VIPER, MVP, RIBs, or MVC migration.
- Do not apply architecture-specific rules that conflict with active project rules; report conflicts and ask for explicit user decision.
