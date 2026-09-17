# L3 runtime hardening receipt

Historical receipt superseded for current status by `18-corrective-s1-s6-receipt.md`. Its 140-test
and pre-A54 cleanup wording remains preserved as historical evidence only.

Date: **2026-09-12**. Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.
Scope: isolated candidate runtime and shipped synthetic Python tests only.

## Change contract

The legacy V5.2 compatibility scanner is read-only admission evidence. It may identify a valid
active/verified session sharing the Git common directory, but it must never rewrite archival state,
follow a state-root escape, exceed bounded observation, or return a successful observation after a
slow final operation exceeds the cooperative deadline. Failure is `ProtectionError` and admission
remains blocked. The current V5.4 schema-3 writer lifecycle is unchanged.

## Applied delta

`GLOBAL_CODEX/runtime/bin/ios_ai.py` now:

- imports and uses explicit `stat` mode checks for intermediate `protection` and `sessions`
  directories;
- rejects symlink/non-directory intermediate state components before scanning records;
- passes the remaining aggregate byte budget to the no-follow `secure_read_json` loader;
- passes the `DirEntry` device/inode/size/mtime identity into the loader; the loader verifies
  that identity before reading and again after reading, rejecting replacement or mutation between
  directory observation and file consumption;
- accounts the record after the bounded read and rechecks the deadline before continuing or
  returning success;
- retains repository-entry, session-record, aggregate-byte and cooperative total-deadline limits.

`tests/test_review_ready.py` now:

- runs all temporary Git/Codex fixtures under the isolated task `.zenflow` adoption workspace,
  avoiding the macOS `/var` symlink while preserving the protected path policy;
- ships regression tests for intermediate symlink escape, exact aggregate-byte boundary and
  overflow, ordinary-file replacement between `stat` and read, scanner iteration failure, and a
  slow final record read that overruns the deadline.

## Observed checks

Command:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -B tests/run_all.py
```

Observed:

- `REVIEW_READY_TEST_SUMMARY total=140 pass=140 fail=0 skip=0`
- runner exit: `0`
- all 31 `ProtectionSessionTests` passed, including five new bounded-observation test methods
  covering six concrete boundary/race scenarios added in this iteration;
- `PYTHONDONTWRITEBYTECODE=1 python3 -B validate_package.py` passed after manifest synchronization:
  `files=1357 skills=60 sections=51 playbooks=288 errors=0`.

Current file identities after the code/test changes:

| File | SHA-256 | Bytes |
|---|---|---:|
| `GLOBAL_CODEX/runtime/bin/ios_ai.py` | `d0d97fe639a2b0fa3d345167399d28b2e556b51cef64f81dd6d4d2e8a1daf7f9` | 34137 |
| `tests/test_review_ready.py` | `b38262dbda55f6490276b9e58efcb5df7576417db83370f4f411cce40bf77b91` | 82980 |

## Semantic result and limits

L3 runtime hardening is **implemented and self-tested in the isolated candidate**. This receipt
does not establish an independent review, a hard wall-clock interrupt for arbitrary filesystem
syscalls, an app/Xcode/device guarantee, or safety of a real global installation. The deadline is
cooperative: it is checked at scanner checkpoints and after the bounded file read. A blocked kernel
filesystem call cannot be made interruptible by this Python check alone.

The exact-boundary test proves the loader rejects a record above the remaining aggregate envelope;
the identity test proves that replacing the observed regular file before opening it is rejected,
and the post-read identity check covers mutation during consumption. Unknown state remains
fail-closed.

## Gate status

L3 code/test evidence: **PASS for this bounded candidate delta**. L3 public contract, recovery
matrix and full final-diff independent review remain required before any adoption or release claim.
