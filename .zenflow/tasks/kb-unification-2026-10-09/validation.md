# Preservation and plan validation — 2026-10-09

Scope is the archive and plan only. **No migration, technical corpus acceptance, mode transition, app runtime, fresh evaluation or independent review performed.**

## Checks

- 1,474 archived files compared byte-for-byte with their pinned source Git blobs; all ZIP member CRCs, names, sizes and SHA-256 matched the manifest. Regular files only, no source symlinks. Archive SHA: `9c3e80135ef713a205f6e0481b9c6eecae8836b51df16d9e2ce459d0dfeee76f`.
- Migration ledger exact source path/hash set equals all 1,403 canonical snapshot entries; all remain UNREVIEWED, unique stable row IDs. Project-copy differences deferred explicitly to U1, not assumed identical.
- Local and canonical task file sets and bytes compared. Every relative Markdown link resolves. Combined current plan/handoff under 3,500-word budget; long execution plan is addressed task reference.
- Canonical `generate_manifest.py --check`, `check_documentation_vault.py`, project `check_documentation_boundaries.py`, `check_docs_consistency.py` passed for prepared candidate. Final staged whitespace check applies to new files too; exact-HEAD results retained externally.
- Limited secret-pattern scan of new task files passed. Additionally all 1,474 ZIP entries scanned after decompression for the existing scanner's private-key header, AWS ID and quoted token-assignment patterns: zero matches. This is not an exhaustive secret-inventory claim.

## Semantic review contract

Reviewed preservation vs activation; source-vs-project version separation; inactive archive authority; classification vs semantic review; canonical ownership/mirror boundaries; technical/freshness uncertainty; coverage denominator and mixed-file units; user permissions; absent runtime/token evidence; reading-cost vs real token claims; low-reasoning escalation; partial cutover and saved-mode ambiguity; publication into checked-out main; safe rollback/recovery.

Final plan review found and resolved a gate-order ambiguity: U4–U6 now explicitly validate the candidate KB chain, while actual project cutover remains PENDING_CUTOVER until U8. This avoids requiring U8 completion as a prerequisite for U8. Full contract review repeated after this clarification; no known unresolved P0–P2 in this bounded preservation/planning candidate. No policy, source, runtime, handler, actual Library status or active loading chain changed. Old source documents intentionally retain historical inconsistencies because this is exact preservation; future migration gates prevent their implicit activation. Entry-point preservation is evidence, not a promise to restore old authority.

The complete corpus was hashed, not semantically re-reviewed. All 1,403 ledger rows intentionally remain UNREVIEWED. U7 thresholds are proposed scoped evaluation decision criteria, not observed results or general statistical proof. Read-cost budgets are task design constraints, not claimed savings. Current source and project payloads remain intact. Existing old experiment/holdout restrictions retained.

## Publication boundary

The owned remote main/development refs were queried before publication: AIZenflow `82294ae7fc4e3946e5ea957f885844e79284d04e`, Documentation `dba11900be2e694c77ad392759280dd56fc86a6e`. Exact committed range review, immediate remote revalidation, pushes and verified resulting refs must be recorded outside tracked candidate files. A receipt cannot be made current by changing this file after commit.

## Residual limitations

No demonstrated quality improvement or token saving; neither is needed to call the snapshot intact or the plan prepared. Migration/cutover awaits user instruction to start. Fresh evaluation, new agents/chats/MCP and executable mode transitions need concrete current authority. Independent review unavailable under current grants. A fresh implementation chat is recommended at this phase boundary; the ready handoff prompt is in the detailed plan.
