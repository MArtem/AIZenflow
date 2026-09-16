# Manual unpack and connection — V5.4 review candidate

This is the first supported deployment path. It uses the checked-out release directly and does
not run `install_global.py`, `sync_global.py`, or `uninstall_global.py`. The installer path is
the second deployment path and automates the same active payload layout. For the canonical
`MArtem/AIZenflowDocumentation` repository, both paths may use only its exact
`.codex-runtime/ios-engineering` subtree as the active runtime.

## What parity means

After successful manual verification, both paths use the same:

- version-pinned knowledge tree and `GLOBAL_CODEX/runtime` implementation;
- JSON-selected relocatable runtime entrypoint, external state boundary and advisory authority model;
- `reference` behavior, or the same namespaced `ioslib-*` skills in `full` mode;
- project-local precedence, review/risk routing, protection-session semantics and subagent limits.

They do not have identical operator mechanics. The installer records ownership and performs
transactional preflight/rollback. The manual path has no hidden rollback agent: the operator runs
the shipped read-only `manual_preflight.py`, copies only to declared external paths, creates the
same descriptor, and disables it by reversing only verified changes. A failed preflight is a hard
stop; it is never permission to overwrite an existing target.

## Important activation boundary

Putting this directory under `/Users/Artem/.zenflow` or any other parent folder does not by
itself make Codex load it for every nested repository. Codex instruction discovery is based on
the active global instruction scope and project roots; an unrelated parent filesystem directory
is not a universal include mechanism. To activate the manual deployment, the operator must:

1. keep the release source in the versioned canonical repository or outside every client repository;
2. identify the Codex process's effective `CODEX_HOME`. For the canonical profile it must be
   `<AIZenflowDocumentation>/.codex-runtime/ios-engineering`;
3. connect the block in `GLOBAL_CODEX/AGENTS.global.block.md` to that active global AGENTS file;
4. start/restart Codex with that same effective `CODEX_HOME`.

If the chosen active area is under `/Users/Artem/.zenflow`, that is a deliberate host choice and
the Codex process must actually start with that area as `CODEX_HOME`. The canonical exception is
valid only when the repository root and remote are verified. A fresh project opened by a process
using another Codex home is not covered. Do not claim universal future-project adoption until a
fresh session proves the actual first-entry flow.

## Operator procedure

Perform the following only after checking the absolute paths and release SHA-256. These are
manual filesystem operations; the package does not execute them.
The selected Codex home must already be an inspected directory (create only that explicitly
approved empty directory on a clean host). Stop the Codex process during publication. Select
`reference` or `full` once; every step below uses the same mode and skills path.

```bash
set -euo pipefail

# Clean-host profile: use two separately inspected absolute destinations. This profile does not
# contain canonical-repository flags and does not assume that CODEX_HOME is correct.
LIB_ROOT=/ABSOLUTE/PATH/TO/HASH-VERIFIED-VERSIONED-RELEASE
ACTIVE_CODEX_HOME=/ABSOLUTE/PATH/TO/DEDICATED-CODEX-HOME
SHIM_ROOT="$ACTIVE_CODEX_HOME/ios-engineering-shim"
STATE_ROOT="$ACTIVE_CODEX_HOME/ios-engineering-state"
MODE=reference # set full explicitly when namespaced skill discovery is wanted
SKILLS_ROOT="$ACTIVE_CODEX_HOME/skills"
PREFLIGHT_ARGS=(--release-root "$LIB_ROOT" --codex-home "$ACTIVE_CODEX_HOME"
  --state-root "$STATE_ROOT" --skills-root "$SKILLS_ROOT" --mode "$MODE")

# Reference mode: read-only preflight must pass before any destination is created. Keep this
# JSON until the final receipt is emitted: receipt_seed is the only accepted source for the
# original AGENTS hash/mode when AGENTS already existed before this deployment.
PREFLIGHT_TMP="$(mktemp "$ACTIVE_CODEX_HOME/.ioslib-preflight.XXXXXX")"
if ! python3 -B "$LIB_ROOT/MANUAL_SHIM/bin/manual_preflight.py" \
    "${PREFLIGHT_ARGS[@]}" > "$PREFLIGHT_TMP"; then
  rm -f "$PREFLIGHT_TMP"
  echo "Preflight failed; no manual deployment step is authorized." >&2
  exit 2
fi
cat "$PREFLIGHT_TMP"
ORIGINAL_AGENTS_SHA256="$(python3 -B -c 'import json,sys; value=json.load(open(sys.argv[1]))["receipt_seed"]["original_agents_sha256"]; print(value if value is not None else "null")' "$PREFLIGHT_TMP")"
ORIGINAL_AGENTS_MODE="$(python3 -B -c 'import json,sys; value=json.load(open(sys.argv[1]))["receipt_seed"]["original_agents_mode"]; print(value if value is not None else "null")' "$PREFLIGHT_TMP")"
AGENTS_FILE="$(python3 -B -c 'import json,sys; print(json.load(open(sys.argv[1]))["paths"]["agents_file"])' "$PREFLIGHT_TMP")"
if [ "$ORIGINAL_AGENTS_SHA256" = "null" ]; then
  RECEIPT_ORIGINAL_ARGS=(--original-agents-absent)
  ORIGINAL_AGENTS_SNAPSHOT=""
else
  ORIGINAL_AGENTS_SNAPSHOT="$ACTIVE_CODEX_HOME/.ioslib-agents-original"
  if [ -e "$ORIGINAL_AGENTS_SNAPSHOT" ] || [ -L "$ORIGINAL_AGENTS_SNAPSHOT" ]; then
    if [ -L "$ORIGINAL_AGENTS_SNAPSHOT" ] || [ ! -f "$ORIGINAL_AGENTS_SNAPSHOT" ] || \
       ! cmp -s "$AGENTS_FILE" "$ORIGINAL_AGENTS_SNAPSHOT"; then
      rm -f "$PREFLIGHT_TMP"
      echo "Existing AGENTS snapshot is not an exact verified match; stop before publication." >&2
      exit 3
    fi
  elif ! cp -p "$AGENTS_FILE" "$ORIGINAL_AGENTS_SNAPSHOT"; then
    rm -f "$PREFLIGHT_TMP"
    echo "Could not preserve the original AGENTS snapshot; stop before publication." >&2
    exit 3
  fi
  RECEIPT_ORIGINAL_ARGS=(--original-agents-sha256 "$ORIGINAL_AGENTS_SHA256" --original-agents-mode "$ORIGINAL_AGENTS_MODE" --original-agents-snapshot "$ORIGINAL_AGENTS_SNAPSHOT")
fi

# Prepare BOTH metadata outputs from the successful preflight before changing the target.
# Do not rerun an update preflight in a partially published fresh installation.
DESCRIPTOR_TMP="$(mktemp "$ACTIVE_CODEX_HOME/.ioslib-descriptor.XXXXXX")"
STATE_MARKER_TMP="$(mktemp "$ACTIVE_CODEX_HOME/.ioslib-state-marker.XXXXXX")"
python3 -B -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["ok"]; print(json.dumps(d["descriptor"],indent=2,sort_keys=True))' "$PREFLIGHT_TMP" > "$DESCRIPTOR_TMP"
python3 -B -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["ok"]; print(json.dumps(d["state_marker"],indent=2,sort_keys=True))' "$PREFLIGHT_TMP" > "$STATE_MARKER_TMP"

# Fresh activation requires an absent shim. The non-zero mkdir/cp checks are deliberate:
# a target that appeared after preflight is a hard stop, not a merge opportunity.
if [ -e "$SHIM_ROOT" ]; then
  if [ -L "$SHIM_ROOT" ] || [ ! -d "$SHIM_ROOT" ]; then
    echo "Shim is not a regular managed directory; stop and rerun preflight." >&2
    exit 3
  fi
else
  if ! mkdir "$SHIM_ROOT"; then
    echo "Shim appeared or could not be created; stop and rerun preflight." >&2
    exit 3
  fi
fi
if [ ! -e "$SHIM_ROOT/bin" ] && ! mkdir "$SHIM_ROOT/bin"; then
  echo "Shim bin directory could not be created; stop." >&2
  exit 3
fi
if [ -L "$SHIM_ROOT/bin" ] || [ ! -d "$SHIM_ROOT/bin" ]; then
  echo "Shim bin path is unsafe; stop." >&2
  exit 3
fi
if ! cp -n "$LIB_ROOT/MANUAL_SHIM/bin/ios_ai.py" "$SHIM_ROOT/bin/ios_ai.py"; then
  echo "Launcher copy failed; leave the transitional target for reviewed recovery." >&2
  exit 3
fi
if ! cmp -s "$LIB_ROOT/MANUAL_SHIM/bin/ios_ai.py" "$SHIM_ROOT/bin/ios_ai.py"; then
  echo "Launcher verification failed; do not publish the descriptor." >&2
  exit 3
fi
# Publish the prepared descriptor only into an absent path.
if ! mv -n "$DESCRIPTOR_TMP" "$SHIM_ROOT/INSTALLATION.json" || [ -e "$DESCRIPTOR_TMP" ]; then
  rm -f "$DESCRIPTOR_TMP"
  echo "Descriptor destination appeared or publication failed; stop." >&2
  exit 3
fi

# Still only after a passing preflight: create the private library-owned state boundary and
# obtain its marker from the read-only verifier. An existing non-empty unmarked state root is a
# conflict and must not be adopted implicitly.
if [ -e "$STATE_ROOT" ]; then
  if [ -L "$STATE_ROOT" ] || [ ! -d "$STATE_ROOT" ]; then
    echo "State root is not a regular managed directory; stop." >&2
    exit 3
  fi
else
  if ! mkdir "$STATE_ROOT"; then
    echo "State root appeared or could not be created; stop." >&2
    exit 3
  fi
fi
chmod 700 "$STATE_ROOT"
# Use the marker prepared before publication, not an update check without a receipt.
STATE_MARKER="$STATE_ROOT/.ioslib-state-owned.json"
if [ -e "$STATE_MARKER" ]; then
  if [ -L "$STATE_MARKER" ] || [ ! -f "$STATE_MARKER" ] || ! mv -f "$STATE_MARKER_TMP" "$STATE_MARKER"; then
    rm -f "$STATE_MARKER_TMP"
    echo "Existing state marker is not safely replaceable; stop." >&2
    exit 3
  fi
elif ! mv -n "$STATE_MARKER_TMP" "$STATE_MARKER" || [ -e "$STATE_MARKER_TMP" ]; then
  rm -f "$STATE_MARKER_TMP"
  echo "State-marker destination appeared or publication failed; stop." >&2
  exit 3
fi
chmod 600 "$STATE_ROOT/.ioslib-state-owned.json"

# Preserve the exact preflighted user text and append one managed block. Any later receipt
# emission verifies this composition against ORIGINAL_AGENTS_SNAPSHOT.
if ! printf '\n' >> "$AGENTS_FILE" || ! cat "$LIB_ROOT/GLOBAL_CODEX/AGENTS.global.block.md" >> "$AGENTS_FILE"; then
  echo "AGENTS publication failed; stop before receipt publication." >&2
  exit 3
fi

```

The descriptor is the activation pointer. It contains the exact release root, runtime path,
state root, release/protection identities, and source-tree package identity hash. The shim refuses to run if it is
missing, malformed, symlinked, or points to a runtime outside that release. Copy the explanatory
`MANUAL_SHIM/INSTALLATION.md` beside it only as documentation; do not use its old placeholder
paths as an active configuration.

The first shell block extracts the effective `agents_file`, makes the recoverable original snapshot
without overwriting an existing non-matching path, and appends the complete global block exactly
once. If `AGENTS.override.md` is non-empty, it is the
effective destination even when a caller supplied the conventional `AGENTS.md` path. The preflight
refuses an existing incomplete or duplicated block. Do not replace the file or copy the block into a
client repository. A later receipt check compares the bytes before the managed block with the saved
snapshot; an update must retain that snapshot until its new receipt is published.

For `full` mode only, first verify the host's actual global skill discovery directory. Then copy
the same namespaced directories and create the generated installation reference expected by each
skill:

```bash
if [ "$MODE" = full ]; then
# The initial full preflight already checked these targets. Existing targets are still refused.
if [ ! -d "$SKILLS_ROOT" ]; then mkdir "$SKILLS_ROOT"; fi
SKILL_STAGE="$(mktemp -d "$SKILLS_ROOT/.ioslib-skill-stage.XXXXXX")"
cleanup_skill_stage() { rm -rf "$SKILL_STAGE"; }
trap cleanup_skill_stage EXIT
for skill in "$LIB_ROOT"/GLOBAL_CODEX/skills/ioslib-*; do
  name="$(basename "$skill")"
  if [ -e "$SKILLS_ROOT/$name" ]; then
    echo "Skill destination appeared; stop without overwriting it: $name" >&2
    exit 3
  fi
  mkdir "$SKILL_STAGE/$name"
  if ! ditto "$skill"/. "$SKILL_STAGE/$name"/; then
    echo "Skill staging failed; no publication for $name." >&2
    exit 3
  fi
  cp "$LIB_ROOT/MANUAL_SHIM/INSTALLATION.md" "$SKILL_STAGE/$name/references/INSTALLATION.md"
  if ! mv -n "$SKILL_STAGE/$name" "$SKILLS_ROOT/$name" || [ -e "$SKILL_STAGE/$name" ]; then
    echo "Skill publication failed or destination appeared: $name" >&2
    exit 3
  fi
done
fi
```

### Current-host canonical profile

Use this separate variable/preflight profile only after verifying the exact repository root and
approved origin. It is the sole Git-root exception; it does not authorize a runtime inside an app
or any other repository. Replace only the clean-host profile variables above with:

```bash
CANONICAL_REPOSITORY_ROOT=/ABSOLUTE/PATH/TO/AIZenflowDocumentation
LIB_ROOT="$CANONICAL_REPOSITORY_ROOT/reusable/ios-engineering-library/v5.4"
ACTIVE_CODEX_HOME="$CANONICAL_REPOSITORY_ROOT/.codex-runtime/ios-engineering"
SHIM_ROOT="$ACTIVE_CODEX_HOME/ios-engineering-shim"
STATE_ROOT="$ACTIVE_CODEX_HOME/ios-engineering-state"
MODE=reference
SKILLS_ROOT="$ACTIVE_CODEX_HOME/skills"
PREFLIGHT_ARGS=(--release-root "$LIB_ROOT" --codex-home "$ACTIVE_CODEX_HOME"
  --state-root "$STATE_ROOT" --skills-root "$SKILLS_ROOT" --mode "$MODE"
  --canonical-repository-root "$CANONICAL_REPOSITORY_ROOT"
  --allow-canonical-repository-runtime)
```

Do not combine the profiles or infer the canonical path from an unset environment variable.

```bash
# Publish the small operator-owned receipt only after the descriptor, state marker, AGENTS
# block, and (for full mode) every namespaced skill have been independently reviewed. The first
# preflight JSON contains receipt_seed.original_agents_sha256 and original_agents_mode. If the
# effective AGENTS file did not exist then, use --original-agents-absent instead. The receipt is
# data for future ownership checks; it is not an installer and does not perform rollback.
RECEIPT_TMP="$(mktemp "$ACTIVE_CODEX_HOME/.ioslib-receipt.XXXXXX")"
if ! python3 -B "$LIB_ROOT/MANUAL_SHIM/bin/manual_preflight.py" \
    "${PREFLIGHT_ARGS[@]}" --emit-receipt \
    "${RECEIPT_ORIGINAL_ARGS[@]}" > "$RECEIPT_TMP"; then
  rm -f "$RECEIPT_TMP" "$PREFLIGHT_TMP"
  echo "Ownership receipt emission failed; do not publish the receipt." >&2
  exit 3
fi
if ! mv -n "$RECEIPT_TMP" "$SHIM_ROOT/.ioslib-managed.json" || [ -e "$RECEIPT_TMP" ]; then
  rm -f "$RECEIPT_TMP" "$PREFLIGHT_TMP"
  echo "Receipt destination appeared or publication failed; stop." >&2
  exit 3
fi
chmod 600 "$SHIM_ROOT/.ioslib-managed.json"
rm -f "$PREFLIGHT_TMP"
python3 -B "$LIB_ROOT/MANUAL_SHIM/bin/manual_preflight.py" "${PREFLIGHT_ARGS[@]}"
```

Do not copy a skill over an existing same-name directory unless its ownership and exact hash have
been reviewed. Existing generic or locally modified skills are conflicts, not duplicates to
overwrite. `reference` deliberately installs no bundled skills. Full-mode migration from an
already active managed `reference` shim is supported only after the explicit full preflight; a
full-to-reference downgrade is a disable/update decision and is not silently performed.

## Verify before first use

Run the relocatable shim with the same environment that Codex will use:

```bash
python3 "$SHIM_ROOT/bin/ios_ai.py" doctor
python3 "$SHIM_ROOT/bin/ios_ai.py" --state-root "$STATE_ROOT" guard --command "git status --short"
```

Confirm that `doctor` reports the descriptor-selected CLI version, the knowledge root is the
unpacked release, and the state root is outside all client repositories. Then start a fresh Codex session
and verify the actual instruction entry, not merely the presence of files. For the first pilot,
record the selected knowledge documents, review/subagent path, command authorization boundary and
any missing/partial observation. A prior session that already loaded instructions is not fresh
evidence.

## Update and disable

Manual update is a new, separately hash-verified payload in a new versioned external directory.
The safe update is a reviewed selector switch: stop Codex, retain the old payload, run preflight
against the new payload, verify that the existing shim and receipt are library-owned and unchanged,
copy the old `INSTALLATION.json` and `.ioslib-managed.json` to explicitly inspected backups, and
prepare BOTH new descriptor and state-marker outputs before publishing either. Back up and
replace the old receipt-verified launcher with the incoming launcher when its release changes.
Before the final new-release preflight,
move the old receipt to the inspected backup path so it cannot be mistaken for a receipt of the new
bytes; preserve an inspected copy of the original AGENTS file and supply its saved
`agents.original_*` values plus `--original-agents-snapshot <path>` to the new receipt emitter.
Replace the descriptor
only after its emitter exits successfully, then publish the new receipt last. If any replacement
fails, restore the descriptor and receipt backups before restarting Codex. Never overwrite a modified
launcher, descriptor, AGENTS file, or skill; use a fresh Codex home when any ownership check is uncertain.
Reference-to-full is an explicit migration: run the full preflight and publish each skill from a
same-filesystem staging directory as shown above. A full-to-reference change is not an in-place
skill deletion; disable the full layer through the exact removal procedure below, then perform a
fresh reference activation. Keep the old payload until a fresh session passes.

The manual path deliberately does not promise crash atomicity or automatic rollback. The operator
must record the old/new descriptor and receipt hashes, selected release SHA-256, and the exact paths
changed. If a command fails, stop; do not continue to the next publication step. A reference→full
migration is a new receipt publication after all namespaced skills are staged. A full→reference
rollback is performed through disable plus fresh reference activation; it never silently deletes a
skill tree.

For a reference→full migration or a full-mode update, the exact publication order is: run the new
`--mode full` preflight while the old descriptor/receipt and all old managed trees are still present;
emit the new descriptor and state marker to temporary files; copy both old metadata files to
explicitly inspected backups; replace the descriptor from its temporary file; replace the AGENTS
block only after its old receipt hash matches; replace the receipt-verified launcher from the new
release (retaining its backup); stage each incoming `ioslib-*` tree and replace only
the old receipt-owned tree (keeping a per-skill backup); publish the new state marker; move the old
receipt to a separate inspected stale-receipt path; then run `--mode full --emit-receipt`, supplying
the `agents.original_*` values from the old receipt backup, and publish the new receipt last. If any
step fails, keep Codex stopped and restore the descriptor, state marker, AGENTS block and skill
backups from the inspected records. The preflight must pass again before restart. The old payload
remains available throughout this sequence.

To disable, stop using the active Codex process, make a recoverable copy of the effective AGENTS
file, and remove only the managed global block after confirming its exact begin/end markers and
block hash. Remove the separator newline and trailing block newline added by activation as part
of that verified composition, restoring the exact original user bytes and mode. Compare with the
recorded original snapshot before reconnecting; if unrelated text differs, stop and preserve it
for manual review. If AGENTS originally did not exist, leave an empty file after removing the
verified composition. Do not trim arbitrary user whitespace or overwrite an old snapshot to
make a reconnect pass. Remove only the shim files and namespaced skills whose paths and hashes were recorded
by the operator; preserve unknown or modified entries. After removing verified skill files,
remove their now-empty directories bottom-up with `rmdir`, limited to directories derived from
the recorded skill paths. Do not remove the skills root or recursively delete a directory:
remaining unknown content must cause a stop. Empty leftover skill directories are not proof of
ownership and will correctly block a later fresh full activation. Leave the unpacked payload and external
state in place. If any file contains unrelated edits, use a reviewed manual merge; do not delete
session history or an entire directory as a shortcut. Afterward start a fresh Codex session and
verify that the library block is absent before declaring disable complete.

### A→B→A lifecycle acceptance

For a real isolated fixture, perform the documented sequence without repairing files between steps:

1. A — fresh `reference` activation: pass preflight, publish descriptor/state/AGENTS/receipt, then
   verify `doctor` and a fresh Codex first-entry route. Preserve the A payload and record descriptor
   and receipt hashes.
2. B — explicit `full` migration or a new release: run the full preflight while A is still active,
   preserve the A receipt, stage all `ioslib-*` trees, publish B descriptor and state marker, then
   emit/publish B receipt. Verify the actual routed skill/review path in a fresh session.
3. A — rollback: stop Codex, use the B receipt to remove only unchanged B-managed skill trees and
   the B global block/selector according to the disable procedure, then activate the preserved A
   payload in `reference` mode and publish a fresh A receipt. Verify the same A checks again.

The receipt proves ownership and unchanged bytes; it is not proof that Codex loaded the block. The
fresh-session first-entry check and the routed behavior check remain required evidence.

Manual lifecycle acceptance is pending until this sequence has run on an eligible isolated
host. The receipt records checked bytes and modes, not runtime adoption or a security boundary.
Neither method guarantees protection against every possible mistake.
