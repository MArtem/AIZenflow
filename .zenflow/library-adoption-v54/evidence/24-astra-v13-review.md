# Astra review of V13 — 2026-09-14

Verdict: **NOT_READY for deployment; useful installer corrections, incomplete product integration**.
Scope: complete V11 ZIP → V13 file delta, affected transaction consumers, manual workflow,
runtime version compatibility, global block, and implementation claims. This is not a new full
audit of all 1,360 files or all domain guidance.

V13 SHA-256: `30ae363ea5441013937d3bc657fb91c1a086fe4ab3869b9692bd4051531516d8`.
Candidate bytes were not modified. Source-control publication and real host activation not performed.

## Improvements confirmed

- Fresh install/sync/uninstall now journal intended publication before helpers can raise after rename/fsync.
- Uninstall separates destructive backup cleanup from rollback; late cleanup has an explicit status.
- Runtime version fields now agree with the manifest.
- A manual shim and runbook exist without invoking installer scripts.
- Six targeted shipped tests independently ran: fresh post-rename, fresh post-metadata,
  full-upgrade post-rename, uninstall post-rename, uninstall post-unlink, uninstall late-cleanup.
  Result: **6 tests / 0 failures / 0 errors**, 4.229 s, runner exit 0.
  One preceding invocation lost its final runner handle; the recorded run above was repeated
  to obtain a definite completion result. No full-suite rerun was needed for this review.
- Prior 156/156 is retained as Luna self-test evidence, not relabeled as this review's full suite.

## Findings

### AV13-01 — P1: manual copy can overwrite existing unmanaged content

`MANUAL_DEPLOYMENT.md:57–61` creates/merges existing destinations using `mkdir -p`, `ditto`
and `cp` before any required collision refusal for content/shim. The skill warning is after
the skill-copy block and is not a complete preflight. Hash-checking the input archive does not
prove ownership of destination files. There is no required pre-mutation check for destination
symlinks or client-root containment comparable to installer preflight.

Observed synthetic reproduction: same `ditto source/. target/` operation returned 0 and replaced
`user-owned bytes` with `new library bytes` at an occupied target. Probe:
`review_v13_manual_probe.py`; retained fixture `astra-v13-n65qre7c` beside this report.
No real user file was targeted. Target state: all destinations checked before any copy; fresh
targets must be absent; existing/unknown/modified targets cause an explicit refusal. Keep a
read-only verifier usable by the manual operator; do not require executing installer mutation.

### AV13-02 — P2: documented manual update never switches the selected release

`MANUAL_DEPLOYMENT.md:106–109` prescribes copying a new versioned directory and replacing the
shim. `MANUAL_SHIM/bin/ios_ai.py:8–9` always selects `<home>/ios-engineering/...` and has no
release-selection setting. Synthetic probe with distinct old/new runtime sentinels produced
`old` before and `old` after copying the new release and replacing the shipped shim.
Target state: one explicit runtime/knowledge/state descriptor shared by both deployment paths;
update and rollback demonstrably select different pinned payloads.

### AV13-03 — P2: protection-version bump needs an upgrade/session contract

The V11 runtime actually used protection version `.1`; V13 changes it to `.5`.
`protection.py:658–659` rejects a baseline with another protection version. `ios_ai.py:368–380`
closes an active session only after that comparison succeeds. `sync_global.py` has no active
session admission check, while QUICKSTART's upgrade warning covers V5.2 only.
Consequence inferred directly from these branches: an active V11 session retained across
update fails verify/close and keeps its writer lease; recovery needs the old runtime.
Target state: close/recover incompatible active sessions before replacement; retain old runtime
and history. Prove real previous-runtime begin → upgrade refusal → old-runtime close → update.
Do not disable version checks or rewrite baseline hashes to obtain PASS.

### AV13-04 — P2: manual deployment does not implement the agreed external-area layout

Manual paths are fixed beneath active CODEX_HOME; moving the active area to `.zenflow` is
described as changing the Codex home. The agreed deployment should allow payload/state under
the user's external area while retaining the current Codex home and a minimal discovery entry.
Installer already supports explicit paths/source-in-place; the manual shim lacks equivalent
selection. Consolidate this correction with AV13-02, not a second deployment framework.

### AV13-05 — P2: automatic knowledge routing and duplicate suppression remain unwired

`GLOBAL_CODEX/AGENTS.global.block.md` publishes paths and mandates protection sessions, but has
no instruction to load the knowledge router/profile on an ordinary task. Reference mode
installs no skills. No new profile consumer is present in the V11→V13 code delta. The task-local
capability matrix calling duplicate handling 'CONTRACT DEFINED' is not a working mechanism.
Result: startup can impose runtime work without reliably selecting useful thematic knowledge.
Target: one shipped startup route, one small deployment profile, explicit exact-duplicate
invalidation, and bounded review/subagent routing. Require known external source activity;
semantic overlap/conflict must not silently disable complete sections. Non-iOS tasks inside
the canonical area still receive common engineering rules, not forced iOS policy.

### AV13-06 — P2: evidence claims and checked plan items exceed actual coverage

`REVIEW_READY_VALIDATION_REPORT.md:5–8,13,21` still says independent review/run completed without
pinning it to its historical artifact. V13 changed counts but retained those sentences.
The full-upgrade regression still targets the first new skill, not complete file-set/hash
rollback. The manual test checks wording; the other manual test checks only doctor/relocation.
`doctor` at `ios_ai.py:474` checks presence of two runtime modules, not instruction loading,
profile consumption, safe manual destinations, or update/disable parity.
Task plan closed full dual-path preservation and reporting corrections despite these gaps.
`evidence/README.md` still opens with stage 18/V4 as current; capability matrix is outside ZIP.
Target: precise artifact-scoped evidence, behavioral lifecycle comparison, and reopen unproven
checkboxes. This report supersedes prior blanket 'local implementation complete' wording.

## Acceptance and priority

Existing canonical automatic adoption remains **unverified / not accepted**. The prepared host
preview additionally narrows the entry to iOS tasks, contradicting the plan's all-project common
baseline scope. Repair that scope before host application. No real host file was inspected here;
the review request does not require host mutation. Exact external-path authorization remains
governed by the user's existing boundary, not by candidate Markdown.

Priorities: existing-knowledge discovery/first-entry; unified external layout and safe manual
lifecycle; incompatible-session update handling; usable routing/profile; one acceptance pass.
Do not expand into new benchmark infrastructure, daemons, hooks, automatic model switching,
or mandatory Xcode/device validation just to accept this tooling package. Actual iOS runtime
checks belong to the later selected consumer's task and permissions.

License/source provenance remains unknown; internal-only intent is not proof of rights for
third-party material. Keep publication separate from a bounded local pilot.
