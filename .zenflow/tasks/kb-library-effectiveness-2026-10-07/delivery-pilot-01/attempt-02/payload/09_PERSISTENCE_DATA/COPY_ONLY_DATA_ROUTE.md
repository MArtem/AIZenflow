# Persistence, cache and migration — curated copy-only route

Use after project-local data rules for SwiftData, Core Data, files, key-value state, cache or
offline sync. This route curates `IOS-09-01` through `IOS-09-10`; raw imported material remains
outside the active payload. Identify the actual storage owner, schema/version, data sensitivity,
app-group consumers and supported old states before proposing a mutation.

- Distinguish durable source of truth, derived cache and disposable state. Never present a cache
  reset as a safe substitute for a data migration without proving the cache is rebuildable.
- Preserve readable old data across schema and serialization changes. Trace migration order,
  failure recovery, interrupted writes, rollback and compatibility with every supported old
  version. Destructive reset or deletion requires a separate explicit product decision.
  Check whether retrying an interrupted migration is idempotent and whether a supported
  downgrade can read the resulting data; neither follows from forward migration success.
  A clean-install store is not upgrade evidence. Enumerate supported historical schemas and
  representative old/partial/large stores; distinguish schema changes from business-data
  transformations, identifier remapping, optionality, relationships and delete rules.
  Recommend count/domain-invariant validation and reopen checks before irreversible cleanup.
- Respect context/actor ownership and transaction boundaries. For app, widget and extension
  access, inspect shared-container coordination, merge/conflict policy and observation timing.
  Verify uniqueness constraints and deterministic ordering at actual readers and writers.
  Trace stable identifiers versus live managed objects across storage contexts/actors; resolving
  an identifier still needs the receiving context's ownership and missing/deleted-object behavior.
  Do not introduce a persistence/domain wrapper unless it protects a real changing contract.
- Bound file size, memory use, disk use, background work and cleanup. Define what partial writes,
  corruption and unavailable storage mean to the user; never convert them to silent success.
  Include disk-full/interrupted migration, bounded fetches/batches and large blobs where relevant.
  If corruption investigation may lose evidence through further writes, recommend scoped
  containment to the responsible owner; this route does not itself authorize freezing writes.
  For files, inspect atomic replacement/coordination, intended temporary/cache/document location,
  protection and backup behavior. For caches, check keys, validators/version/TTL, eviction and
  stale-while-revalidate consumers. For preferences, check typed keys, defaults/migration and
  app-group scope; non-sensitive preferences are not a substitute for credential storage.
- Inspect all readers and writers of changed fields, including offline pending operations,
  import/export and backup/restore paths. Do not touch Keychain or credentials under this route.
- For a durable offline mutation, distinguish local, pending, acknowledged, failed and conflicted
  states. Check stable operation identity, duplicate replay after relaunch, ordering/clock
  assumptions, and an explicit per-entity conflict policy. A remote delete needs a durable
  tombstone or pending-deletion record before removing the only local copy; do not turn an
  optimistic UI update into a false server acknowledgment.

Select old-data fixtures, migration/relaunch checks and failure injection based on observed risk
and task permission. If these checks are not authorized or run, mark compatibility and recovery
unverified. Static inspection does not prove a migration is non-destructive.
