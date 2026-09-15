# Review-Ready Validation Report — post-FINAL8 working candidate

Date: **2026-09-15**
Artifact stage: local corrections after FINAL8; no new accepted archive.
Status: **NOT_READY — targeted regressions pass; external-to-Git lifecycle and actual
host instruction delivery remain unverified**.

This is author/self-test evidence, not independent acceptance or proof of complete security. V14 is a corrective follow-up to the V13 candidate and its bounded Astra review: it addresses manual selector/overwrite findings, explicit protection-version admission, knowledge routing/profile wiring, bounded destination admission, and artifact-scoped evidence. The current local candidate also ships regression coverage for post-publication cleanup, intermediate paths, per-file and aggregate accounting, replacement races, iteration failure, slow read and slow validation deadline checkpoints, client-repository destination rejection, AGENTS override precedence, candidate/source profile revalidation and explicit layout mappings. The V13 Astra review remains historical evidence; this candidate still requires final independent review and host adoption evidence.

## Environment

- Python runtime used for the package's original self-test: Python 3.13.5 in the available Linux container.
- Independent candidate execution environment: macOS 26.6.1, arm64, Python 3.9.6; all temporary state and Git fixtures were redirected under the isolated adoption workspace.
- Test sources are parsed by `validate_package.py` using Python 3.9 grammar compatibility.
- Git repositories, real linked worktrees, external state roots and Codex-home fixtures are synthetic temporary resources only.
- No real user Codex configuration or client repository is an installation/test target.
- macOS/Xcode/Swift runtime, Simulator/device/signing tests are **not available in this environment** and are not replaced by Python/static claims.

## Executed regression suite

Command used for the independent candidate run:

```bash
python3 tests/run_all.py --serial
```

Observed result on the corrected working tree:

- total: **196**
- PASS: **191**
- FAIL: **0**
- SKIP: **5**
- runner exit: **0**
- wall clock: not recorded as a release claim

The final serial run used `/Users/Artem/.zenflow/test-tmp-new-task-be0b`, which is
inside `/Users/Artem/.zenflow` and outside the candidate's Git root. The complete suite passed;
five host-dependent cases remain explicitly skipped. The earlier failed attempt used a fixture
root inside the candidate Git worktree and is superseded by this final run.

Current deployment-integration boundary:

- The current host exposes a home-level Git root above the approved `.zenflow` fixture area.
  Production policy correctly rejects destinations inside any detected Git repository; the test
  real CLI integration tests do not mask that root. Existing installer UNIT fixtures locally
  mock the home-level Git result; their PASS is not external deployment evidence.
- Five positive manual/installer integration cases are explicitly `NOT_RUN` in this
  environment. They run when `IOSLIB_TEST_TMP_ROOT` points to an operator-
  approved path outside every Git repository. This is a host limitation, not a production
  exception, and it is not evidence of successful global deployment.
- Unmocked negative CLI coverage, including bounded FIFO handling in both preflights, ran and
  passed. The 191 passing tests are regression evidence, not a claim of universal host discovery.

Post-FINAL8 corrections prepare descriptor and state marker before any publication, preserve the
raw original AGENTS hash, propagate the selected mode/skills path, verify incoming content before
receipt emission and make protection explicitly opt-in. Package reading has a 512 MiB aggregate,
64 MiB per-file, 10,000-entry and cooperative 30-second budget. Receipt readers/writers share a
4 MiB encoded limit and 64 MiB aggregate content budget. Short reads, exact/overflow aggregate
boundaries, expired deadlines and receipts larger than 64 KiB are covered by passing unit tests.
The new unmocked lifecycle test executes the fresh runbook shell blocks, then reference/full,
changed routed payload A→B→A and disable; it is one of the five NOT_RUN cases.

The suite contains all prior V5.3 regression coverage plus deterministic A53-01 upgrade/state-compatibility and bounded-observation fixtures. The corrective candidate adds A54 cleanup-commit-point, final-validation-deadline, per-file-limit and identity-sensitive mutation coverage, plus manual receipt ownership and bounded observer fixtures. The test host uses an isolated `.zenflow` temporary root so protected state I/O is exercised through the same no-follow path policy on macOS.

## A53-01 observed synthetic evidence

- A valid V5.2 schema-2 `closed` session permits a new current writer using the same external state root.
- The old JSON is not rewritten; repeated compatibility checks and subsequent current begin/close cycles preserve it byte-for-byte.
- `protect list` exposes schema 2 history as `legacy-v5.2-closed-archival` with `historical_evidence_only=true` and its existing audit.
- Explicit `protect status --session <legacy-id>` returns `ARCHIVAL_CLOSED`, `historical_evidence_only=true`, and `verification: null`; old verification is not promoted to V5.4 PASS evidence.
- V5.2 `active` and `verified` records remain fail-closed.
- Corrupted baseline hash, foreign repository identity, and unknown session schema remain fail-closed.
- A real `git worktree add` fixture confirms that closed V5.2 history in main/linked worktrees does not consume the current common-dir writer slot, while an unresolved V5.2 writer sharing the common-dir blocks new admission.
- Intermediate `protection`/`sessions` symlink escapes are rejected before legacy records are read.
- A deliberately slow final record read is rejected by the total scan deadline; the scanner cannot return a successful observation after the last expensive operation overruns its envelope.
- A deliberately slow final record validation is rejected after validation, so the cooperative deadline covers validation rather than only file I/O.
- The scanner rejects a record over the explicit 4 MiB per-file limit even when the aggregate budget has room; the aggregate 32 MiB boundary remains separately enforced.
- The replacement fixture publishes a private regular file with identical bytes/size and a different inode; the observed failure is `state file changed before read`, not a permissions failure.

## Legacy registry observation envelope

The V5.4 candidate scans legacy records with streaming `os.scandir` iteration rather than materializing complete directory listings. Admission fails closed when any single scan exceeds 10,000 repository entries, 10,000 session entries, a 4 MiB session file, 32 MiB of aggregate session JSON, or 10 seconds. On the macOS fixture, 10,000 closed records occupied approximately 6.39 MB and scanned in approximately 3.95 seconds. A dedicated bounds fixture observed the expected refusal for each envelope, and a malformed private JSON record returned `ProtectionError`.

## A54 corrective installer evidence

The update commit point is after the new managed trees and metadata, including registry, are
published. If backup cleanup subsequently fails, the candidate raises `SyncCleanupIncomplete`
with `mutation_state=applied_new_version_cleanup_incomplete` and does not attempt destructive
rollback using backups that may already have been deleted. The synthetic multi-target test
verifies that published content, shim and registry remain present and that an unremoved backup
remains discoverable for retry/inspection. A separate race fixture verifies that a target which
appears unmanaged after preflight is preserved and the sync aborts before publication. This is a bounded cleanup-failure contract, not
crash atomicity or automatic recovery.

The corrective transaction journal now records each target and metadata publication before the
potentially failing rename/link/fsync operation. Fresh-install and full-upgrade fixtures inject
an exception after publication and verify that published new targets are removed, existing
content is restored, and an operation that failed before publication is not misreported as an
incomplete rollback. This closes the previously identified post-rename journal gap; it remains
bounded failure-injection evidence, not a claim of crash atomicity across power loss.

Uninstall uses the same pre-publication journal discipline for tree moves and metadata removal.
If a rename/unlink fails after publication, rollback restores only the exact owned bytes; if
backup cleanup has begun, the operation reports `uninstall_applied_cleanup_incomplete` and never
pretends that deleted backups remain recoverable. Three synthetic fixtures cover these boundaries.

The manual deployment contract is now shipped separately from the installer contract. Its
relocatable shim reads a validated JSON selector for the same external payload/state contract used
by the installer, and the runbook requires a read-only preflight, an explicitly active `CODEX_HOME`,
a preserved global AGENTS file, namespaced skills only after host discovery verification, and
fresh-session first-entry evidence. The preflight refuses unknown shim/state/skill targets and does
not overwrite a pre-descriptor or modified shim. The runbook explicitly says that extraction under
a parent directory is not automatic universal adoption. Manual active-layer parity is therefore
claimed only after those checks; transactional ownership/rollback remains an installer-only
convenience.

## V14 corrective evidence

- The manual observer now uses stable no-follow directory handles for parent components and child
  entries, checks regular-file identity before and after reads, and bounds all entries (including
  empty directories), pending directories, depth, aggregate bytes, and cooperative scan time.
  Iteration errors, symlinks, replacement identities and deadline exhaustion refuse the preflight;
  they cannot become an empty successful tree. Addressed fixtures cover these cases on the shipped
  observer itself.
- Manual updates now require a small operator-published `.ioslib-managed.json` receipt. It records
  exact managed paths, SHA-256 values, modes, release/protection identity and the managed AGENTS
  block hash. The preflight re-hashes the receipt before accepting an update; changed descriptor,
  AGENTS block, skill or state marker is refused. A new receipt is emitted only after a new
  descriptor/state/block/skill publication has been independently completed. This is an ownership
  check, not a trust boundary, installer, backup, or automatic rollback service.
- The manual runbook now defines the checked fresh reference, reference→full, update, full→reference
  disable, and A→B→A rollback sequence. The local suite validates receipt emission and refusal
  behavior in synthetic fixtures; the positive external-to-Git deployment cases remain NOT_RUN on
  this host because its home-level Git root encloses the approved `.zenflow` fixture area.
- Manual A→B→A selector fixture launches distinguishable release payloads from the same shim by
  changing only the validated descriptor; a missing descriptor fails before the runtime starts.
- Manual preflight fixture preserves an occupied unknown shim and returns a non-zero refusal before
  any write. An existing unmarked non-empty state root is likewise an explicit migration conflict.
- Installer and manual preflight share bounded active-session admission. An active or verified
  record with a different protection compatibility identity blocks deployment; matching current
  protection state remains usable and closed history is preserved.
- The shipped router defines one common baseline, task-shape routes, bounded cross-domain selection,
  and honest unavailable-subagent behavior. The external profile disables only exact path+hash
  duplicates after explicit source activation; candidate/source drift or ambiguous mappings clear
  all exclusions.

## Upgrade contract

Current sessions remain schema 3. V5.2 schema-2 compatibility is deliberately **read-only and archival-only**. Before upgrading, users must resolve and close all V5.2 active/verified sessions, including linked worktrees sharing the same Git common-dir. The same external state root is retained; deleting sessions or switching state roots is not the recovery mechanism. If an unresolved old writer is present, recovery is explicit through the V5.2 runtime that created the state, followed by retrying the V14 deployment admission. Release identity `.6` intentionally retains protection compatibility `.5`; this deployment correction does not invalidate current protection baselines.

## Existing writer/subprocess contract

V5.4 preserves the V5.3 A52 fixes: one writer per Git common directory, serialized lifecycle transitions, real linked-worktree admission, nonblocking subprocess pipes, real readiness events only, bounded waits, and POSIX owned-process-group cleanup independent of leader liveness.

## Package validation

`validate_package.py` checks manifest/file hashes, shipped test-count consistency, Python 3.9 parsing, no bytecode/symlink package entries, 60 `ioslib-*` skills, 51 knowledge sections, 288 playbooks, the router/profile/capability entrypoints, writer-policy wording, and declared-policy/review-document invariants.

## Final archive evidence

- Archive: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_CORRECTIVE_CANDIDATE_V14_FREEZE_FINAL7.zip`.
- SHA-256: recorded in the external task receipt; it is intentionally not embedded in the ZIP
  because changing the report to include a self-hash would change the archive hash.
- Extracted package validator: `files=1366 skills=60 sections=51 playbooks=288 errors=0`.
- Extracted suite: `REVIEW_READY_TEST_SUMMARY total=173 pass=173 fail=0 skip=0`, exit `0`.
- Candidate-isolated manual smoke: current documented reference sequence — clean and post-activation
  read-only preflight, descriptor/state-marker lifecycle, AGENTS block, relocated shim doctor and
  guard — all PASS. Outputs are retained under `.zenflow/library-adoption-v54/evidence/manual-smoke-current/`.
- Candidate-isolated installer smoke: current copied-runtime reference sequence — dry-run with
  `would_mutate=false`, matching preflight identity, install, generated shim doctor and
  `validate_global_install.py` — all PASS. Outputs are retained under
  `.zenflow/library-adoption-v54/evidence/installer-smoke-current/`.
- Corrected shared-state V11→V14 smoke: V11 `.1` begin → V14 admission refusal (exit `2`) →
  V11 close → V14 admission success → V14 begin/verify/close, all expected results PASS. The
  isolated fixture is retained under `.zenflow/library-adoption-v54/evidence/v11-runtime-compat/`.

## Remaining limitations

- `guard` remains advisory, not an OS execution sandbox.
- Protection is before/after observation/detection, not backup/recovery or a transient-write monitor.
- Writer/lifecycle serialization uses POSIX `flock`; unsupported platforms fail closed for writer-session creation.
- POSIX process-group cleanup does not claim control of descendants that deliberately escape the owned group.
- Common-dir lifecycle locking coordinates library session state, not arbitrary third-party Git processes or source writes.
- V5.2 archival compatibility supports only the explicitly validated schema-2 closed-session shape; unresolved/unknown/foreign state intentionally requires recovery/review.
- No complete ignored-file protection is claimed.
- No macOS/Xcode/Swift compiler/runtime, signing, device, simulator, App Store, or production-repository acceptance was performed here.
- A bounded mutation run intentionally bypassing `expected_identity` produced one failure
  (`ProtectionError not raised`), confirming that the shipped race test is sensitive to the
  identity contract. The bypass was not left in the candidate.
- The bounded V13 independent control-plane review is recorded in the task evidence. Its residual
  integrity handoff limitation is explicitly advisory, not a filesystem security boundary. The
  earlier blind A/B utility run found additional coverage but failed the frozen <=50% input-overhead
  gate, so automatic utility is not demonstrated for that seven-document payload. V14 router/profile
  wiring is deterministic selection evidence, not proof of quality uplift. Provenance/license and
  real activation remain separate gates; this report does not authorize global deployment.
