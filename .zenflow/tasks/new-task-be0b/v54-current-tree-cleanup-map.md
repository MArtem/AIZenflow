# V5.4 current-tree cleanup map — not an authorization to delete

Historical pre-publication inventory. Its staged-removal and uncommitted
claims are superseded by `v54-retirement-published-status.md`; retain only as
evidence of source accounting, not as the current execution plan.

Goal: leave one uniquely named copy-only reference library with all useful V5.4 knowledge,
including all former `ioslib-*` skills, while removing installer and Codex-host-modification
mechanisms from the current Git tree. Published Git history stays intact. Current host effects
are tracked separately in `codex-v54-rollback-audit.md`.

## Observed source classes

- 1,367 tracked files exist under `reusable/ios-engineering-library/v5.4/`. Do not equate the
  tracked historical source with an active Codex installation.
- `GLOBAL_CODEX/skills/`: 240 files across 60 skill directories. All 240 were copied exactly
  into inactive `reference-copy-only/source-skills/`; recursive diff passed. Their `SKILL.md`,
  agent YAML and domain checklists contain useful work patterns, but many also mention global
  installation, runtime commands and `INSTALLATION.md`. No copied skill is yet allowlisted.
- `GLOBAL_CODEX/runtime/`: 53 tracked files, including 17 `core/`, 20 `orchestration/` and 12
  `templates/` files alongside executable runtime/vendor/protection files. Keep useful knowledge;
  do not remove the entire directory by name. Its 49 Markdown/JSON documents are now preserved
  byte-identically under inactive `reference-copy-only/source-runtime/`; executable Python files
  were not copied. This is preservation, not approval of their installer-dependent wording.
- Root deployment entrypoints include `bootstrap_global.sh`, `host_entry.py`,
  `install_global.py`, `sync_global.py`, `uninstall_global.py`, `validate_global_install.py`
  and `MANUAL_DEPLOYMENT.md`. `MANUAL_SHIM/` has four tracked files. These are candidates for
  current-tree removal after reference content and inbound links are resolved.
- First bounded current-tree removal is **uncommitted**: deleted only `v5.4/bootstrap_global.sh`
  (direct installer wrapper) and `v5.4/AGENTS.md` (nested instruction to preserve global
  installation). No active baseline/app document referenced these paths. The old
  `PACKAGE_FILE_MANIFEST.json` still lists both; it belongs to the retired installation release
  and must be removed/replaced during final cleanup. Do not publish this partial source tree as
  a valid V5.4 package.
- Two further bounded, uncommitted batches removed `host_entry.py`, `install_global.py`,
  `sync_global.py`, `uninstall_global.py` and `validate_global_install.py`; all are tied to
  installation/host-entry/installed-state management. `git diff --check` passed after each
  batch. The mixed `GLOBAL_CODEX/runtime/bin/ios_ai.py` and two manual-shim executables were
  initially held after auto-review rejected deletion pending full accounting of useful behavior.
  After the command/helper ledger, candidate capability map and explicit user authorization,
  these three files were deleted in a third bounded, uncommitted batch. See
  `v54-runtime-command-ledger.md`. The copy-only library retains useful decisions but not the
  former runtime's stateful enforcement; do not claim functional parity.
- `50_CLIENT_CODE_PROTECTION/` has 11 tracked files. Separate general safe-write principles
  from the old installed protection mechanism before deciding exact removal. All 11 were copied
  byte-identically to inactive `reference-copy-only/source-protection/`; a curated copy-only
  repository-safety route now preserves the main principles without the installed CLI.
- The numbered iOS knowledge sections, deep playbooks, prompts, audit gates, project workflows,
  agent roles and templates are presumed useful until reviewed. The inactive candidate already
  holds 813 thematic Markdown files, all 186 Markdown documents from `36–49` in `legacy-source/`,
  and curated routes. The 186 legacy copies are unrouted, may contain installer commands, and
  are **not** part of the eventual active payload without conversion.
- A targeted search found 81 V5.4 Markdown files mentioning selected installer/shim/runtime
  entrypoints; 40 are under `38_REPO_WORKFLOWS/` and 18 under `37_AGENT_ROLES/`. Sampled hits
  in those two areas are the same global-install path-mapping preamble, not evidence that their
  underlying workflows are installation-only. Their raw copies are now preserved in inactive
  `legacy-source/`; salvage useful bodies before final-payload selection. The targeted pattern
  is not a complete dependency scan.
- The five executable files under `40_REPO_AUTOMATION/` were inspected but not run or copied.
  `discover_xcode.sh` and `repo_intake.py` contain useful bounded-discovery ideas;
  `swift_risk_scan.py` provides heuristic review leads but imports the retired protection
  runtime; `verify_diff.sh` invokes that scanner; `validate_ai_layer.py` checks installed
  `.agents/skills` layout. Rank concepts for future reference behavior, not the old scripts as
  executable payload. Do not call them safe merely because their README says read-only.

## Safe sequence

1. Complete a content ledger for **every** tracked V5.4 file: useful payload, convertible
   installation-dependent guidance, deployment-only mechanism, generated/redundant metadata, or
   unresolved. A filename or folder is not enough evidence.
2. Convert all useful skill/core/orchestration/protection ideas into copy-only documents. Make
   the new library self-contained, with an exact active allowlist, valid links, local-rules-first
   precedence and `AUTO`/`ADVISORY` action-advice behavior. Keep raw snapshots unrouted.
3. Search inbound references from canonical bootstrap, active baseline, app/task docs and the
   proposed reference payload. Resolve consumers before deleting a tracked V5.4 file.
4. Only then remove the exact deployment-only files from the **current** tree in reviewed batches;
   do not rewrite Git history, force-push, run an uninstaller, or touch Codex auth/Keychain.
5. Review the complete final diff and fresh-chat behavior. Keep any unresolved source and report
   it rather than pretending the migration is complete.

No tracked V5.4 file was removed in this inventory block. The unfinished reference candidate
must not be copied into a client project or published as a ready release.
