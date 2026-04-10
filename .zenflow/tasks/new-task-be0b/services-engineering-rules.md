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

## Integration Rule
- Feature services may compose lower-level infrastructure services.
- Repositories map service or persistence DTOs into domain models.
- View models depend on repositories or use cases, not on raw API/database managers unless there is a strong reason.

## Active Service Brief
- Design production-ready, scalable, maintainable, and performant services.
- Follow SOLID everywhere in service and infra code.
- Prefer protocol-driven architecture for routers, clients, interceptors, repositories, managers, and persistence adapters.
- Public APIs should use async/await only. Avoid completion handlers in public service APIs.
- Use initializer-based dependency injection. Avoid singletons and hidden shared state.
- Use typed errors with context. Avoid exposing bare `Error` in service contracts.
- Thread safety is required by design. Use actors where shared mutable async state exists.
- Add DocC-compatible documentation to public types and public functions.

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
