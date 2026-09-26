# Copy-only reference — offline contract walkthrough

Historical paper evaluation from before V5.4 current-tree removal. Statements
below about an active V5.4 source, uncommitted changes or pending removal are
superseded by `v54-retirement-published-status.md`. This is not executed
OFF/ON evidence or proof that the copy-only candidate is ready.

Task `new-task-be0b`; 2026-09-26. This is a static reading of the candidate documents, not an
executed test, live-project adoption, new-chat observation or independent review.

| Synthetic case | Inspected contract result | Evidence limit |
| --- | --- | --- |
| OFF read-only PR review | Local rules, diff and affected consumers still receive full review; reference adds no requirement | No real PR reviewed |
| ON resource added to app and widget targets | Structural route checks membership/bundle consumers; inclusive-UI route applies if user-facing; final review covers code, resources and project file | No target build or runtime asset lookup observed |
| ON Figma screen with inaccessible design node | Design route requires exact node and reports insufficient visual evidence; no pixel-perfect claim | No Figma content or screenshot available |
| Test execution denied | Both modes select needed evidence but do not run tests; missing required evidence limits readiness | No tests run |
| Invalid state record | OFF behavior and user question; `recover` now requires chosen mode and preservation of regular file before replacement | No state I/O implementation or race check executed |
| Two Xcode projects in one Git repository | Each project has a separate proposed key; linked worktrees use common Git directory and same relative project path | Identity hashing and cross-chat behavior unimplemented |
| ON mid-task, then artifact edited after final review | Earlier output must be inspected before a complete ON claim; later edits invalidate the final-review receipt | No real candidate diff exercised |
| P2 finding before handoff | Readiness blocked until correction and whole final-change re-review | No actual finding or independent review performed |

## Findings from the walkthrough

The initial project-key proposal was repository-wide and would have conflated two Xcode projects.
After user choice, the draft identity is per `.xcodeproj` path. The original invalid-record flow
had no safe recovery path; `reference recover` now specifies explicit choice and preservation.
These are document-level corrections only.

The main unresolved gate is activation: no selected startup instruction currently loads this
candidate in a fresh chat, no conversational command implementation reads/writes status, and no
project status record exists. The 813 imported thematic documents and 117 quarantined legacy
documents are not all reviewed routes. Therefore **automatic ON/OFF, cross-chat visibility,
whole-corpus quality and PR readiness remain unverified**. The active `v5.4` source cannot be
removed until its live dependency is retired by a separately approved safe cutover.

Three additional curated routes now cover Swift concurrency, networking and persistence. They
are listed in the router and exact-file manifest but have received only static document checks;
they do not turn the underlying imported playbooks into reviewed payload. Their safety contract
keeps runtime checks permission-bound and excludes auth/Keychain mutation.

A targeted allowlist audit found no positive installer, host-configuration or automatic-command
instruction in the curated routes; mentions of those topics are prohibitions or evidence limits.
The router and matrix were corrected so a cross-domain task checks more than two affected domains
in separate bounded passes, and the three new specialist routes are no longer described as
conditionally unavailable. This is a static text audit, not a proof about every imported file.

Two more curated routes now cover permission-aware test strategy and security/privacy review.
Their skill references used app-root paths rather than paths under the skill directories; the
actual app-root standards were read. The app-specific testing instruction was treated as a
project example, not imported as a universal reference rule. No auth/Keychain mutation was made.

## Fixed paper scenarios — expected differential, not observed execution

**A: Network-backed list with an offline cache and localized empty state.** Facts: one app target,
one endpoint with unknown idempotency contract, a persisted last-success cache, and no permission
to edit or run tests. OFF must inspect local rules, request/response mapping, cache ownership,
locale resources, all affected call sites and the full diff; it must list needed but unrun checks.
ON adds network, data, inclusive-UI and test-strategy passes after the corresponding local
stages, in bounded groups. It should flag any proposed automatic retry of a mutation while
idempotency is unknown, and any claim that an empty-state asset works without target/resource
evidence. It must not create tests, contact the endpoint or claim PR readiness. The added
reference findings are hypothetical until a real fixed code fixture is reviewed; if local rules
already catch both, ON adds no true finding and may only add context cost.

**B: Read-only review of a deep-link handler that logs the incoming URL.** OFF must report
evidence-backed findings under local security rules and must not edit code. ON adds the curated
security/privacy pass: trace untrusted URL validation and whether logs may expose private query
values. It should not declare a leak merely because a URL is logged without inspecting actual
redaction and URL contents; that would be a false positive. It must not touch auth, Keychain or
host settings. Static review cannot establish production log contents without observed data.

**C: Target split affecting app and widget resource lookup.** OFF must review target membership,
bundle ownership and both consumers. ON adds the structural route at design and final diff and
the inclusive-UI route only if the resource is user-facing. If no build/device work is allowed,
both modes leave actual lookup unverified. A reference reviewer that insists on accessibility for
an internal non-UI file would be a false positive.

These examples validate contract wording only. They do not measure true-finding rate, false-
positive rate or token/context cost; those require fixed review fixtures and an independent
comparison before activation.

Next evaluation should use fixed, non-client code/resource fixtures to compare actual OFF and ON
findings, false positives, context cost and evidence honesty. No runtime verification is
authorized by this task.
