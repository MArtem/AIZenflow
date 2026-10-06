# Per-project reference mode — candidate contract

This document specifies a future conversational control. It does not activate reference, create
state, install hooks, or modify Codex configuration. Project-local rules and the user's current
instructions remain authoritative in every mode.

## Enablement and execution profile

`ON`/`OFF` is the per-project enablement switch. For `ON`, `AUTO` is the default reference
execution profile: after each local quality stage, select and perform applicable **in-session,
read-only or already-authorized** reference reasoning and review, correct findings within the
task's existing write scope, and recheck the final artifact. It needs no installer, daemon,
scheduled job, Codex configuration change or implicit tool invocation. `ADVISORY` is the alternate
profile: explain the applicable reference checks and prioritized recommendations without claiming
they were performed. Both profiles leave the full local quality workflow intact.

The profile changes only how approved reference guidance is applied, never the authority boundary.
Builds, tests, Simulator/device work, agent delegation, external/network operations, Git changes,
dependency resolution, signing, release and host/Codex changes still require their own current
authorization. A rule that asks for one of these actions becomes a recommendation or an explicit
permission request, not an automatic step. `AUTO` means automatic *reasoning within the task*,
not background execution or unattended project mutation.
In both profiles, use [RISK_AND_EVIDENCE.md](RISK_AND_EVIDENCE.md#action-advice-not-silent-authority)
to decide whether such an action is worthwhile and explain the smallest useful check, its
expected evidence, cost/risk and permission status. `ADVISORY` does not waive this decision.

## Identity and storage

The approved external state directory is
`/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/reference-status/`. Status is per
**Xcode project**, not per whole Git repository. Select the exact `.xcodeproj` affected by the
task; its normalized repository-relative path is the project component. A workspace that contains
multiple projects is not itself a shared identity. If several projects are affected, resolve each
mode separately; never inherit one project's ON for another. If no `.xcodeproj` exists and the
task is a standalone Swift package, use its repository-relative `Package.swift` path. If the
project is new and has neither yet, operate as UNSET/OFF until its identity exists, then ask.

For Git, the repository component is the normalized absolute Git **common directory** path;
linked worktrees of the same project therefore share one mode, while distinct clones do not.
For non-Git work, use the normalized absolute containing project root. Reject ambiguous roots,
symlinked project selectors or selectors outside the chosen root. Never use a remote URL, display
name, source body or credential as identity.

The record filename key is lowercase SHA-256 of UTF-8 bytes
`ios-reference-project-v1<NUL><kind><NUL><repository-component><NUL><project-relative-path>`,
where `<kind>` is `git-xcodeproj`, `git-package`, `local-xcodeproj` or `local-package`; `<NUL>` is
one zero byte, not the printed characters. This unambiguous encoding must be identical in every
chat. The record also stores a `scope_fingerprint`: lowercase SHA-256 of UTF-8 bytes
`ios-reference-object-v1<NUL><kind><NUL><device-decimal><NUL><inode-decimal><NUL><project-relative-path>`.
Device/inode refer to the Git common directory or non-Git containing root. A replaced root at
the same path therefore invalidates the old record instead of silently inheriting its mode.

The record name is `<64-lowercase-hex-key>.json`. Version 1 is exactly:

```json
{"schema_version":1,"mode":"ON","profile":"AUTO","scope_fingerprint":"<64-lowercase-hex>"}
```

`mode` is `ON` or `OFF`; `profile` is `AUTO` or `ADVISORY` and is retained even while OFF;
`UNSET` means no valid record. Unknown schema, malformed/duplicate fields,
invalid fingerprint, unreadable file, unsafe symlink, identity ambiguity or conflicting records are not silently
repaired or overwritten: behave as `OFF`, show `UNSET/invalid`, and ask the user. A moved project
gets a new key and returns to `UNSET`; never infer its old preference from a similar name or
remote. The record contains only mode and the minimum identity metadata, never a raw path, code,
credentials or logs. Records are local ignored state, not committed documentation.

## Conversation controls

| User request | Effect |
| --- | --- |
| `reference status` | Read current project's record and show `ON`, `OFF`, or `UNSET/invalid`; for ON also show its effective `AUTO`/`ADVISORY` profile; never write |
| `reference on` | After an explicit request, set only this project's valid record to `ON`; a new record starts with `AUTO`, an existing record retains its profile |
| `reference off` | After an explicit request, set only this project's valid record to `OFF`; retain its profile |
| `reference recover` | Disabled: report the refusal and preserve the record unchanged; explicit ON/OFF choice does not bypass this restriction |
| `reference review` | Apply the current mode's permitted, task-appropriate review; never change mode |
| `reference help` | Show these controls and authority/evidence limits; never write |
| `reference config` | Show current mode, profile and immutable safety defaults; never write |
| `reference auto` | Explicitly select `AUTO` for this ON project; does not authorize new tools or writes |
| `reference advisory` | Explicitly select `ADVISORY` for this ON project; does not lower local gates |

At first entry to an `UNSET` project, show the status and ask once whether to enable reference;
continue local work as `OFF` until answered. `ON` adds checks only for future work or subsequent
stages; it does not retroactively validate earlier output. `OFF` never skips local quality work.
No mode or profile change grants build/test/Git/network/dependency/signing/release permission.
For a cross-project task, apply local quality to the complete change; apply each ON project's
own reference profile to its affected artifacts and shared consumers, without changing any OFF
project's saved mode. If project scope cannot be resolved, ask and operate as OFF meanwhile.

The copy-only `tools/reference_mode.py` implements the record operation. It is not a global
Codex service; an explicitly approved project-local instruction may ask a chat to invoke its
read-only `status` for one exact project. Synthetic checks alone do not establish new-chat
behavior; any pilot observation is scoped to that project's copied payload and entrypoint.
Actual writes require a separately reviewed, explicit user-requested transition. Before writing,
revalidate the project key and exact destination; preserve malformed or unexpected files for
inspection rather than overwriting them. Make replacement atomic within the same directory and
report the observed result. A command failure leaves the transition result `UNKNOWN` until
status is re-read. This draft is not an activated cross-chat command service.

Recovery is disabled. `recover` fails before scope lookup, locking or filesystem mutation,
including when an explicit ON/OFF value is supplied. Invalid records remain untouched;
ordinary transitions reject them. Any future recovery mechanism needs separate review and
authorization, not an automatic repair or a suggested manual deletion.

Record opening is nonblocking and followed by a regular-file check. Directory locks are
nonblocking: contention returns an explicit error/UNKNOWN instead of waiting. This bounds
lock waiting, not all filesystem I/O latency. Locks coordinate cooperating handler callers;
they do not guarantee isolation from arbitrary same-UID writers. Never copy record contents
to a chat response or Git-tracked file.
