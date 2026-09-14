# iOS Engineering AI Library 2026 — V5.4 GLOBAL CODEX REVIEW READY

Self-contained global iOS/Swift knowledge and safety toolkit for Codex. This release is a **review candidate**, not an independently accepted or production-proven security boundary.

## Installation model

Two modes are supported and neither installs library infrastructure into a client repository:

- **`reference` (default installer mode):** installs/registers the runtime, external knowledge location, and a minimal managed global instruction block. It does **not** install the 60 skills into the global skill namespace. **It is not a passive/no-change mode:** it changes user-global Codex configuration.
- **Manual unpack/connection:** follow [`MANUAL_DEPLOYMENT.md`](MANUAL_DEPLOYMENT.md) to keep the unpacked payload in a versioned external directory, run the read-only preflight, and connect the same global instruction block without running an installer. Extraction alone does not activate global discovery; the active Codex home and fresh-session entrypoint must be verified.
- **No-install reference workflow:** for evaluation where global instructions must remain untouched, keep the extracted library outside the client repository and use `PROJECT_REFERENCE_OPT_IN.md`; this is manual advisory knowledge use, not an installed runtime gate.
- **`full` (explicit opt-in):** additionally installs the 60 bundled skills under the provider namespace **`ioslib-*`**. A matching `--dry-run` preflight ID is required before mutation.

Project-local and more-specific instructions remain authoritative for project conventions. Library knowledge is data/advice; it never grants permission to run build/test/network/Git/release commands.

Every installation also writes `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/INSTALLATION.json`. This machine-readable selector is the stable discovery point for the exact **Knowledge root**, runtime CLI, release/protection identities and external state root in both manual and installer layouts. `INSTALLATION.md` is explanatory documentation only.

The first-entry knowledge contract is [`GLOBAL_CODEX/KNOWLEDGE_ROUTER.md`](GLOBAL_CODEX/KNOWLEDGE_ROUTER.md). It selects a small route for ordinary implementation, review, and cross-domain tasks. Optional exact duplicate handling is explicit and lives in the external `knowledge-profile.json`; a clean installation has no external source and disables nothing.

## Explicit portable-area installer profile

For an isolated installer rehearsal, choose a dedicated area and make that area the active
`CODEX_HOME` for the Codex process before opening projects from it. This is an installer profile,
not a substitute for the manual path:

```bash
AREA_ROOT=/ABSOLUTE/PATH/TO/ios-codex-area
export CODEX_HOME="$AREA_ROOT"
python3 install_global.py --portable-area "$AREA_ROOT" --use-source-in-place --mode reference --dry-run
python3 install_global.py --portable-area "$AREA_ROOT" --use-source-in-place --mode reference
python3 validate_global_install.py --codex-home "$AREA_ROOT"
```

Use `--mode full` only when the host's skills discovery path is deliberately configured for the
area; the profile maps it to `$AREA_ROOT/skills` and never silently writes to the user's normal
`~/.agents/skills`. This profile does not set process environment variables, alter Desktop launch
configuration, install hooks, or guarantee discovery for a Codex process started with another
`CODEX_HOME`. A parent filesystem directory is not an automatic substitute for Codex's global or
repository-root instruction discovery.

Explicit destination overrides for this profile are accepted only when they remain lexically inside
the selected area; path-escape attempts fail before mutation.

The installer and this explicit profile share the same transactional layout and ownership rules.
That proves layout parity only after the active Codex process is verified to use the selected area;
it does not prove automatic adoption of arbitrary future Desktop/open/import projects.

## Safety model

The package deliberately separates three mechanisms:

- **Prevention/rejection before action:** transactional installer preflight, ownership/collision checks, symlink/path-containment checks, fail-closed state writes, and strict advisory command classification that refuses to mark unknown/mutating shell forms as read-only.
- **Detection after repository mutation:** protection sessions compare a complete baseline observation against later Git/worktree state and report unexpected path, dirty, protected, nested-repository, index, HEAD/tree, refs, branch, or local-config changes.
- **Advisory:** command guard, build-surface scan, risk routing, knowledge and review recommendations. They do not intercept an arbitrary OS process.

The protection layer is **not** a kernel sandbox, backup/recovery system, or transient-write monitor. Ignored files are not claimed protected unless they are actually reported by the observation model. Client source is not copied into the external cache.

## Validate the package first

```bash
python3 validate_package.py
python3 tests/run_all.py
```

The shipped suite uses synthetic temporary Git repositories and Codex homes only.

## Dry-run and install — safest reference mode

```bash
python3 install_global.py --mode reference --dry-run
python3 install_global.py --mode reference
python3 validate_global_install.py
```

Use explicit destinations for isolated evaluation:

```bash
python3 install_global.py \
  --mode reference \
  --codex-home /tmp/codex-home \
  --skills-root /tmp/codex-skills \
  --dry-run
```

## Full namespaced mode

First capture the `preflight_id` from a full dry-run, inspect all target paths/collisions/ownership, then repeat with that exact ID:

```bash
python3 install_global.py --mode full --dry-run
python3 install_global.py --mode full --preflight-id <ID_FROM_DRY_RUN>
python3 validate_global_install.py
```

The generic `ios-*` namespace is intentionally not used.

## Protection session example

`protect begin` creates an immutable session-specific baseline and returns `session_id`:

```bash
IOS_AI="${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py"
python3 "$IOS_AI" protect begin --repo . \
  --allow Sources/Feature/Foo.swift \
  --allow Tests/Feature/FooTests.swift \
  --task "Fix Foo behavior"
```

Then verify and close the exact session:

```bash
python3 "$IOS_AI" protect verify --repo . --session <SESSION_ID>
python3 "$IOS_AI" protect close  --repo . --session <SESSION_ID>
```

A pre-existing dirty path needs exact `--allow-dirty`; protected project/config/dependency paths need exact `--allow-protected`. Git staging/commit is declared separately with `--git-transition stage` / `--git-transition commit`; these declarations authorize an operation class, not scope, and do not authorize config, unrelated refs, branch switches, or out-of-scope content. The runtime allows **one writer session per Git common directory**. Linked worktrees share refs/config through the same Git common-dir and therefore share one writer slot. Concurrent writer sessions are supported only for independent repositories/clones with different Git common directories.


## V5.2 session-state upgrade compatibility

V5.4 keeps session schema 3 for current sessions and provides a **read-only compatibility reader** for valid V5.2 schema-2 sessions that are already `closed`. Historical JSON is not rewritten or promoted to V5.4 evidence. `protect list` marks it `legacy-v5.2-closed-archival`, and explicit `protect status --session <OLD_ID>` returns `ARCHIVAL_CLOSED` with `verification: null`.

Before upgrading from V5.2, verify/close every active or verified V5.2 writer session, including sessions in linked worktrees that share the same Git common directory. Keep the same external state root; do not delete or relocate state as a workaround. If V5.4 finds a V5.2 `active`/`verified` session for the same Git common-dir, or a malformed/foreign/unknown relevant record, writer admission fails closed. Recovery is explicit: use the V5.2 runtime that created the state to resolve/close the old session, then retry V5.4. Repeating this process is idempotent and preserves the historical audit bytes.

## Context, guard, and build-surface review

```bash
python3 "$IOS_AI" context --repo . --ensure
python3 "$IOS_AI" guard --command "git status --short"
python3 "$IOS_AI" build-phases --repo .
python3 "$IOS_AI" plan --repo . --task "<task>" --risk R3 --domain concurrency
python3 "$IOS_AI" declared-policy --repo .
```

Context/adaptation is bounded and metadata-minimizing. Partial, truncated, unreadable, walk-error, timed-out, or budget-exhausted observation is not reported as fully fresh/PASS. Repeating `context --ensure` against the same incomplete observation remains non-zero and does not turn stable partial state into fresh state.

## Update and uninstall

`sync_global.py` updates only unchanged managed assets; a locally modified managed asset is a conflict and is preserved. `uninstall_global.py` removes only manifest-owned unchanged artifacts; modified/unknown content blocks destructive cleanup or is preserved.

```bash
python3 sync_global.py --dry-run
python3 sync_global.py
python3 uninstall_global.py --dry-run
python3 uninstall_global.py --yes
```

## Review artifacts

- `REVIEW_FINDINGS_MATRIX.md` maps F01–F14/K01–K05, V51-01…V51-08, V52-01, A52-01…A52-03, and A53-01 to patches and tests/evidence.
- `REVIEW_READY_VALIDATION_REPORT.md` records only commands actually executed for this candidate.
- `00_META/CURRENT_OFFICIAL_REFERENCES.md` maps selected rules to primary sources and checked dates.

Independent review is still required before treating this candidate as accepted.
