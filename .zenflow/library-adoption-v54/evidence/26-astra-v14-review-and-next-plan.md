# Astra: V14 review and bounded implementation plan

2026-09-14. Verdict before corrective implementation: NOT_READY for deployment. Review covers deployment/control-plane changes,
profile routing and acceptance claims; it does not audit every iOS knowledge document.
Reviewed archive: V14_FREEZE_FINAL6, SHA-256
`dcdbfe1a16ebf37a5417751c15cea098e3db3dc40fdf10cb9722b02821fa3bc1`.
Read-only comparison confirmed every archived regular file matches the candidate.
The corrective implementation is now frozen separately as V14_FREEZE_FINAL7; its external receipt
records the new SHA, 173/173 suite result and bounded acceptance evidence. Astra did not independently
re-review FINAL7.

## Findings

- AV14-01 / P1 / product delivery: plan section 1 remains unchecked, including preparation
  of the scoped host block and alignment with canonical bootstrap/templates/checker.
  Current bootstrap still requires per-repository adoption. Universal existing/new/imported
  project activation is neither delivered nor proven. An external write boundary does not
  prevent preparing the exact local proposal and acceptance script.
- AV14-02 / P1 / manual destinations: MANUAL_SHIM/bin/manual_preflight.py:149-164 checks
  symlinks but does not enforce separation from client repositories or pairwise target overlap.
  Read-only reproduction with all proposed destinations under the existing synthetic Git repo
  returned ok=true, collisions=[], targets_created=false. The operator can subsequently create
  library infrastructure inside client code contrary to the stated contract.
- AV14-03 / P2 / manual lifecycle: MANUAL_DEPLOYMENT.md:56-85 publishes generated output
  without conditional success checks. An unsuccessful emitter outputs an error object which
  the following mv can publish. Full-mode steps follow a reference deployment; preflight rejects
  the mode mismatch (independently reproduced), while the following shell loop lacks a gate.
  Repeating full preflight rejects every existing skill. There is no fully specified safe
  manual update/rollback sequence. Copy-paste safety cannot be replaced by comments.
  Explicit --agents-file also bypasses active_agents override selection; the runbook defaults
  that option to AGENTS.md without checking a non-empty AGENTS.override.md.
- AV14-04 / P2 / duplicate profile: knowledge_profile.py:86-103 revalidates only the external
  source, not candidate release/content or the exact duplicate list. A retained old profile can
  suppress newly changed local material after upgrade. Read-only reproduction with an outdated
  candidate identity returned active_exact_only and the stale exclusion. profile status without
  --source-root always returns unknown_source, although that is the advertised entry command.
  Same-relative-path matching is conservative but does not handle equivalent material stored
  under different canonical library paths; do not promise semantic duplicate detection.
- AV14-05 / P2 / unintended process changes: AGENTS.global.block.md:24-31 mandates protect
  begin/verify/close for every write, including reference mode. Plan section 5 calls runtime
  opt-in. This can serialize linked worktrees and require recovery after interruption, despite
  a user's intent merely to activate knowledge/review guidance.
- AV14-06 / P2 / new observation paths: install_global.py:385,399 materializes sorted scandir
  before enforcing entry budgets; its admission scanner has no deadline and silently ignores
  unknown lifecycle values at 414-416. knowledge_profile.scan uses os.walk without onerror,
  no deadline, and open after lstat without no-follow/identity protection; bytes are budgeted
  before reading, not against actual consumed bytes. These differ from the bounded fail-closed
  guarantees already implemented elsewhere. Reuse existing hardened primitives.
- AV14-07 / P2 / acceptance claims: the A/B test uses two copies of the same version and
  runs doctor; it does not execute A→B→A or the manual operator update procedure. The actual
  previous-version finding concerned V11 protection .1→.5; V13→V14 both use protection .5,
  and passing compatible admission cannot close the incompatible-upgrade acceptance item.
  The plan checks final independent diff review while also saying it remains pending.
  git diff --check does not cover the untracked candidate tree. Repeated FINAL ZIP/suite cycles
  consumed effort without closing the primary adoption requirement.

## Positive result to retain

The shared JSON-selected external payload/state mechanism, explicit release/protection identity
separation, reference mode without skill installation, collision fixtures and shipped router are
useful improvements. The architecture does not require restarting or expanding the project.

## Executable next plan

This supersedes V14 blanket CLOSED claims. Implementation follows a user command; this turn is review/planning.

- [ ] 1. First-entry delivery: prepare the minimal all-project .zenflow host block locally,
  exact affected-file list and before/after proposal when existing read authority permits.
  Align canonical bootstrap, new-project template and checker. Preserve project overlays.
  Resolve only missing exact host permissions at the application boundary. Acceptance: fresh
  existing, empty/imported, new worktree and non-iOS sessions load the common baseline;
  nested/non-Git and outside-area behavior is explicit. Do not infer discovery from doctor.
  Local proposal preparation is complete; actual host first-entry/fresh-session acceptance remains pending.
- [x] 2. One bounded deployment correction: reject client-root and overlapping destinations,
  resolve effective AGENTS/override consistently, and make fresh/full/update/rollback/disable
  explicit. Both manual and installer must stop on failed verification and preserve unknown
  bytes/modes. Manual stays operator-driven; do not add a new installer/service disguised as
  manual mode. Use explicit checked command groups and publication receipts.
- [x] 3. Preserve workflow: separate knowledge/review activation from protection runtime opt-in.
  Both deployment paths use the same option. Default knowledge activation must not silently
  create writer sessions, change Git permissions or serialize concurrent project work.
- [x] 4. Correct profile: validate current candidate identity and source identity before each
  exclusion, validate schema/paths, and require evidence the external replacement is loaded for
  the task. Supply explicit source mappings for differently organized libraries; uncertain or
  merely semantic overlaps stay enabled. No embeddings/deduplication service is needed.
- [x] 5. Reuse bounded scan primitives: streamed iteration, actual-byte accounting, deadline,
  no-follow/identity checks and explicit unknown/error handling in the two new scanners.
  Reproduce V11 .1 begin → V14 admission rejection → V11 close → admission success;
  preserve history and complete the new-runtime lifecycle on the same state.
- [x] 6. Acceptance before packaging: run the actual documented manual commands and installer
  in isolated clean/existing fixtures; verify sentinels, permissions, failed-step behavior,
  source selection A→B→A with distinguishable content, override precedence and disable.
  Add focused behavioral regressions only for the findings above; avoid string-presence tests.
- [x] 7. One reviewed artifact: review the full V13→candidate file delta, including untracked
  files; run relevant checks, freeze bytes once, package once, verify extraction identity.
  Store SHA/results outside the archive. Reuse unchanged runtime evidence. Correct checkbox
  statuses and distinguish self-test, independent review and actual host results.
- [ ] 8. Controlled use: activate the knowledge layer in the approved area; complete three real
  tasks (implementation, review, cross-domain). Record useful findings, false positives, omitted
  guidance, added work and unexpected stops. Accept ordinary use when first-entry works and no
  P0–P2 remains; keep runtime and public distribution separate decisions. Establish material
  provenance before distribution; internal intent alone does not establish third-party rights.

Luna implemented the locally executable steps with fully specified invariants and bounded per-step
acceptance. The remaining host/pilot/provenance gates require their separately stated authority and
review boundary.
Architecture/authority choices and final review need the stronger reviewer; avoid another
unbounded Luna investigation and repeated packaging cycle. No new framework, daemon, hooks,
benchmark engine, mandatory subagent fan-out or full-corpus context loading.

FINAL7 candidate, task evidence and isolated fixtures were changed by the corrective implementation;
no host configuration, app source or Git refs were changed. Final artifact receipt:
`evidence/25-luna-v14-final-freeze-receipt.md`.
Read-only probes used existing synthetic paths; no destinations were created.
Context transfer: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
