# Astra review FINAL7 and bounded adoption plan

> Execution order superseded by the user-approved small-block process in
> `.zenflow/tasks/new-task-be0b/plan.md`. Begin with block A only, then scoped Astra review.
> Findings and common-host proposal below remain valid; do not execute the old bulk plan.

Date: 2026-09-14. Requested by the user: independent review, feedback and detailed next plan.
Model: GPT-6 Astra. Operating mode: эконом. This document does not authorize host changes.

## Verdict and evidence boundary

NOT_READY for universal deployment. The candidate has useful improvements, but the statement
that only external gates remain is incorrect. Local deployment/profile defects remain.
This review completes independent review of FINAL7 with findings; another review of unchanged
FINAL7 is unnecessary. Re-review only the corrective delta and affected consumers after fixes.

Reviewed ZIP: `dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_CORRECTIVE_CANDIDATE_V14_FREEZE_FINAL7.zip`.
SHA-256: `fe3fa9c1800ba0902b48918df9543f16eb6e75d189122f63d168d53a08cd4b44`.
Astra independently compared all 1366 archived regular files with the candidate: zero mismatches.
Luna's recorded 173/173 suite and validator results are reused, not claimed as Astra reruns.
Review scope: changed deployment/control-plane code, its callers, manual runbook, profile,
global entry and adoption claims. This is not a full semantic audit of 1275 Markdown assets.

Read-only probes loaded candidate helpers with Python `-B` and used existing isolated fixture
paths or in-memory substituted inputs. They created no installation targets, changed no candidate
code/tests, and accessed no real Codex home. No build, device, Git mutation or full-suite rerun.

## Findings

### F7-01 — P1: universal first entry remains undelivered; preparation claim is false

`evidence/22-host-entrypoint-preview.md`, Proposed managed entrypoint contract, still begins
"For an iOS/Swift task". Its non-iOS acceptance row says the entry is ignored. The canonical
`reusable/GLOBAL_RULES_BOOTSTRAP.md` still requires adoption in every repository root.
Neither is the requested all-project host entry. Candidate `AGENTS.global.block.md` correctly
scopes the NEW iOS library to Apple tasks, but cannot substitute for delivery of EXISTING common
knowledge to all projects. Evidence 26's new "Local proposal preparation is complete" claim is
unsupported. Existing markers help adopted projects; future/imported project coverage remains
unproven. Repair the common host proposal and bootstrap/template/checker agreement first.

### F7-02 — P1: client-repository destination rejection has configuration bypasses

`install_global.py:258-270` and `MANUAL_SHIM/bin/manual_preflight.py:164-173` exempt the source
Git root and paths under environment `CODEX_HOME`. The location of the release does not identify
its containing repository as a non-client repository. A caller-selected CODEX_HOME is a target,
not authority to bypass the no-client-install invariant.

Read-only reproduction: targets under existing isolated `.../corrected-v11-to-v14-_cj28c3o/repo`
are rejected normally; with in-memory CODEX_HOME set to that repo's proposed home both helpers
return `[]` collisions. A proposed destination in the actual worktree containing the candidate
also returns `[]`. Targets remained absent. Remove both broad exemptions; fixtures must not
weaken production policy to make tests pass.

Additional effective-target defect: `install_global.py:197` ignores a regular override larger
than TEXT_LIMIT and falls back to AGENTS.md; manual preflight instead treats an unreadable or
oversized override as the target and rejects it. Mocked oversize metadata reproduced fallback.
Both paths must refuse an uninspectable effective override, not silently edit the other file.

### F7-03 — P2: manual update/full lifecycle and ownership are incomplete

`manual_preflight.py:315-325` checks only owner/mode on an existing descriptor; it does not prove
the descriptor is unchanged. A read-only probe substituted an invalid runtime path and changed
source hash while retaining owner/mode: preflight still returned `ok=true`.

At lines 339-342 it compares the installed AGENTS block with the INCOMING release. Substituting
the authentic FINAL6 global block in an otherwise valid current manual fixture produces
`AGENTS managed block is modified or from another release`. A legitimate upgrade changing that
block is therefore indistinguishable from a user edit and cannot follow the documented sequence.

At lines 349-355 every existing full-mode skill is rejected, including unchanged owned ones.
An in-memory existing bundled skill path reproduced refusal. The runbook's full copy loop never
publishes a full-mode descriptor after reference activation; update still describes mostly a
selector change. Full update/rollback and final verification are not established.

The A→B→A test at `tests/test_review_ready.py:936-956` changes a report file, directly writes the
descriptor, calls doctor and reads the marker from the test itself. This proves path selection,
not the documented update or new runtime/knowledge behavior. The marker edits also leave package
manifest hashes stale; the fixture bypasses manual package preflight entirely.

### F7-04 — P2: duplicate exclusion is not anchored to the selected candidate/task

`ios_ai.py:462-468` passes the optional CLI candidate_root, which normally is None.
`knowledge_profile.py:245` then scans the old root stored in the profile. Retaining A and selecting
B with the same release string can leave A's exclusions active. FINAL6/FINAL7 already share `.6`.
In-memory reproduction: default status returns `active_exact_only`; passing actual B returns
`invalid: candidate release changed` for the same profile.

`source.active` is checked by truthiness, not boolean identity. A profile containing the string
`"false"` returned active exclusions. Runtime shape checks and JSON schema leave important field
types unspecified. A persistent activation flag also does not prove that the external replacement
has been loaded for the current task. Keep all uncertain documents enabled; bind status to the
actual runtime LIBRARY and require current-task use of the replacement before omitting a document.

### F7-05 — P2: protection opt-in is contradicted by the next instruction

`GLOBAL_CODEX/AGENTS.global.block.md`, Client-code protection, first says explicit opt-in, then
requires every authorized write task to start a protection session and says concurrent writers
require independent clones. Ordinary permission to edit code does not mean permission to enable
writer serialization. Gate the entire begin/scope/verify/close sequence on explicit adoption of
protection for that task. Apply the same wording to the routed consumers, not just the first bullet.

### F7-06 — P2: new observer guarantees and claimed coverage remain incomplete

`knowledge_profile.py:51-77` queues directories with no visited-entry/depth bound; MAX_FILES counts
only yielded regular files. Many empty directories are not covered by that memory envelope.
At 85-88 parent symlinks are checked before a path-based open; final O_NOFOLLOW does not protect
parent components changed between those operations. Directory traversal similarly opens queued
paths without stable directory handles. File fstat identity is useful but not a whole path boundary.
Aggregate bytes are checked after a whole file is read, so the declared aggregate can be exceeded
by a per-file allowance before refusal. Deadlines are cooperative, not a bound on blocking syscalls.

`manual_preflight.py:195-216` retains os.walk without onerror and without entry/byte/time bounds;
an unreadable subtree can disappear from ownership inspection. The suite's existing legacy race/
deadline tests target `ios_ai.py`'s other scanner, not these newly changed profile/installer paths.
Correct these scoped observers or narrow unsupported claims explicitly; do not add a new general
filesystem framework. This finding is from source inspection, not an observed exploitation.

## Positive changes to retain

- Manual emitters now check exit status and guard publication; this addresses a real failure path.
- Candidate/source hashes, explicit mappings and duplicate-list consistency improve the profile.
- Unknown session lifecycle now blocks deployment; streamed session scanning is an improvement.
- Shared descriptor routing and separate release/protection identities remain suitable foundations.
- The real isolated V11 `.1` close/retry evidence addresses the previously missing upgrade case.
- FINAL7 bytes match delivery identity. Keep that artifact immutable as review input.

## Concrete common-host proposal (not applied)

Place the following managed block in the EFFECTIVE host AGENTS file after an exact before/after
preview. This is separate from the candidate iOS block. The actual host file is not yet inspected.

```markdown
<!-- AIZENFLOW_COMMON_HOST_ENTRY_V1:BEGIN -->
For every project or task whose effective working directory is
`/Users/Artem/.zenflow` or a descendant of that directory, before the first project operation read
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md`.
Apply its common baseline to every project type, then select only task-relevant specialist routes.
This applies to existing, new, imported, nested and non-Git project directories in that scope,
including projects without a root AGENTS.md. Preserve project and nested instruction overlays.
Repository bootstrap markers provide portability; their absence must not suppress this host entry.
If the canonical file is unavailable, follow the approved portable-snapshot fallback where present
and report canonical-baseline-unavailable. Do not claim current canonical rules were loaded.
This block does not activate the new iOS library runtime or change command permissions.
Outside this directory scope, this block adds no instructions.
<!-- AIZENFLOW_COMMON_HOST_ENTRY_V1:END -->
```

Pending exact host targets: `/Users/Artem/.codex/AGENTS.md`, and
`/Users/Artem/.codex/AGENTS.override.md` only if present/effective; config.toml only if required to
resolve actual host discovery. No home directory scan, credentials, histories or sessions.
Existing user path restriction requires separate exact authority for those host reads/writes.
Until read authority exists, this is a proposed insertion, not a verified host diff.

## Detailed execution plan for Luna Xhigh

The user selects Luna for execution; this review itself makes no production fixes. Follow the
specified invariants below. Preserve both deployment paths and the full self-contained payload.
Default adoption remains knowledge/reference with protection disabled. Do not add services,
watchers, hooks, new policy engines, semantic dedup or mandatory multi-agent execution.

### 1. Finish the first-priority common knowledge delivery preparation

- [ ] Replace the iOS-only proposal in evidence 22 with the common scoped block above and correct
  its non-iOS row. Keep the candidate's separate Apple-specific scope.
- [ ] Prepare a concrete canonical diff for GLOBAL_RULES_BOOTSTRAP.md, NEW_PROJECT_START_CONTRACT.md
  and the existing bootstrap validator/template that enforces root adoption: distinguish host
  delivery from portable root adoption. Missing root marker must be an adoption/portability issue,
  not proof that globally delivered common guidance is absent. Preserve fallback and overlays.
- [ ] Resolve current exact host authority from the conversation; do not request granted actions
  again. If absent, finish the local proposal and continue steps 2–6. At the host boundary request
  only the missing exact read, then present the actual preserving diff for write approval.
- [ ] Acceptance: fresh existing, empty/imported-without-AGENTS, linked-worktree and non-iOS tasks
  receive the common baseline before project work. Cover nested/non-Git boundaries and an outside
  scope negative case when authorized. Use ordinary task prompts without a library reminder.
  Record selected documents and actual startup evidence; do not infer success from doctor/markers.

### 2. Close destination/override bypasses — F7-02

- [ ] Remove source-Git-root and environment-CODEX_HOME exemptions from BOTH preflights. A writable
  destination inside any client Git boundary is rejected regardless of defaults or payload location.
  If supporting a Git-managed host configuration is needed, require a separate explicit contract;
  do not infer it from an environment value.
- [ ] Keep source immutable, intended parent-child relationships explicit, independent destinations
  disjoint; reject missing/unsafe/non-regular/oversized effective override states consistently.
- [ ] Regression: source inside same client repo, target via CODEX_HOME, .git worktree file, ordinary
  external success, target overlap, nonempty/oversized override. No failed case creates a target.
  Keep synthetic test areas isolated; do not alter production checks to accommodate fixture layout.

### 3. Finish the actual manual lifecycle — F7-03

- [ ] Verify installed state against the PREVIOUS known release plus a small operator-owned receipt
  of descriptor/AGENTS/skills bytes and modes. Validate incoming release independently. Do not trust
  `managed_by` as proof of an unchanged descriptor. Unknown or edited state must stop before writes.
- [ ] Specify executable checked fresh/reference/full/update/rollback/disable procedures. Preserve
  old payload and state history; stage verified new files, update selected descriptor and effective
  managed AGENTS block coherently, publish full mode when full skills become active.
- [ ] Verify every declared destination after publication. Update may replace unchanged owned skills;
  user-modified/unknown skills survive or block. Keep ordinary manual operations and one read-only
  verifier; a receipt is data, not a second installer or autonomous rollback service.
- [ ] Acceptance uses valid hash-consistent release A and B with a real changed routed document or
  observable runtime result. Execute the DOCUMENTED A→B→A procedure through preflight, then disable.
  Cover changed global block, full update, modified descriptor/skill, an emitter failure and a
  publication failure. Compare sentinels/bytes/modes and retain state. Doctor alone is insufficient.

### 4. Make duplicate exclusion reliable — F7-04

- [ ] Normal profile status always uses the actual runtime LIBRARY root. Diagnostic override must
  not silently produce exclusions for another active release. Same release string is insufficient.
- [ ] Require strict profile types: boolean active, supported schema/kind, nonempty identities,
  valid hashes/absolute roots, unique safe relative paths and mappings. Reject malformed inputs
  with a structured invalid result and zero exclusions. Align JSON schema and runtime validation.
- [ ] Expose each exact replacement path. Router skips the local duplicate only after the external
  replacement is selected/read for this task; stored `active=true` is eligibility, not proof of
  task-context delivery. Missing/changed/unread external knowledge keeps the local document enabled.
- [ ] Regression: retained A while B selected with the same version string; changed candidate;
  changed/missing source; active string `false`; mapping collision; absent source; clean installation.

### 5. Remove unintended workflow changes and finish bounded reads — F7-05/06

- [ ] Make the entire protection sequence conditional on separate task opt-in. Ordinary authorized
  editing with knowledge-only activation creates no session and imposes no clone/serialization rule.
  When protection is explicitly adopted, retain all existing verification and scope requirements.
- [ ] Reuse suitable no-follow directory-handle/read helpers for the profile and manual observations.
  Bound visited entries (including directories), depth/pending work, actual remaining bytes and time.
  Never interpret unreadable/walk-error input as an empty owned tree. Report cooperative deadlines
  honestly. Preserve unsupported/error => no automatic exclusions/no deployment admission.
- [ ] Add targeted negative cases to these exact observers: empty-directory budget, directory-read
  error, parent replacement, per-file/aggregate edge and deadline. Preserve existing runtime scanner
  evidence; do not repeat its whole test matrix without changing that code.

### 6. One acceptance and delivery boundary

- [ ] Use focused checks while patching. Then review the complete FINAL7→corrective delta and all
  affected callers/contracts; include the untracked candidate. Resolve P0–P2 before deployment.
- [ ] Run the final relevant suite/validator once after source/tests stabilize; keep a command log
  with exact exit status. Reuse the valid V11 lifecycle receipt unless admission behavior changed.
- [ ] Correct evidence: distinguish path-selector test, actual lifecycle test and host session.
  Mark steps partially complete when only part passed. Current independent review is this report;
  do not leave it labelled simply "not run". Any further review checks changed bytes and findings.
- [ ] Freeze one artifact only after bounded corrective review. Record its SHA outside the ZIP;
  compare extracted bytes with the tested tree. If identical, do not automatically rerun the whole
  suite on extraction. Preserve FINAL7; no repeated FINAL8/9 archives for minor report edits.

### 7. Apply the approved knowledge connection and complete a short real pilot

- [ ] Use the prepared host diff once its exact path authority is established. Keep payload/state
  under the approved external area and preserve the working CODEX_HOME. Retain reversible backup.
- [ ] Run three real authorized tasks: one ordinary implementation, one review, one cross-domain.
  Record relevant material used, concrete useful findings, false positives, unnecessary work and
  unexpected stops. No automatic subagent fan-out; use available tools when the task warrants it.
- [ ] Accept internal knowledge use when first entry works, all local blocking findings are closed,
  disable is verified, and pilot demonstrates useful guidance without unintended process changes.
  Pilot establishes bounded practical usefulness, not guaranteed quality uplift for every project.
  Keep full/protection activation a separate explicit choice if not selected for this rollout.

### 8. Product handoff and stop

- [ ] Provide one short operator guide: connect manually, install on a clean host, check current
  state, update and disable; clearly state supported platform/tool availability and manual parity.
- [ ] Record known origin of supplied/generated materials, third-party components and declared
  license/NOTICE information. Missing information remains unknown; technical work can continue.
  Public redistribution stays a separate decision and does not justify another tool-building cycle.
- [ ] Synchronize concise current plan/handoff and approved canonical changes at a meaningful
  boundary under existing repository-specific permissions. Do not mix candidate work into app Git.
- [ ] Stop development when this contract is met. No further framework, corpus expansion or
  benchmark redesign is required for the first useful version. Backlog nonblocking improvements.

Context transfer: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
