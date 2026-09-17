# L4 installer, legacy-state and interruption receipt

Historical receipt superseded for current status by `18-corrective-s1-s6-receipt.md`. In
particular, the pre-A54 late-cleanup rollback wording below is not the current contract.

Date: **2026-09-12**. Scope: synthetic homes, real V5.2/V5.4 Python entrypoints and one
synthetic forced interruption. No real Codex home or client repository was targeted.

## V5.2 → V5.4 lifecycle

`evidence/run_install_lifecycle_macos.py` now uses the preserved V5.2 review candidate at
`library-review-v52-aPK9Wh`, not a text sentinel. It:

1. installs the V5.2 reference package into a synthetic home;
2. creates a synthetic Git consumer and uses the actual V5.2 CLI to begin and close a valid
   schema-2 session;
3. records that session bytes before the V5.4 update;
4. runs V5.4 dry-run/update, validates the installation, runs the V5.4 archival status path,
   repeats update and uninstall, and compares the history bytes after every boundary;
5. creates actual V5.2 `active` and `verified` sessions and confirms that V5.4 blocks writer
   admission until the old runtime explicitly closes them; after recovery, a V5.4 writer can
   begin and close.

Observed result on Python **3.9.6** / macOS:

```text
v52_installer=PASS
v52_valid_closed_session=true
archival_status=ARCHIVAL_CLOSED
active_legacy_blocked=true
verified_legacy_blocked=true
explicit_v52_recovery=PASS
post_recovery_begin=PASS
v54_update=PASS
repeat_update=PASS
session_history_preserved_byte_for_byte=true
```

The same run retained the prior synthetic reference lifecycle and full-mode collision checks:
reference has zero bundled skills, full enumerates 60 namespaced skills, reference→full update
passes, and user-owned AGENTS content is preserved.

## Late cleanup failure

The shipped `InstallerTests.test_F10_late_backup_cleanup_failure_restores_published_state`
injects an error only when the update tries to delete a target-local rollback backup after
metadata publication. The test verifies the original AGENTS bytes, registry bytes and shim hash
are restored, and no hidden backup remains. This is an observed rollback behavior for this
injected point, not a claim that arbitrary process termination is crash-atomic.

## Forced interruption rehearsal

`evidence/check_interruption_macos.py` starts a subprocess against a synthetic copied-mode home,
pauses immediately after the first managed tree publication, and sends `SIGKILL`. The next
installer dry-run discovers the partial content root and refuses to overwrite it. The harness then
removes only the exact installer-owned partial tree and transaction directories, reruns install,
and validates the result.

Observed:

```text
child_exit=SIGKILL
published_before_interrupt=true
next_launch=blocked_and_discoverable
operator_recovery=PASS
post_recovery_install=PASS
```

This deliberately records partial-install discoverability and a bounded operator recovery path;
it does not claim automatic crash rollback or protection against an arbitrary external edit during
the killed interval. Recovery must inspect exact paths and preserve anything not proven installer-
owned.

## L4 verdict

The declared synthetic installer/legacy/recovery envelope is **PASS**. Remaining limits are:
provenance/license ownership, independent final review, real global activation, and a production
consumer pilot. L4 does not authorize global installation and does not restore user source code.
