# Final Luna Xhigh V13 candidate receipt

Date: **2026-09-14**. Scope: isolated standalone library candidate and task-local adoption
evidence. No real Codex home, client repository, Git remote, or canonical documentation checkout
was changed by this receipt.

## Artifact identity

- Candidate: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.
- Version: `5.4-review-ready.5`.
- Archive: `/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_XHIGH_CORRECTIVE_CANDIDATE_V13.zip`.
- Archive SHA-256: `30ae363ea5441013937d3bc657fb91c1a086fe4ab3869b9692bd4051531516d8`.
- Archive size: `2,852,953` bytes.
- Extracted verification root: `dist/extracted-luna-xhigh-corrective-v13/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.

V12 is superseded and is not the delivery artifact. V13 includes the uninstall transaction fix
found during the final boundary review.

## Observed checks

| Check | Result |
|---|---|
| Source package validator | `files=1360 skills=60 sections=51 playbooks=288 errors=0` |
| Extracted package validator | `files=1360 skills=60 sections=51 playbooks=288 errors=0` |
| Source synthetic suite | `156/156 PASS, 0 FAIL, 0 SKIP` |
| Extracted synthetic suite | `156/156 PASS, 0 FAIL, 0 SKIP` |
| Source/extracted tree comparison | `diff -qr` clean |
| ZIP bytecode scan | no `__pycache__`, `.pyc`, or test cache entries |
| Python compatibility parse | all shipped Python entrypoints parse under Python 3.9 grammar |
| iOS/Xcode/Simulator/device | not executed; no claim made |

## Candidate changes

- Fresh install, sync and uninstall pre-journal target publication before rename/link/unlink/fsync
  failure can leave a public path changed.
- Sync and uninstall distinguish pre-publication failure, safe rollback, and cleanup after the
  commit point; cleanup failures report an applied/incomplete state instead of a false rollback.
- Added bounded failure-injection tests for fresh install, full upgrade, uninstall rename,
  metadata unlink and late cleanup paths.
- Runtime CLI, adapter and protection component versions now match the release manifest.
- Added a relocatable `MANUAL_SHIM` and `MANUAL_DEPLOYMENT.md`. Manual unpack uses the same active
  payload/runtime/skills contract without invoking installer code; it explicitly discloses that
  extraction under a parent directory is not automatic universal adoption and that rollback is
  operator-managed.

## Safety boundary observed

No `/Users/Artem/.codex` file, `CODEX_HOME`, Desktop launch setting, client source tree, app
repository Git ref, simulator, device, or network service was modified. Existing untracked
PanModal adoption files remain uncommitted. The candidate does not install hooks, daemons,
watchers, auto-updates, or a kernel sandbox.

## Open acceptance gates

- The final V13 delta still needs an independent read-only re-review; Luna's suite is not that
  second barrier.
- Provenance, source commit, license/NOTICE/SPDX and redistribution rights remain `UNKNOWN`.
- Existing canonical-knowledge automatic first-entry adoption for every current/future project is
  not proven. The host entrypoint preview is prepared separately; exact host-file authority is
  required before reading or changing `/Users/Artem/.codex`.
- Manual and installer paths have synthetic relocation/lifecycle coverage, but no real fresh Codex
  session or real consumer pilot has been executed.
- The library remains a quality/advisory and before/after detection layer, not a guarantee against
  every defect, arbitrary process mutation, transient write, ignored-file change, or Mac failure.
