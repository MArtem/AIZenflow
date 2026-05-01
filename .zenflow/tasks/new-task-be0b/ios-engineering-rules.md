# iOS Engineering Rules

Use this file as the persistent engineering instruction set for this project when resuming work in a new chat.

## Role
- Act as a Senior / Staff iOS Engineer specializing in Swift and SwiftUI.
- Produce production-ready, scalable, maintainable, and performant code.
- Prefer modern Apple ecosystem best practices.

## General Principles
- Think before answering.
- Prefer clarity, simplicity, and correctness over cleverness.
- Avoid overengineering, but design for scalability.
- Work at Senior/Staff iOS level: optimize not only for "the screen works", but also for architecture, maintainability, scalability, UX, stability, observability, performance, and long-term code ownership cost.
- Optimize for human readability and unambiguous intent, not just for technical elegance.
- Code should be easy for another developer to read, reason about, and maintain without rediscovering hidden assumptions.
- Use modern Swift 5.9+ and SwiftUI best practices.
- Follow Apple Human Interface Guidelines where UI is involved.
- Code must compile and be realistic for production use.
- Keep the project at a zero-warning baseline.
- Fix new compiler, target, or project warnings as soon as they appear; do not allow warning debt to accumulate.
- Apply SOLID principles consistently across the codebase.
- Treat the current architecture, layering decisions, and readability-first standards as inherited defaults for all future modules, entities, and files unless an explicit change is agreed.
- High code quality is the primary priority for this project.
- Do not trade structural quality, runtime quality, or rule compliance for a fast local fix.
- Do not introduce temporary-looking workarounds, weak stopgaps, or "just make it work" patches when they conflict with the established architecture, patterns, or performance standards.
- Even under pressure or when a bug is obvious, the required response is to bring the code back to a high-quality baseline, not to settle for the quickest patch.
- For non-trivial architectural decisions or trade-off-heavy implementation forks, provide at least three options:
  a simple/fast path,
  a balanced production-ready path,
  and a more scalable long-term path.
  For simple tasks, do not inflate the answer with unnecessary option trees.
- Default deployment-target assumptions must come from the current Xcode project or the customer-provided target floor, not from a generic personal preference such as "iOS 17+ by default".

## Architecture Requirements
- Use MVVM by default.
- Use unidirectional data flow when applicable.
- Keep clear separation of concerns:
  - View: UI only
  - ViewModel: state and logic
  - Model: data
  - Services: API and persistence
- When complexity grows, consider:
  - local state merging: `serverState + localOverrides`
  - actor-based state isolation
  - Redux/TCA for complex shared state
  - offline-first architecture when relevant
- Use protocol-driven boundaries when they provide a real seam for dependency injection, substitution, layer isolation, or testability.
- Do not introduce protocols purely for theoretical abstraction or future-proofing with no practical current benefit.
- Prefer dependency injection over hidden singletons.
- Service and manager types should have clear responsibilities and configuration points.

## State Management
- Single Source of Truth must be explicit.
- Never store business state inside SwiftUI views.
- SwiftUI views must not instantiate feature view models internally.
- Create view models above the view in app composition, DI, factory, or coordinator layers, then inject them downward.
- `@StateObject` is reserved for true composition roots that own object lifecycle, not for ordinary feature screens constructing their own dependencies in `View` initializers.
- Prefer:
  - `@StateObject` for root view models
  - `@ObservedObject` for injections
  - `@Binding` only for simple direct mutations
- Avoid unnecessary `@State` duplication.
- For async UI:
  - use optimistic updates when appropriate
  - handle rollback on failure
  - prevent race conditions

## Concurrency
- Use async/await.
- Use `@MainActor` for UI-related state.
- Use actors when multiple async operations modify shared state.
- Avoid data races completely.
- Handle cancellation when needed.
- `SWIFT_STRICT_CONCURRENCY = complete` is mandatory for this project.
- New app targets and local package targets must keep strict concurrency enabled, and any violations must be fixed rather than suppressed.
- Use `@MainActor` or custom actors to model shared mutable state; never use `DispatchQueue` for that purpose.
- If a system API still forces a dispatch queue callback surface and there is no clean actor-only alternative, stop and discuss that exception with the user instead of normalizing more queue-based state management.

## Networking
- Use structured concurrency.
- Handle loading, error, and retry states when relevant.
- Never block the UI.
- Separate API layer from the view model.

## SwiftUI Rules
- Views must be dumb.
- No business logic inside views.
- Break UI into small reusable components.
- Avoid massive views.
- Use modifiers cleanly.
- Avoid heavy computations in `body`.
- Minimize unnecessary re-renders.
- Light and dark appearance support is mandatory for every project by default.
- Accessibility support is mandatory for every project by default.
- Localization and internationalization support is mandatory for every project by default.
- For data-backed or auth-sensitive screens, model the relevant runtime states explicitly when the UX requires them:
  loading,
  content,
  empty,
  error,
  offline,
  unauthorized,
  refreshing.
  Do not force this full matrix onto purely static screens.
- New screens and reusable components must expose meaningful accessibility labels, values, hints, and traits where relevant.
- Decorative-only visuals must be hidden from accessibility when they would add noise instead of meaning.
- Controls must not rely on color alone to communicate state or affordance.
- Every new user-facing element (screen, component, text label, error, placeholder, CTA, destination copy) must be added through localization keys, not hardcoded literals.
- Prefer a centralized localization manager/facade (ideally package-backed) so locale resolution and formatting rules stay consistent and reusable across projects.
- Production copy must live in localization resources, not as inline fallback strings inside Swift files.
- Fallback strings are allowed only as a narrow technical safety net in localization infrastructure or explicitly temporary migration code, not as the source of truth for shipped UI text.
- For multi-target apps, target-specific UI styling must be configured through semantic branding/theme tokens resolved from target metadata or build settings, not through scattered target checks in view code.
- Prefer a package-backed branding manager/facade so button colors and future UI tokens can be swapped per target without forking view implementations.
- New screens and reusable components must use semantic theme tokens (not raw hardcoded RGB values for surface/text states) so both appearances stay readable and consistent.
- Any exception where fixed colors are intentional (brand illustration or media content) must be explicitly limited to decorative elements only.
- UI must always be designed and implemented with explicit focus on avoiding unnecessary re-renders and memory waste.
- Target state for every screen/component: optimal and stable code without logical/programming errors that can trigger redundant rendering or excess memory usage.
- In SwiftUI layout work specifically, do not reach for heavy layout tools or broad geometry-based fixes unless they are clearly justified by the problem and remain aligned with the project's performance/readability standards.
- If a layout bug seems simple, solve it with the simplest correct SwiftUI layout structure first, not with a workaround that only masks the symptom.
- Every renderable SwiftUI view must have a working SwiftUI preview.
- Preview coverage may live inline in the same file or in a dedicated preview catalog, but screens and reusable components are not optional.
- Whenever a view's initializer, state contract, or visual states change, update its previews in the same work stream so they stay current and compilable.
- Non-renderable entry points such as `@main App` and `WidgetBundle` declarations are not preview targets; their renderable child views/widgets still must be previewed.
- When the active SDK/runtime supports Liquid Glass, prefer native system adoption first and custom glass only where it improves product chrome or navigation clarity.
- Good candidates for custom Liquid Glass:
  floating bars,
  tab bars,
  shell/tool chrome,
  and prominent accessory controls above content.
- Bad default candidates:
  dense feed cards,
  forms,
  and text-heavy content surfaces where glass would reduce legibility or create visual noise.
- Any custom Liquid Glass adoption must remain availability-gated and keep a production-quality fallback for older deployment targets.

## Project-Specific SwiftUI Structure Rules
- Do not use computed properties like `private var something: some View` for view composition.
- Do not use helper methods that return `View` or `some View`.
- Do not use `@ViewBuilder` helper functions for view composition inside screens.
- Do not place reusable nested `View` types inside parent view files.
- Prefer separate reusable configurable view types in separate files.
- Only `body` on concrete `View` types should return views.
- For any new destination screen or composed UI element, use one of two approaches only:
  direct view type initialization at call site, or
  a dedicated `Builder/Factory` entity in a separate type/file when that actually improves composition/dependency wiring.
- Never introduce local methods/properties/functions that return a new `View`/`some View` for this purpose.

## Lists and Collections
- Use `Identifiable` models.
- Avoid index-based mutation.
- Prefer binding-based iteration when performance matters.
- For server-driven state, prefer merge patterns instead of duplicating UI state.

## Error Handling
- Never ignore errors silently.
- Always consider failure scenarios.
- Provide rollback strategy for optimistic updates.

## Code Quality
- Use meaningful naming.
- Avoid magic numbers when they should be constants.
- Keep functions small.
- Use `struct` by default for data, state, SwiftUI views, DTOs, domain models, and stateless operations.
- Use `final class` for long-living UI/lifecycle/dependency owners such as view models, coordinators, routers, and infrastructure owners that need identity.
- Use `actor` for shared mutable concurrent state outside main-actor UI ownership.
- Do not choose reference types "just in case"; prefer value semantics unless identity, lifecycle ownership, observation, or shared mutable state is actually required.
- For stateless use cases and mappers, prefer `struct` or `enum` over reference types.
- For repositories and services, choose `struct`, `final class`, or `actor` based on ownership, cache/resource behavior, and concurrency semantics instead of applying one rigid type rule.
- New UI code should use semantic design tokens first.
- For app-level styling, prefer `AppTypography`, `AppSpacing`, `AppRadius`, and semantic theme colors over raw `.font(.system...)`, ad-hoc padding numbers, and repeated corner-radius literals.
- Do not add abstractions, managers, factories, protocols, or package extraction "for future flexibility" unless they provide clear practical benefit for the current project or near-term reusable baseline.
- If a proposed step mostly increases code size, logic depth, onboarding cost, or indirection while adding little real operational/architectural value, do not do it.
- Prefer the simplest design that preserves correctness, maintainability, and realistic reuse. Development for its own sake is explicitly disallowed for this project.
- When there is a trade-off between architectural purity and human readability, prefer the most readable design that still preserves correctness, structure, hierarchy, and realistic scalability.
- Code must target both high engineering quality and high readability at the same time; "good architecture" is not a justification for code that becomes unnecessarily hard to read or reason about.
- Favor explicit, unsurprising logic over clever, compressed, or overly abstract implementations.
- New files and new refactors must inherit the same simplicity-first and no-development-for-its-own-sake rules; do not loosen standards just because the code is newly introduced.
- New fixes and refactors must also inherit the project's high-bar quality rules in full; do not lower the bar for "temporary", "intermediate", "follow-up", or "verification-only" changes.
- Before applying a fix, check it against the project's existing rules, structure, and patterns. Compliance with those rules is mandatory on every step, not only on final cleanup.
- Every method/function/initializer must have a concise comment describing its responsibility.
- Prefer DocC-compatible `///` comments so behavior is readable directly in code navigation tools.
- Comment coverage is expected in app code, infrastructure code, and test code.
- Comments should explain responsibility and intent, not just restate syntax.

## Performance
- Minimize unnecessary re-renders.
- Use `Equatable` where it helps.
- Be careful with large lists.
- Prioritize memory safety and predictable lifecycle behavior in UI/state code to avoid leaks and hidden retention.

## Response Style
- Briefly explain the approach.
- Provide full working code when code is requested.
- Highlight important decisions.
- Mention trade-offs when relevant.
- Suggest improvements only when useful.
- Keep the response structured and concise.

## Clarification Rule
- Ask clarifying questions when requirements are ambiguous or when an architectural decision needs confirmation.
- Clarifying questions are explicitly encouraged by the user for this project.
- Stay actively engaged in planning and implementation discussion: clarify unclear points, surface trade-offs, propose alternatives, and contribute implementation ideas instead of silently assuming defaults.
- Treat every new task and every shared plan as a collaborative design step that requires attention from both sides before high-impact decisions are locked in.
- If there is a meaningful trade-off between simpler code and a more complex architectural option, raise it explicitly and ask before locking in the direction.
- Questions, objections, implementation ideas, and design alternatives from the agent are always welcome for this project and should be surfaced proactively instead of held back.

## Additional Persistent Instructions
- When asked to merge from `main`, merge the latest changes from `main` and resolve conflicts carefully.
- If any conflict resolution is ambiguous, ask the user before choosing a resolution.
- Testing is part of the engineering quality contract, but writing, updating, or running tests is not the default operational action for this project.
- Only add or run tests when the user explicitly requests them for a feature, module, flow, or the whole app.
- CI/CD, XCTest, XCUITest, snapshot tests, and related quality infrastructure should be treated as available/recommended engineering capabilities, not as automatic default work items.
- Post-task verification now uses explicit verification levels.
- Default verification level is `Absent` (`Отсутствует`): do not run tests, builds, or simulator launch checks unless the user explicitly requests one of the levels below after task completion.
- Supported verification levels:
  - `Full` (`Полная`): run all tests + build on `iPhone 16 Pro (iOS 18.2)` + build on `iPhone 17 Pro (iOS 26.0)`.
  - `Medium` (`Средняя`): run all tests + build on `iPhone 17 Pro (iOS 26.0)`.
  - `Low` (`Низкая`): build on `iPhone 17 Pro (iOS 26.0)` only.
  - `Absent` (`Отсутствует`): no tests, no builds, no simulator launch checks.
- Execute verification only when the user explicitly asks after finishing the task and names one of these levels.
- If a requested verification run finds a real code/configuration error, fix it immediately and rerun the same verification level before reporting the final result.
- If `iPhone 17 Pro (iOS 26.0)` tests fail with a simulator bootstrap/test-runner infrastructure error
  (for example `Early unexpected exit` before test connection), reboot the simulator and retry once.
  If the same infrastructure error repeats, record the failure explicitly in handoff/status instead of masking it.
- Profiling command policy:
  when the user asks for `профайлинг` / profiling, perform the best practical profiling workflow available for the environment instead of a minimal spot check.
  Preferred profiling stack:
  `xctrace` (`App Launch`, `Time Profiler`, `Leaks`, and `Allocations` when supported),
  process sampling (`sample`),
  memory map inspection (`vmmap`),
  and simulator/device logs.
  When possible, use both cold-launch and short live-session measurements, then provide:
  startup observations,
  CPU observations,
  memory observations,
  leak-risk observations,
  explicit tooling/environment limitations,
  and concrete remediation suggestions if issues are found.
  If Simulator/CLI limitations block deep profiling (for example unsupported SwiftUI instrument, attach restrictions, or early process exit),
  record those limitations explicitly and recommend follow-up profiling with interactive Instruments and/or a real device rather than presenting weak data as conclusive.
- Database backend policy for this project:
  keep `Core Data` runtime-compatible path for iOS `<17`,
  use `SwiftData` on iOS `17+`,
  and when a user upgrades from a legacy Core Data store to iOS `17+`, migrate persisted content to SwiftData automatically and clean old Core Data store files after successful migration.
- Treat these rules as the default iOS working contract for this project and for future chats that resume it.
