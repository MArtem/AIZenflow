# Persistence, Data, And CloudKit

## Load When
Use for SwiftData, Core Data, files, UserDefaults, Keychain boundaries, SQLite, schema migration, import/export, backup, shared containers, CloudKit, offline behavior, or sync.

## Choose By Contract
| Need | Default candidate | Main cautions |
|---|---|---|
| Small preferences | UserDefaults | Not a database, secret store, or large-blob store |
| Credentials/keys | Keychain | Lifecycle and accessibility differ from ordinary files |
| Structured object graph | SwiftData/Core Data | Schema, context isolation, migration, fetch cost |
| App-owned documents/media | Files | Atomicity, protection, backup, coordination, cleanup |
| Relational/query control | SQLite-backed layer | Schema/API ownership and migration burden |
| Cross-device Apple sync | CloudKit or supported integration | Account state, conflicts, quotas, partial failure |

Select from access patterns, durability, query needs, data volume, sharing, migration, privacy, backup, and recovery. Framework familiarity is not a sufficient reason.

## Data Ownership
Define canonical data, derived data, caches, temporary files, user-exported data, shared-container data, and remotely authoritative data. Each class needs retention, deletion, backup, protection, migration, and corruption behavior.

## SwiftData And Core Data
- Keep model/context work on its isolation owner.
- Do not pass live managed objects across actors or contexts; pass stable identifiers or immutable snapshots.
- Fetch only required rows/properties, use predicates/sort descriptors, and bound unfiltered queries.
- Understand faulting, relationship loading, uniqueness semantics, delete rules, and save boundaries.
- UI observation is not a substitute for a transaction boundary or merge policy.
- Batch and background operations require explicit merge and user-visible refresh behavior.
- Persistent history and store change observation need token durability and pruning policy.

## Files
- Write to a sibling temporary file, synchronize when durability requires it, then atomically replace.
- Validate imported size, type, content, and filename independently of extension.
- Use app-generated opaque names for untrusted or colliding input.
- Apply the intended file-protection and backup-exclusion policy after creation and replacement.
- Coordinate access when documents can be edited through document providers or multiple processes.
- Clean temporary files on success, failure, cancellation, and recovery startup.

## Migration
Inventory every existing schema and stored representation. Define compatible source versions, mapping/defaults, relationship and uniqueness changes, file moves, interrupted-migration recovery, disk-space requirements, rollback, and user-facing failure.

- Never silently destroy the only copy of user data.
- Copy/backup before an irreversible transform when feasible.
- Make steps idempotent or checkpointed.
- Test old-data fixtures and relaunch after migration.
- Treat CloudKit-backed schema evolution as a separate constraint from local-only migration.

## CloudKit
- Model private, shared, and public database semantics deliberately.
- Handle no account, restricted account, quota, network loss, partial failure, server-record change, zone deletion, and permission changes.
- Use change tokens and subscriptions with durable recovery; a push is a hint, not the data itself.
- Define conflict resolution per field/entity rather than relying on last-writer-wins by accident.
- Do not assume CloudKit provides end-to-end encryption for every data class; verify the current service and field behavior.
- Test development and production schema promotion and container/environment selection.

## Offline And Sync
Represent pending operations durably with stable identifiers, ordering/dependency, attempts, idempotency key, payload version, and terminal/retryable failure. Reconcile remote and local changes through explicit conflict policy. UI must distinguish queued, syncing, synced, conflicted, and failed states when users need that truth.

## Import, Export, And Deletion
- Export from a stable snapshot and record format/schema version.
- Avoid unbounded in-memory archives; stream large content.
- Validate import before mutating canonical state and stage files transactionally.
- Account deletion and delete-all must cover databases, files, shared containers, caches, credentials, pending work, and remote data as promised.
- Interrupted deletion needs startup recovery or an honest partial-failure state.

## Evidence
- Fresh install, upgrade from every supported schema, relaunch, low disk, corruption, cancellation, and interrupted write/migration.
- Large realistic data volume and bounded memory/query behavior.
- File protection, backup policy, import validation, export round-trip, and deletion recovery.
- Multi-context/actor merge, duplicate identity, conflict, offline queue, and account-change scenarios.
- Physical-device locked-state and CloudKit multi-device checks where claimed.

## Primary Sources
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Core Data](https://developer.apple.com/documentation/coredata)
- [CloudKit](https://developer.apple.com/documentation/cloudkit)
- [File system programming](https://developer.apple.com/documentation/foundation/file_system)
