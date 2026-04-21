# Services Engineering Rules

Use this file as the persistent services-layer instruction set for this project when resuming work in a new chat.

## Service Design
- Apply SOLID principles consistently.
- Prefer protocol-first design for services and managers.
- Keep services focused on one responsibility.
- Avoid hidden global state and hardcoded dependencies.
- Prefer dependency injection through the app DI container.

## API Services
- Keep transport concerns separate from feature-specific API managers.
- Support cancellation explicitly.
- Support runtime configuration updates.
- Keep request construction centralized and predictable.
- Surface failures through typed errors when practical.

## Persistence Services
- Keep database access behind a dedicated manager abstraction.
- Repositories should depend on the database manager, not on raw storage primitives directly.
- Keep transaction/save boundaries explicit.
- Avoid leaking persistence-specific models into view models and views.
- For non-relational local data (small DTOs, flags, transient payloads), prefer a dedicated local cache manager behind a protocol contract.
- Favor reusable package-level cache modules (in-memory + file-backed implementations) over feature-specific ad-hoc caching logic.

## Integration Rule
- Feature services may compose lower-level infrastructure services.
- Repositories map service or persistence DTOs into domain models.
- View models depend on repositories or use cases, not on raw API/database managers unless there is a strong reason.
- APNs / push-notification handling should live behind a reusable package-backed manager where practical.
- Keep system callbacks (`UIApplicationDelegate`, `UNUserNotificationCenterDelegate`) in an app bridge/composition layer, while token/state/payload parsing and persistence stay in the reusable package layer.

## Active Service Brief
- Design production-ready, scalable, maintainable, and performant services.
- Follow SOLID everywhere in service and infra code.
- Prefer protocol-driven architecture for routers, clients, interceptors, repositories, managers, and persistence adapters.
- Keep service and infrastructure code easy for humans to read and reason about; do not hide simple behavior behind needless layers.
- Public APIs should use async/await only. Avoid completion handlers in public service APIs.
- Use initializer-based dependency injection. Avoid singletons and hidden shared state.
- Use typed errors with context. Avoid exposing bare `Error` in service contracts.
- Thread safety is required by design. Use actors where shared mutable async state exists.
- Add DocC-compatible documentation to public types and public functions.
- Service and infrastructure code now also follows a stricter local rule for this project: every method/function/initializer should have a concise comment explaining its role, not only public APIs.
- If a service or package design becomes materially harder to understand for the average developer, that added complexity must be justified by clear practical value, not theoretical flexibility.
- All future service, infrastructure, package, and persistence additions inherit these same constraints by default; new modules do not get a looser standard than the existing baseline.

## Database Service Expectations
- Keep every operation behind Swift protocols.
- Support pluggable backends without changing business logic.
- Target support for:
  - SwiftData
  - Core Data
  - SQLite or Realm only if explicitly needed later
- Support:
  - async/await and, where useful, Combine bridges
  - CRUD and batch operations
  - transactions with rollback
  - migrations with explicit versions
  - soft deletes and timestamps
  - background operations
  - in-memory backend for tests
  - pagination strategies when needed
- Prefer a backend-neutral service contract and backend-specific adapters.

## Networking Service Expectations
- Keep endpoint, transport, and interceptor concerns separated.
- Support protocol-driven:
  - Router
  - Client
  - Interceptor
- Support:
  - request configuration
  - cancellation
  - retries with backoff when appropriate
  - logging with configurable verbosity
  - response decoding
  - mock transport for tests and previews
  - offline queuing only when the feature actually requires it
- Treat certificate pinning and auth flows as injectable capabilities, not hardcoded behavior.

## Before Large Infra Work
- If the user requests substantial database or networking infrastructure, ask first:
  - preferred DB backend
  - auth method
  - whether the work must integrate with the existing project structure or may introduce a new module layout
- Also ask whenever there is a real trade-off between simpler code and a more elaborate architecture, or between reuse and readability, instead of deciding silently.
