# Proposed Countries error-contract correction

Scoped static artifact only; no upstream pre-existing bug claim. The human-approved development contract deliberately changes prior best-effort cache behavior. Exactly two `try? await` sites become `try await`; existing optional-return DB protocol already distinguishes nil from throw. No API, schema, transaction, actor, order or unrelated function change.

| Input/path | Proposed behavior |
| --- | --- |
| Nonforce cache value | returns existing stored value; no web/store |
| Nonforce initial read error, including CancellationError | propagates same error; no web/store |
| Nonforce cache nil | web details→store→read |
| Force | short-circuits initial read; web→store→read |
| Web error | propagates; no store/post-read |
| Store error | propagates; no post-read or fabricated success |
| Post-store read error | propagates same error; not ValueIsMissingError |
| Post-store nil | existing ValueIsMissingError |
| Post-store value | returns DB-stored representation |
| Other functions/public signatures | byte-equivalent |

The producer is async throws returning Optional; consumer optional binding handles genuine absence while thrown failure now escapes the async throws function. `forceReload` short-circuit remains. A cancellation error is no longer silently collapsed into a miss, but no new producer-stop/rollback/late-publication guarantee is introduced. Already committed writes may remain if later read fails. Database actor ownership and transaction implementation untouched.

Relevant current KB error norm says not to collapse distinct technical errors unless intended; engineering change contract supplies exact new local intent. Selected Library data route challenges silent-success/cache-vs-durable semantics, not a mandate to add migration/transaction abstractions. No new knowledge module authored. Library reference is task-only, not actual project ON/pin. No numerical causal KB benefit claim.

Static hash/size validation and `git apply --check` PASS against clean exact source commit9eca97b8…. Original checkout not changed. Parent whole-diff review against frozen10requirements: PASS under revised task contract. Actual consumers/UI/error messaging, target/compiler/SwiftData runtime behavior, tests and data state remain UNKNOWN; no production/readiness/full-callgraph claim. Unchanged source-pair protocol agreement only. Independent review is a second barrier, no replacement for this author review.

No test writing/build/typecheck/runtime/Simulator/network/MCP/source Git mutations or additional agents. iPad/physical/actual VoiceOver OMITTED_BY_USER. Candidate patch and rubric frozen before dispatch; reviewer does not receive author analysis or oracle.
