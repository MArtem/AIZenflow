# Handoff — FINAL7 corrective work in small Luna blocks

Task: new-task-be0b. Date: 2026-09-15. Mode: эконом.
User decision: Luna Xhigh implements; Astra performs small scoped reviews to conserve limits.
Current executable source: .zenflow/tasks/new-task-be0b/plan.md.
Current next action: independent acceptance of the canonical-repository runtime exception and
final publication decision. The unmocked reference installer lifecycle now passes in
`AIZenflowDocumentation/.codex-runtime/ios-engineering` from its versioned source payload.
The earlier claim that only external checks remained was withdrawn by Astra's FINAL8 findings.
Working changes fix manual publication order/raw SHA/mode, receipt publication verification,
resource bounds and protection opt-in. Evidence: 30-post-final8-correction.md.
194 distinct tests: 189 PASS, 5 SKIP (stable serial run with an external-to-candidate-Git
fixture root inside `.zenflow`; parallel diagnostic showed one non-reproducible fixture race).
Canonical source/runtime were activated in the approved repository exception during this turn;
candidate/task publication and independent review remain separate finalization decisions.
Canonical publication receipt: `AIZenflowDocumentation` commit
`c3d61a98d6fdad9e0230c0c49edb52a13d2fbfae` pushed and confirmed at `origin/main`.
Block A was RETURNED by Astra and has now been corrected by Luna; independent re-review remains
useful but is not a user stop. Later user authority permits continued
blocks and commit/push; obsolete per-block stop/publication restrictions below are superseded.
The final correction also makes the manual AGENTS snapshot path fail closed unless an existing
regular file is an exact byte match; it never overwrites an unrelated snapshot.
The canonical-repository exception is explicit and narrow: exact origin/root plus
`.codex-runtime/ios-engineering`; normal client-repository rejection remains active.

## Startup and evidence

Read canonical bootstrap and current Level 0 once, then only documents needed for each active block.
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Final packaging pass — completed

The candidate README is now a self-contained Codex handoff: it covers reference/full installer
deployment, manual connection, canonical-repository exception, process-level `CODEX_HOME`, exact
duplicate handling, runtime/protection limits, update/uninstall/rollback, troubleshooting,
evidence, and internal redistribution limits. Candidate and canonical V5.4 README plus
`PACKAGE_FILE_MANIFEST.json` are byte-identical. Candidate validator: 1366 files, 60 skills, 51
sections, 288 playbooks, 0 errors. A valid serial suite from a fixture root outside all Git roots
reports 194 total, 189 pass, 0 fail, 5 skip.

Completed in this pass: final archive created from the canonical versioned source only; archive
contents contain no `.git`, `.codex-runtime`, `__MACOSX`, `__pycache__`, or `.pyc`; extracted bytes
match the canonical source (`1366` files). Archive:
`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_PORTABLE.zip`
SHA-256: `57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27`.

Canonical docs commit/push: `03aafeb304fe6be4c54efa8a7930bcc2d95e5ab1` on
`AIZenflowDocumentation/main`, confirmed at `origin/main`. Task-repository commit/push:
`9d835401a` on `AIZenflow/codex/audit-remediation-luna`, confirmed at its origin branch.
The product source and task recovery state are preserved; generated historical evidence remains
local and was intentionally not mixed into the portable product commit.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Candidate:
.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY
Findings: .zenflow/library-adoption-v54/evidence/27-astra-final7-review-and-action-plan.md.
Evidence 27 remains the finding record/common-host proposal; its bulk execution order is superseded.
Artifact FINAL7 SHA: fe3fa9c1800ba0902b48918df9543f16eb6e75d189122f63d168d53a08cd4b44.
1366 archive files independently match candidate at review. Luna 173/173 and validator PASS are
historical FINAL7 evidence. Astra reviewed FINAL7 WITH FINDINGS F7-01..06; status NOT_READY.
Universal existing/new project delivery is not yet established; this is not merely an external-review gate.

## Current block and boundaries

A changes installer/manual destination rejection and effective override handling, plus relevant tests.
Remove configuration/source-repo bypasses. Test actual failure and permitted external success.
Do not touch profile, lifecycle, scanners, host configuration or client code in A.
Existing test-edit authority covers candidate regressions. Fixtures/output remain under .zenflow.
Use external-to-Git synthetic deployment targets; do not weaken production checks for fixtures.
No new ZIP, full suite, whole-library reread, app commit/push or global sync between blocks.
No secrets/auth/history/session access. Exact external host read/write authority remains separate.
Do not ask again for already granted operations.

## Review cycle

Luna finishes one block and records at most 15 lines: paths, invariant/results/exit codes,
review input identity and limitations. Astra reviews the complete small delta and consumers;
ACCEPTED or RETURNED on the same block. Next block begins on continuation with Luna.
No new multi-stage plan for each returned finding. Accepted work reopens only on concrete evidence.
Common-host preparation B follows A; actual common-host activation can follow accepted B if
authorized, independently of candidate runtime corrections.

## Planning-only changes in this turn

Replaced contradictory active plan/handoff with the small-block execution contract.
Prior versions preserved in archive/pre-small-blocks-2026-09-14-plan.md and matching handoff.md.
Candidate changed only in block A; the FINAL7 archive remains a frozen historical input and is
stale relative to the current candidate by design. Host configuration and Git refs unchanged.

## Block A result — corrected after Astra RETURNED

Changed candidate installer/manual preflight and targeted tests. Mutable destinations under any
detected Git root are rejected; source/default/environment paths no longer bypass the check.
Effective unsafe AGENTS.override remains the selected target and fails before writes.
AdditionalAcceptanceTests: 22/22 PASS (exit 0); AST/trailing-whitespace checks PASS;
Correction: installer regular-file reads use `O_NONBLOCK` before `fstat`, so FIFO overrides cannot
hang. Shipped tests use an operator-selected `IOSLIB_TEST_TMP_ROOT`, remove the global Git-root
monkeypatch, and run real CLI tests whenever an external-to-Git fixture root is available.
Current host has a home-level Git root above `.zenflow`, so four positive deployment tests are
explicitly `NOT_RUN`; unmocked negative tests ran. Final correction run before E/F completion:
180 total, 176 pass,
0 fail, 4 skip; package validator 0 errors. This is not proof of host deployment.
Local commit: 74d651417b7b48b77a092c487a0f2c2fb241c442 imports all 1366 candidate files.
Push was rejected by automatic approval review; no successful push is recorded.
Astra reproduced FIFO override: real installer times out after 3 seconds, manual exits 2;
no deployment targets created. Cause: installer read_regular_snapshot opens FIFO before fstat.
The FIFO and shipped-test portability/global-monkeypatch findings are corrected locally.
Existing Git rejection and oversized-override selection changes are correct; B–G remain open.

## Block B result — common-host preparation

Evidence 22 now contains the task-type-neutral common host block and corrects the non-iOS outcome.
Evidence 28 contains the concrete local canonical diff proposal for bootstrap, new-project template,
AGENTS template and bootstrap checker. No `/Users/Artem/.codex` file or canonical documentation
file was read or changed; exact host authority is still a separate acceptance boundary.

## Blocks C–F result — locally implemented

C strict profile/runtime wiring, D protection opt-in wording, F1 bounded knowledge observer,
F2 bounded manual observer and E1 manual ownership receipt are implemented in the candidate.
E2 runbook specifies fresh reference, full migration, update, disable and A→B→A rollback.
Final serial suite: 188 total, 184 pass, 0 fail, 4 NOT_RUN; package validator: 0 errors.
The four skips are positive deployment fixtures unavailable because the current host Git root
encloses the approved `.zenflow` area. No real CODEX_HOME/canonical host files were changed.
Remaining evidence is independent B–F review, actual external-to-Git lifecycle/first-entry
acceptance, and final G release/pilot review. Context transfer:
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
