# iOS Engineering AI Library 2026 — V5.4

Portable, versioned iOS/Swift engineering knowledge and safety tooling for Codex. This archive is
self-contained: it contains the knowledge corpus, global entry instructions, runtime, installer,
manual deployment procedure, namespaced optional skills, validators, and synthetic regression
tests.

This README is the handoff contract for a Codex agent that receives only this archive. Read it
before changing files, installing anything, or running a project command.

## 1. What this library is — and is not

The library adds a bounded, reusable quality layer for iOS work:

- a single knowledge router that selects a small, task-relevant route instead of loading the whole
  corpus;
- common engineering and evidence baselines;
- domain guidance for Swift, SwiftUI, concurrency, networking, persistence, security, lifecycle,
  accessibility, release, testing, and related iOS concerns;
- an advisory command guard and build-surface inspection;
- explicit risk/plan routing and bounded protection sessions for Git worktrees;
- optional namespaced skills (`ioslib-*`) that index the same versioned documents;
- duplicate detection that disables only exact, explicitly mapped matches from a revalidated source;
- transactional installation, ownership receipts, collision checks, safe update, and conservative
  uninstall paths.

It is not a compiler, a test runner, a kernel sandbox, a backup system, a Git hosting service, or a
guarantee that an AI agent or Codex client will obey every instruction. The protection session is
post-mutation detection plus an admission contract; it does not intercept arbitrary processes or
make transient writes impossible. No software can honestly provide a 100% guarantee against every
host, client, OS, user, tool, or model failure.

The safe claim is narrower and useful: when the selected entrypoint is actually loaded, the package
provides versioned guidance, explicit boundaries, fail-closed installation checks, and evidence
about what the library observed. Unknown, partial, stale, or unavailable evidence must be reported;
it must never be represented as a clean PASS.

## 2. Non-negotiable authority and safety rules

Before any project action, the Codex agent must apply these rules:

1. User instructions and explicit safety limits are highest priority.
2. The client/project's own `AGENTS.md` and more-specific instructions remain authoritative for
   project behavior. This library is additive and must not silently replace or weaken them.
3. Library text never grants permission to run builds, tests, Simulator, UI automation, Instruments,
   network, dependency, signing, release, Git, destructive, or external-communication commands.
   Those permissions come from the user and current project rules.
4. Inspect an absolute path before writing it. Never install into a client repository, its `.git`
   directory, a source checkout, a package cache, or an unknown destination.
5. Start with `reference` mode. Use `full` only after an explicit decision that the host's skill
   discovery path is known and the exact dry-run preflight has been reviewed.
6. Stop on a failed preflight, collision, symlink/path escape, ownership mismatch, malformed state,
   missing canonical identity, or uncertain Codex activation. Do not convert a failed check into a
   best-effort install.
7. Preserve the archive and the old versioned payload until a fresh Codex session has verified the
   new deployment. The generated runtime is not the backup.

## 3. Deployment choices

There are two supported ways to use the library. They can expose the same versioned knowledge and
runtime behavior, but their operator mechanics differ:

### A. Installer deployment

`install_global.py` performs a read-only preflight, validates boundaries and collisions, publishes
the selected runtime transactionally, writes an ownership descriptor/receipt, and supports the
matching `sync_global.py` and conservative `uninstall_global.py` flows. It automates filesystem
publication; it does not configure an already-running Codex process or change a Desktop launcher.

The installer gives operational safety and repeatability, not extra AI authority. A fresh process
must still use the installed `CODEX_HOME` and must actually read the global entry block.

### B. Manual unpack and connection

The operator keeps the archive in a versioned external directory, runs the read-only
`MANUAL_SHIM/bin/manual_preflight.py`, connects the global block, and verifies the same descriptor,
runtime, state boundary, and fresh-session entry. It does not run the installer. This minimizes
automation, but the operator must perform and record the publication steps accurately.

Read [`MANUAL_DEPLOYMENT.md`](MANUAL_DEPLOYMENT.md) in full for the manual procedure. Merely
extracting the archive into a parent folder does not activate it for every project.

### What is equal and what is not

After successful activation, both paths use the same:

- version-pinned knowledge tree and runtime implementation;
- `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` first-entry contract;
- project-local precedence and command-authority boundary;
- `reference` behavior or the same explicitly selected `ioslib-*` skills;
- profile, review, protection-session, state, and evidence semantics.

They are not mechanically identical. The installer supplies transactional publication and ownership
checks. Manual deployment supplies lower automation but requires the operator to reproduce those
checks. If the global block is not connected or the Codex process uses a different `CODEX_HOME`,
neither path is active, regardless of where the files are stored.

## 4. Archive layout

The extracted archive root is the versioned release directory. Important entrypoints are:

| Path | Purpose |
| --- | --- |
| `README.md` | This complete handoff and deployment contract |
| `QUICKSTART.md` | Short operational sequence |
| `MANUAL_DEPLOYMENT.md` | Full manual publication/update/reversal procedure |
| `install_global.py` | Transactional installer; default mode is `reference` |
| `sync_global.py` | Safe update of unchanged installer-owned assets |
| `uninstall_global.py` | Dry-run/ownership-aware removal |
| `validate_package.py` | Structural, manifest, namespace, and evidence validator |
| `validate_global_install.py` | Validation of an installed ownership descriptor |
| `MANUAL_SHIM/bin/manual_preflight.py` | Read-only manual deployment preflight/receipt tool |
| `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` | First-entry route selector for every covered iOS task |
| `GLOBAL_CODEX/runtime/bin/ios_ai.py` | Release runtime CLI inside the payload |
| `GLOBAL_CODEX/skills/ioslib-*` | 60 optional namespaced skills for `full` mode |
| `tests/run_all.py` | Synthetic package regression runner |
| `GLOBAL_MANIFEST.json` | Release identity, inventory, and observed evidence |
| `PACKAGE_FILE_MANIFEST.json` | File hashes used to detect package drift |
| `PROJECT_REFERENCE_OPT_IN.md` | No-install advisory evaluation path |

The package must not contain `.git`, a runtime generated from a host, bytecode caches, symlinks, or
client source. Do not add those items to a redistributed archive.

## 5. First use on a clean Mac: recommended installer path

The safest portable first use is a dedicated area that is not inside a client Git repository. The
following commands are templates: replace both placeholders with inspected absolute paths. Keep
the extracted release and the active Codex area separate.

```bash
set -euo pipefail

LIB_ROOT=/ABSOLUTE/PATH/TO/EXTRACTED/V5.4/RELEASE
AREA_ROOT=/ABSOLUTE/PATH/TO/DEDICATED/CODEX-IOS-AREA

# The operator creates/approves this dedicated area. It must not be a client Git root.
export CODEX_HOME="$AREA_ROOT"

python3 "$LIB_ROOT/validate_package.py"
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --use-source-in-place \
  --mode reference \
  --dry-run

# Inspect the dry-run output. Only then publish the exact same reference profile.
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --use-source-in-place \
  --mode reference

python3 "$LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
python3 "$AREA_ROOT/ios-engineering-shim/bin/ios_ai.py" doctor
```

`--use-source-in-place` keeps the hash-verified release as the immutable knowledge root and writes
only generated runtime state to the selected area. If a copied runtime is required, omit that flag
and review the resulting descriptor before use; never assume a guessed copy is correct.

The installer does not set the environment of an already-running Codex desktop process. The
Codex process that opens projects must be launched/configured with the same effective
`CODEX_HOME`, or restarted after that environment is configured. A shell `export` affects commands
started from that shell; it cannot retroactively change a parent desktop application's environment.

## 6. Current Mac: canonical AIZenflowDocumentation profile

The repository `MArtem/AIZenflowDocumentation` is the sole approved Git-root exception in this
release. Its versioned source remains under `reusable/ios-engineering-library/v5.4`. Its generated
runtime may exist only at the separate ignored subtree:

```text
/Users/Artem/.zenflow/worktrees/documentation-vault/.codex-runtime/ios-engineering
```

The exact repository root and exact remote origin are verified by the installer. `.git`,
`reusable/`, and documentation/source files are never installation targets. This exception does not
extend to another repository, a nested subtree, a client project, or a different remote.

On the current Mac, with all paths inside the user's approved `.zenflow` area:

```bash
set -euo pipefail

DOCS_ROOT=/Users/Artem/.zenflow/worktrees/documentation-vault
LIB_ROOT="$DOCS_ROOT/reusable/ios-engineering-library/v5.4"
AREA_ROOT="$DOCS_ROOT/.codex-runtime/ios-engineering"

export CODEX_HOME="$AREA_ROOT"

python3 "$LIB_ROOT/validate_package.py"
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --canonical-repository-root "$DOCS_ROOT" \
  --allow-canonical-repository-runtime \
  --use-source-in-place \
  --mode reference \
  --dry-run

# Review that the destination is exactly AREA_ROOT and the origin is the approved repository.
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --canonical-repository-root "$DOCS_ROOT" \
  --allow-canonical-repository-runtime \
  --use-source-in-place \
  --mode reference

python3 "$LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
python3 "$AREA_ROOT/ios-engineering-shim/bin/ios_ai.py" doctor
```

Do not copy the runtime into `reusable/`, into `.git/`, or into any app directory. Keep the
versioned source and the generated runtime separate so Git remains the recovery source and the
runtime remains disposable/regenerable. The repository `.gitignore` excludes `.codex-runtime/`.

## 7. Full mode and optional skills

`reference` is the default and normally provides the complete knowledge route and runtime without
installing the 60 optional skills into a host skill namespace. This is the preferred starting point
because it changes less host state.

`full` is explicit opt-in. It installs only namespaced `ioslib-*` skills under the selected
portable area's `skills` directory (or the explicitly accepted destination). It does not overwrite
generic skills and it does not make every skill mandatory. Use a matching preflight ID:

```bash
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --use-source-in-place \
  --mode full \
  --dry-run

# Replace the placeholder with the exact preflight_id from the immediately preceding output.
python3 "$LIB_ROOT/install_global.py" \
  --portable-area "$AREA_ROOT" \
  --use-source-in-place \
  --mode full \
  --preflight-id <PREFLIGHT_ID>

python3 "$LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
```

### Existing reference installation: explicit reference → full migration

Do not rerun `install_global.py` against a registered area. For an existing managed `reference`
installation, use the registered installation's `sync_global.py`, inspect its dry-run, and pass the
ID produced by that same dry-run to the publishing command:

```bash
python3 "$LIB_ROOT/sync_global.py" \
  --codex-home "$AREA_ROOT" --mode full --dry-run

# Copy the exact preflight_id from the immediately preceding output.
python3 "$LIB_ROOT/sync_global.py" \
  --codex-home "$AREA_ROOT" --mode full --preflight-id <PREFLIGHT_ID_FROM_SYNC_DRY_RUN>

python3 "$LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
```

The same dry-run/ID pair is required for an existing `full` update. Installer preflight IDs are
not interchangeable with sync IDs, and a fresh empty area still uses `install_global.py`.

Do not use `full` merely to increase context size. Load the router first and only the relevant
route. An unavailable skill, subagent, connector, or review provider must be reported as
unavailable; the library must never simulate independent evidence.

## 8. What the active Codex must read

After installation or manual connection, the first fresh Codex task must read:

1. `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md`;
2. `00_META/START_HERE.md`;
3. `GLOBAL_CODEX/runtime/core/QUALITY_STANDARD.md`;
4. `GLOBAL_CODEX/runtime/core/EVIDENCE_AND_VERIFICATION_POLICY.md`;
5. only the smallest route selected by the task and repository evidence.

For ordinary implementation, use one matching deep playbook and the affected numbered section.
For review, use the repository review workflow and affected domain. For cross-domain work, use at
most two supporting routes unless the task explicitly justifies more. For unclear or unsupported
work, stop with `review_required`.

The project-local rules, task overrides, user instructions, and available tools remain the actual
authority. The global block is an entrypoint, not a license to bypass them.

## 9. Duplicate knowledge handling

On a clean host, no duplicate source exists and nothing is disabled. On a host with an existing
knowledge library, duplicate handling is opt-in and exact-only:

```bash
IOS_AI="$AREA_ROOT/ios-engineering-shim/bin/ios_ai.py"

python3 "$IOS_AI" --state-root "$AREA_ROOT/ios-engineering-state" \
  profile status --source-root /ABSOLUTE/PATH/TO/EXTERNAL/KNOWLEDGE

python3 "$IOS_AI" --state-root "$AREA_ROOT/ios-engineering-state" \
  profile build \
  --source-root /ABSOLUTE/PATH/TO/EXTERNAL/KNOWLEDGE \
  --activate --write
```

The external source must be explicitly supplied and revalidated. Only an exact relative-path and
SHA-256 match, or an explicitly provided exact layout mapping, can become
`disabled_exact_duplicates`. Similar, partial, stale, missing, malformed, or changed material is
not disabled. The active release remains the selected source in `INSTALLATION.json`; a persisted
candidate or arbitrary diagnostic directory is never adopted automatically.

This avoids both dangerous suppression and accidental double authority: the package is complete
on every host, while exact duplicates can be recorded as not required on that host. The profile is
metadata, not permission to skip the router or to ignore project-local instructions.

## 10. Runtime operations

Use the installed shim, not a guessed path inside a client project:

```bash
IOS_AI="$AREA_ROOT/ios-engineering-shim/bin/ios_ai.py"

python3 "$IOS_AI" doctor
python3 "$IOS_AI" context --repo /ABSOLUTE/PATH/TO/PROJECT --ensure
python3 "$IOS_AI" guard --command "git status --short"
python3 "$IOS_AI" build-phases --repo /ABSOLUTE/PATH/TO/PROJECT
python3 "$IOS_AI" declared-policy --repo /ABSOLUTE/PATH/TO/PROJECT
python3 "$IOS_AI" plan --repo /ABSOLUTE/PATH/TO/PROJECT \
  --task "<task description>" --risk R3 --domain concurrency
```

These operations are advisory or observational. A command classified as read-only is not proof
that the surrounding shell, process, or user action is harmless. Unknown commands, shell
operators, redirection/substitution, interpreters, network/dependency/release tools, and mutating
Git forms are not silently classified as safe.

For an authorized write task, protection is explicit and scoped:

```bash
python3 "$IOS_AI" protect begin \
  --repo /ABSOLUTE/PATH/TO/PROJECT \
  --allow Sources/Feature/Foo.swift \
  --task "Fix Foo behavior"

# Make only the authorized change, then use the returned session ID.
python3 "$IOS_AI" protect verify \
  --repo /ABSOLUTE/PATH/TO/PROJECT --session <SESSION_ID>
python3 "$IOS_AI" protect close \
  --repo /ABSOLUTE/PATH/TO/PROJECT --session <SESSION_ID>
```

Git staging/commit declarations are separate from file scope (`--git-transition stage` or
`commit`). They do not authorize unrelated files, config, refs, branch switches, release, or
network operations. There is one writer session per Git common directory; linked worktrees share
that slot. Independent clones have independent Git common directories.

## 11. Safe update, rollback, and uninstall

Keep every release in a new versioned directory. Do not overwrite the old release in place.
For an installer deployment created with `--use-source-in-place`, run the update command from
the new release directory. `sync_global.py` treats the directory containing that script as the
incoming release root, switches the selector and managed runtime to it, and leaves the previously
registered source directory and external state untouched. A fixed release can also coordinate a
rollback by loading a separately verified historical release with `--release-root`; the historical
release's old sync must not be substituted for that coordinator.

For an installer-managed deployment:

```bash
NEW_LIB_ROOT=/ABSOLUTE/PATH/TO/NEW/VERSIONED/RELEASE
python3 "$NEW_LIB_ROOT/sync_global.py" --codex-home "$AREA_ROOT" --dry-run
# Review the output, then run the matching update command only when no ownership conflict exists.
python3 "$NEW_LIB_ROOT/sync_global.py" --codex-home "$AREA_ROOT"
python3 "$NEW_LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
```

`sync_global.py` updates only unchanged managed assets. A local modification is a conflict and is
preserved. Its dry-run must show the new `source`, `content_root`, `version`, and
`source_tree_sha256` before publication. Keep the previous archive/release until a fresh session
passes. If an update is uncertain, stop and use a fresh dedicated Codex area rather than forcing
ownership. Do not treat `--dry-run` as an update or rollback.

To return to the preserved previous source, stop Codex and use the fixed incoming release's sync
as the coordinator for the verified old payload. This is required when the old release's own sync
rejects a source-in-place registry that points at a newer release:

```bash
FIXED_LIB_ROOT=/ABSOLUTE/PATH/TO/FIXED/RELEASE
OLD_LIB_ROOT=/ABSOLUTE/PATH/TO/PREVIOUS/VERSIONED/RELEASE
python3 "$FIXED_LIB_ROOT/sync_global.py" --release-root "$OLD_LIB_ROOT" \
  --codex-home "$AREA_ROOT" --dry-run
# Reference profile: publish without an ID after reviewing the dry-run.
python3 "$FIXED_LIB_ROOT/sync_global.py" --release-root "$OLD_LIB_ROOT" \
  --codex-home "$AREA_ROOT"
# Full profile: use the same command with
# --mode full --preflight-id <PREFLIGHT_ID_FROM_ROLLBACK_DRY_RUN>.
python3 "$OLD_LIB_ROOT/validate_global_install.py" --codex-home "$AREA_ROOT"
```

To inspect removal before changing anything:

```bash
python3 "$LIB_ROOT/uninstall_global.py" --codex-home "$AREA_ROOT" --dry-run
python3 "$LIB_ROOT/uninstall_global.py" --codex-home "$AREA_ROOT" --yes
```

Uninstall removes only manifest-owned, unchanged artifacts. Unknown or modified files are preserved
or cause a hard stop. Manual deployment has its own reversal procedure in
[`MANUAL_DEPLOYMENT.md`](MANUAL_DEPLOYMENT.md); do not improvise deletion of a global AGENTS file,
state root, or skill directory.

The recovery plan is simple: preserve this archive, preserve the versioned Git source, retain the
old descriptor/receipt when changing versions, and regenerate the ignored runtime only after a
fresh preflight. The runtime is not the source of truth or a backup.

## 12. Validation and evidence

Run package checks before deployment:

```bash
python3 "$LIB_ROOT/validate_package.py"
IOSLIB_TEST_TMP_ROOT=/ABSOLUTE/PATH/TO/AUTHORIZED/FIXTURES \
  IOSLIB_LEGACY_ARCHIVE=/ABSOLUTE/PATH/TO/HISTORICAL-V6.zip \
  python3 -B "$LIB_ROOT/tests/run_all.py" --serial
```

Choose an authorized fixture root before running. Positive external-deployment cases need
a root outside every Git repository; never bypass Git admission to obtain PASS. The legacy
round-trip test requires the historical `.6` ZIP with SHA-256
`57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27`.
An omitted archive is explicitly NOT_RUN; a supplied missing, relative, or mismatched archive
fails before an environment skip. Published manual shell-command construction and syntax
are tested separately, without deployment, in both reference and full modes.

The shipped tests use synthetic repositories and Codex homes. They do not prove behavior of every
Codex Desktop build, Mac configuration, Xcode project, physical iOS device, host skill index, or
external connector. They are regression evidence for the package's own boundaries and scripts.

The V5.4 release inventory is recorded in `GLOBAL_MANIFEST.json` and the exact file hashes in
`PACKAGE_FILE_MANIFEST.json`. The maintained evidence currently records:

- 51 knowledge sections;
- 288 deep playbooks;
- 60 namespaced optional skills;
- 199 synthetic tests, observed as 199 passed, 0 failed, and 0 skipped in the release working tree;
- structural package validation with no validator errors at the time of release preparation.

These numbers describe shipped inventory and observed checks; they are not a claim that every
project task is correct or that the host is automatically configured.

## 13. Troubleshooting

| Symptom | Meaning | Safe response |
| --- | --- | --- |
| `canonical-baseline-unavailable` | The canonical documentation checkout could not be used | Stop; do not claim the current canonical revision was applied. Use a tracked portable snapshot or restore the checkout. |
| Destination is inside a Git repository | The selected host area is not an admitted runtime boundary | Choose a dedicated non-Git area, or use only the exact `AIZenflowDocumentation/.codex-runtime/ios-engineering` exception with exact origin verification. |
| `CODEX_HOME` mismatch | The process and installer target differ | Stop/restart or relaunch Codex with the descriptor's exact `CODEX_HOME`; do not install a second guessed copy. |
| Existing or modified managed file | Ownership cannot be proven | Preserve it, inspect the receipt/hash, and use a fresh area if uncertain. Never overwrite with `cp`, symlinks, or a forced flag. |
| Full-mode preflight ID rejected | The host state or requested paths changed after dry-run | Run a new dry-run, inspect it, and use its exact ID. |
| Profile is invalid/overlap only | Source changed, mapping is not exact, or source was not explicitly selected | Keep all material active; rebuild only from an explicit, revalidated source root. |
| `doctor` passes but a task ignores the library | Presence is not activation evidence | Verify the fresh Codex process's effective `CODEX_HOME`, global AGENTS block, `INSTALLATION.json`, and first-entry router read. |
| A command would change external state | The library cannot authorize it | Ask the user or apply project rules; run only after explicit authorization and appropriate evidence planning. |

## 14. License and redistribution

This V5.4 package is an internal engineering release unless a separate license/NOTICE/SPDX file is
provided with it. Do not redistribute the corpus, prompts, or bundled skills outside the authorized
organization until ownership and licensing are confirmed. Keeping a private archive for recovery is
compatible with the intended internal workflow; retain the release identity and SHA-256 with it.

## 15. Codex handoff checklist

When another Codex App receives this archive, it should report these facts before any project edit:

1. archive path and SHA-256 were identified;
2. `validate_package.py` passed;
3. deployment choice is `reference`, `full`, or manual, with the user's explicit scope;
4. destination is absolute, approved, and outside client Git roots unless it is the exact canonical
   exception;
5. dry-run/preflight was reviewed before mutation;
6. `INSTALLATION.json`, `doctor`, and the effective Codex process `CODEX_HOME` agree;
7. `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` was read in a fresh task/session;
8. project-local instructions and user permissions remain in force;
9. any missing tool, unavailable subagent, skipped test, partial observation, or residual risk is
   reported plainly.

The context-transfer rule for a handoff is:

> перечитать весь актуальный набор документации и правил для этого worktree и task-контекста

Only after this checklist is satisfied should the agent claim that the library is active. A file's
presence, a successful installer exit, or a green synthetic suite alone is not enough.

## Related documents

- [`QUICKSTART.md`](QUICKSTART.md) — compact command sequence
- [`MANUAL_DEPLOYMENT.md`](MANUAL_DEPLOYMENT.md) — complete no-installer deployment and reversal
- [`GLOBAL_CODEX/KNOWLEDGE_ROUTER.md`](GLOBAL_CODEX/KNOWLEDGE_ROUTER.md) — task route selector
- [`GLOBAL_CODEX/AGENTS.global.block.md`](GLOBAL_CODEX/AGENTS.global.block.md) — global entry block
- [`CAPABILITY_MATRIX.md`](CAPABILITY_MATRIX.md) — capability/activation boundaries
- [`REVIEW_READY_VALIDATION_REPORT.md`](REVIEW_READY_VALIDATION_REPORT.md) — executed evidence
- [`REVIEW_FINDINGS_MATRIX.md`](REVIEW_FINDINGS_MATRIX.md) — findings mapped to fixes/checks
- [`00_META/CURRENT_OFFICIAL_REFERENCES.md`](00_META/CURRENT_OFFICIAL_REFERENCES.md) — selected primary references
