# 09 — Persistence and Migrations

## Principle

A schema change is not just a source-code change; it is an upgrade of existing user data on devices already in the wild.

## MUST

- identify the current persisted schema/version;
- preserve upgrade paths from all versions the product promises to support;
- define rollback/recovery behavior;
- test migration using a real old-version store/fixture when migration is non-trivial;
- never delete the store automatically because migration/opening failed;
- handle persistence save failures when data correctness matters.

## SwiftData

For versioned SwiftData models, prefer explicit `VersionedSchema` and `SchemaMigrationPlan` once production data exists and schema evolution matters.

Use lightweight migration only when schema changes are supported without custom data transformation.

Use custom migration when existing data must be transformed, normalized, de-duplicated, or prepared for new constraints.

## Unique constraints

Before adding uniqueness to existing data:

- scan/migrate duplicates;
- define collision policy;
- avoid making a property nonoptional/unique in the same step if old data cannot satisfy it safely.

Staged migrations are preferred when constraints require backfilling.

## Other persistence technologies

Core Data/SQLite/Realm/files/Keychain each have technology-specific behavior, but the same rules apply: version, preserve, verify, fail safely.

## Transactions

Multi-step mutations that must remain consistent SHOULD be transactional where the storage system supports it.

## Sensitive data

Choose storage based on sensitivity. Credentials/tokens usually belong in Keychain, not plain UserDefaults/files.

## Migration test matrix

R4 migration should include:

- oldest supported -> current;
- previous release -> current;
- empty database -> current;
- representative large dataset when performance matters;
- duplicate/corrupt edge cases relevant to the migration;
- interruption/failure behavior when realistically testable.
