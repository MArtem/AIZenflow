# Persistence subtree rules
- Schema/migration changes are R2+ by default.
- Identify production store and migration path before model edits.
- Never delete/rename persisted fields without compatibility analysis.
- Tests must include representative old-store migration and failure/rollback behavior.
