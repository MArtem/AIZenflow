# Review-Ready Validation Report — Astra follow-up working candidate

Date: **2026-09-17**
Artifact stage: Astra external-lifecycle correction; no accepted release.
Status: **NOT_READY — isolated lifecycle verified; automatic host instruction application
not demonstrated in three fresh Desktop tasks**.

This is author/self-test evidence, not independent acceptance or proof of complete security. V14 is a corrective follow-up to the V13 candidate and its bounded Astra review: it addresses manual selector/overwrite findings, explicit protection-version admission, knowledge routing/profile wiring, bounded destination admission, and artifact-scoped evidence. The current local candidate also ships regression coverage for post-publication cleanup, intermediate paths, per-file and aggregate accounting, replacement races, iteration failure, slow read and slow validation deadline checkpoints, client-repository destination rejection, AGENTS override precedence, candidate/source profile revalidation and explicit layout mappings. This follow-up additionally fixes positional manual-block selection and makes the historical archive input explicit through `IOSLIB_LEGACY_ARCHIVE`. The V13 review remains historical evidence; this candidate still requires final independent review and host adoption evidence.

## Environment

- Python runtime used for the package's original self-test: Python 3.13.5 in the available Linux container.
- Independent candidate execution environment: macOS 26.6.1, arm64, Python 3.9.6; all temporary state and Git fixtures were redirected under the isolated adoption workspace.
- Test sources are parsed by `validate_package.py` using Python 3.9 grammar compatibility.
- Git repositories, real linked worktrees, external state roots and Codex-home fixtures are synthetic temporary resources only.
- No real user Codex configuration or client repository is an installation/test target.
- Xcode/Swift app runtime, Simulator/device/signing tests were **not authorized in this block** and are not replaced by Python/static claims.

## Executed regression suite

The latest split-host author-verification command stays inside the approved `.zenflow` area:

```bash
PYTHONDONTWRITEBYTECODE=1 \
IOSLIB_TEST_TMP_ROOT=/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/test-tmp \
IOSLIB_LEGACY_ARCHIVE=/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_PORTABLE.zip \
  python3 -B tests/run_all.py --serial
```

- total: **215**
- PASS: **209**
- FAIL: **0**
- SKIP: **6**
- runner exit: **0**

The sixteen split-host cases cover exact empty-file/mode roundtrip, active override precedence,
managed-block tamper refusal, receipt-publication rollback, modified-runtime refusal, damaged-runtime
disconnect recovery, uninstall interlock, template-refresh disconnect, racing-edit preservation,
post-exchange durability rollback, new-file post-publication rollback, post-removal durability
rollback, post-exchange cleanup rollback, recovery-snapshot failure reporting, a second edit during
rollback and later active-override drift.
Fixtures use separate synthetic runtime and host homes; no real Codex setting is an implementation target.

The six current skips are the two installer/manual dry-run cases, three documented/manual
preflight cases and the real historical release roundtrip that require an external-to-Git root.
No implementation failure was hidden as a skip. The preceding 199-test lifecycle acceptance used
the one-time external fixture and executed these six cases successfully. That directory was
absent before creation, outside detected Git roots, and created with
mode 0700. After the successful suite its contents were already cleaned by the tests; the same
directory inode was verified, the empty root removed with rmdir, and absence confirmed. This report
is not permission to recreate it. On other hosts choose a separately authorized external-to-Git
root; omitted historical archive or Git-enclosed fixtures remain explicit NOT_RUN.

The preceding inside-Git run had 193 PASS / 6 SKIP. The first external run exposed five failing
assertions across three manual tests: missing isolated skills paths, wrong original-snapshot
mode and empty skill directories blocking reconnect. The targeted recheck passed the two
preflight tests and exposed two reconnect subtest failures from activation-owned newlines left on disable.
These were fixed in the harness and manual procedure, without relaxing production admission:
explicit fixture skills paths, recorded snapshot mode, rmdir only for empty directories derived
from verified owned files, and byte-exact restoration of the verified AGENTS composition.
Original failure logs and corrected run evidence remain in the task receipt.

The manual lifecycle now exercises fresh reference/full, absent/existing user AGENTS (0640),
reference→full/update, changed payload A→B→A, modification refusal, disable, preserved history
and reconnect in all four branches. Its shell blocks are selected uniquely and syntax-checked
independently. The real historical .6→.7→.6 CLI sequence checks selected release identity,
old coordinator refusal, state sentinel, user AGENTS mode and old payload preservation.
Historical archive SHA:
`57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27`.

The six formerly skipped integration cases execute with real production Git checks. Existing
mocked unit fixtures remain unit evidence. Passing these isolated fixtures does not prove
delivery to the active Codex Desktop process or independently establish app production readiness.

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
  behavior in synthetic fixtures; the formerly skipped positive external-to-Git cases also passed
  in the separately authorized one-time fixture area described above.
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

- Archive: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_ASTRA_LIFECYCLE_20260916.zip`.
- SHA-256: recorded in the external task receipt; it is intentionally not embedded in the ZIP
  because changing the report to include a self-hash would change the archive hash.
- Package validator: `files=1367 skills=60 sections=51 playbooks=288 errors=0`.
- Candidate suite: `REVIEW_READY_TEST_SUMMARY total=215 pass=209 fail=0 skip=6`, exit `0`;
  all sixteen split-host tests executed and passed. Separate prior external evidence remains
  `199/199/0/0` for the unchanged external-only lifecycle paths.
- Archive/candidate equality is checked against every packaged file; details and SHA live in the
  external task receipt. The smoke evidence below is retained historical evidence, not a new
  manual/installer execution of this harness correction.
- Promotion into canonical source and the active source-in-place installation is deferred:
  the current user instruction forbids changing real Codex settings. The tested candidate is
  separate; no claim is made that the active runtime selects these new bytes.
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
