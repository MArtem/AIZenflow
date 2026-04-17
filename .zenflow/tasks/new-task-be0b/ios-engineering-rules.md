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
- Use modern Swift 5.9+ and SwiftUI best practices.
- Follow Apple Human Interface Guidelines where UI is involved.
- Code must compile and be realistic for production use.
- Apply SOLID principles consistently across the codebase.

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
- Prefer protocol-driven boundaries between services, repositories, managers, and feature layers.
- Prefer dependency injection over hidden singletons.
- Service and manager types should have clear responsibilities and configuration points.

## State Management
- Single Source of Truth must be explicit.
- Never store business state inside SwiftUI views.
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
- New screens and reusable components must use semantic theme tokens (not raw hardcoded RGB values for surface/text states) so both appearances stay readable and consistent.
- Any exception where fixed colors are intentional (brand illustration or media content) must be explicitly limited to decorative elements only.

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
- Add comments only where logic is non-obvious.

## Performance
- Minimize unnecessary re-renders.
- Use `Equatable` where it helps.
- Be careful with large lists.

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

## Additional Persistent Instructions
- When asked to merge from `main`, merge the latest changes from `main` and resolve conflicts carefully.
- If any conflict resolution is ambiguous, ask the user before choosing a resolution.
- Verification matrix for app-level checks must include both simulator targets:
  `iPhone 16 Pro (iOS 18.2)` and `iPhone 17 Pro (iOS 26.0)`.
- For app verification, run `xcodebuild ... build` and `xcodebuild ... test` on both targets.
- If `iPhone 17 Pro (iOS 26.0)` tests fail with a simulator bootstrap/test-runner infrastructure error
  (for example `Early unexpected exit` before test connection), reboot the simulator and retry once.
  If the same infrastructure error repeats, record the failure explicitly in handoff/status instead of masking it.
- Database backend policy for this project:
  keep `Core Data` runtime-compatible path for iOS `<17`,
  use `SwiftData` on iOS `17+`,
  and when a user upgrades from a legacy Core Data store to iOS `17+`, migrate persisted content to SwiftData automatically and clean old Core Data store files after successful migration.
- Treat these rules as the default iOS working contract for this project and for future chats that resume it.
