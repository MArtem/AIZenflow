# Saved Prompt: `/services`

## Content
```text
## SERVICE 1 — DATABASE SERVICE (Core Data / SwiftData / SQLite / Realm)

### Requirements
- Protocol-driven: every operation behind a Swift protocol
- Support pluggable backends: Core Data, SwiftData, SQLite (GRDB), Realm
  — switchable via config without changing business logic
- Full async/await + Combine support
- CRUD + batch operations
- Transactions with rollback
- Migrations (versioned, up/down)
- Soft deletes + timestamps (createdAt, updatedAt) out of the box
- Background context operations (no UI freezes)
- In-memory backend for tests
- Pagination (cursor-based and offset-based)
- Error handling: typed errors with context, no bare Error

### Deliverables
- Protocol definitions
- Implementations for Core Data and SwiftData
- Migration manager
- Unit tests with in-memory backend

---

## SERVICE 2 — NETWORKING SERVICE (URLSession-based)

### Requirements
- Protocol-driven: Router, Client, Interceptor all behind protocols
- Endpoint definition via enum (method, path, headers, body, query params)
- Middleware/interceptor pipeline:
  - Auth (Bearer token, API Key, OAuth2 refresh)
  - Retry with exponential backoff + jitter
  - Logging (request/response, configurable verbosity)
  - Certificate pinning
- Response decoding: Codable + custom decoders
- Multipart upload + download with progress
- Request cancellation via Task / CancellationToken
- Offline queue: enqueue requests when no connection, replay on reconnect
- Mock backend for UI previews and tests
- Error handling: typed NetworkError (noConnection, timeout, httpError,
  decodingFailed, cancelled)

### Deliverables
- Protocol definitions
- URLSession implementation
- Each interceptor as a separate injectable component
- Mock client implementation
- Unit tests for interceptors and decoding

---

## CONSTRAINTS
- Swift 5.9+, iOS 16+ minimum deployment target
- No third-party dependencies unless absolutely necessary
  (if used — justify why)
- Every public type and function must have DocC-compatible documentation
- Full async/await (no completion handlers in public API)
- Thread-safe by design (actors where appropriate)
- Dependency injection via initializer (no singletons, no shared instances)

## OUTPUT ORDER
1. Protocols and types for both services
2. Database service implementation
3. Networking service implementation
4. Tests for both
5. Usage example (ViewModel using both services together)

## BEFORE STARTING — ask me:
1. Preferred DB backend (Core Data / SwiftData / SQLite / Realm)?
2. Auth method (Bearer / API Key / OAuth2)?
3. Any existing project structure to integrate into?
```

## Completeness
Status: complete exact export from Zenflow/Codex App `saved_prompts` table.

## Export Metadata
- Slug: `/services`
- Exported from local read-only DB table: `saved_prompts`
- App-updated timestamp: `2026-04-06 19:50:58.332`


## Active Worktree Rule Note
This is the exact Codex App saved prompt body. The active project-specific evolved rule file for this task is:

- `./.zenflow/tasks/new-task-be0b/services-engineering-rules.md`

Use the active task rule file as authoritative for current source-app services/package work; keep this file as the preserved Codex App saved-prompt snapshot.
