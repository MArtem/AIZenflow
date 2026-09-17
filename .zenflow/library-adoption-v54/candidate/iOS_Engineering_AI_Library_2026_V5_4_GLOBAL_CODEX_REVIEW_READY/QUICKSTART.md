# Quick Start — V5.4 Review Ready

Do not install this library into a client repository. Validate it first. If you want an installed pilot, inspect a dry-run and start with **reference mode**. Reference mode **does modify user-global Codex configuration**; for a no-install/no-global-instruction evaluation, use `PROJECT_REFERENCE_OPT_IN.md` instead. The only Git-root exception is the exact managed runtime subtree of `MArtem/AIZenflowDocumentation` described below.

```bash
python3 validate_package.py
python3 tests/run_all.py
python3 install_global.py --mode reference --dry-run
python3 install_global.py --mode reference
python3 validate_global_install.py
```

For a manual unpack/connection that does not run an installer, follow
[`MANUAL_DEPLOYMENT.md`](MANUAL_DEPLOYMENT.md). It copies the same payload/runtime and requires
the operator to connect the global AGENTS block and verify a fresh first-entry session. Merely
placing the archive under `/Users/Artem/.zenflow` does not cover independent Git roots.

For an explicit portable-area installer rehearsal, keep the extracted package as the source and
set the same area as the active `CODEX_HOME` before starting the Codex process. The profile is
deliberately explicit; it does not modify Desktop launch settings or claim that a parent directory
covers independent Git roots automatically:

```bash
AREA_ROOT=/ABSOLUTE/PATH/TO/ios-codex-area
export CODEX_HOME="$AREA_ROOT"
python3 install_global.py --portable-area "$AREA_ROOT" --use-source-in-place --mode reference --dry-run
python3 install_global.py --portable-area "$AREA_ROOT" --use-source-in-place --mode reference
python3 validate_global_install.py --codex-home "$AREA_ROOT"
```

The portable profile keeps full-mode skills under `$AREA_ROOT/skills` only when explicitly
selected; do not assume that a separate Codex process will use this area unless its effective
`CODEX_HOME` is verified. Explicit destination overrides are rejected when they escape the selected
area.

For the canonical documentation repository, keep the versioned library source in the repository
and put only generated runtime state in its separate ignored subtree:

```bash
DOCS_ROOT=/ABSOLUTE/PATH/TO/AIZenflowDocumentation
AREA_ROOT="$DOCS_ROOT/.codex-runtime/ios-engineering"
export CODEX_HOME="$AREA_ROOT"
python3 install_global.py --portable-area "$AREA_ROOT" \
  --canonical-repository-root "$DOCS_ROOT" \
  --allow-canonical-repository-runtime --use-source-in-place \
  --mode reference --dry-run
python3 install_global.py --portable-area "$AREA_ROOT" \
  --canonical-repository-root "$DOCS_ROOT" \
  --allow-canonical-repository-runtime --use-source-in-place \
  --mode reference
```

Only `<DOCS_ROOT>/.codex-runtime/ios-engineering` is writable; the source/docs tree and `.git`
remain protected. The repository origin must be `MArtem/AIZenflowDocumentation`.

If Desktop must keep its existing Codex home, connect only its active global instruction file to
the separately validated runtime. Runtime, state and the connection receipt stay in `AREA_ROOT`:

```bash
HOST_CODEX_HOME=/ABSOLUTE/PATH/TO/ACTUAL/CODEX-HOME
python3 validate_global_install.py --codex-home "$AREA_ROOT"
python3 host_entry.py connect --runtime-home "$AREA_ROOT" \
  --host-codex-home "$HOST_CODEX_HOME" --dry-run
python3 host_entry.py connect --runtime-home "$AREA_ROOT" \
  --host-codex-home "$HOST_CODEX_HOME" --preflight-id <ID_FROM_DRY_RUN>
python3 host_entry.py status --runtime-home "$AREA_ROOT"
```

This split-host path does not copy a shim, state or registry into `HOST_CODEX_HOME`. Disconnect with
the matching dry-run followed by `host_entry.py disconnect --runtime-home "$AREA_ROOT" --yes`.
Disconnect must precede runtime uninstall; an active split-host receipt blocks removal. Existing
host instruction files are published/reversed with Darwin atomic exchange and racing edits fail
closed without being overwritten. Status is non-passing if a later non-empty override changes the
active global instruction file.

For a later installer update, extract the new release beside the old one and run the new release's
`sync_global.py`; source-in-place mode selects that script's versioned source root. Inspect the
dry-run `source`, `content_root`, `version`, and `source_tree_sha256`, then run the same command
without `--dry-run`. Keep the old release and state root. To roll back, stop Codex and run the
fixed release's `sync_global.py --release-root <verified-old-release>` using the same dry-run/update
pair. Never run `install_global.py` again against an already registered area, never use the old
release's pre-fix sync as the rollback coordinator, and never treat a dry-run as a completed update.

For **full** mode, inspect the full preflight and reuse its exact ID:

```bash
python3 install_global.py --mode full --dry-run
python3 install_global.py --mode full --preflight-id <ID_FROM_DRY_RUN>
```

Full mode installs only namespaced `ioslib-*` skills.

For an existing reference installation, the migration producer is `sync_global.py`, not the fresh
installer:

```bash
python3 sync_global.py --codex-home "$AREA_ROOT" --mode full --dry-run
python3 sync_global.py --codex-home "$AREA_ROOT" --mode full --preflight-id <ID_FROM_SYNC_DRY_RUN>
```

After a same-home deployment, read `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/INSTALLATION.json` to discover the exact selected release and knowledge root. In split-host mode, use the absolute descriptor path shown by `host_entry.py status`. `INSTALLATION.md` is explanatory only. Reference mode intentionally relies on this stable selector instead of installing the 60 optional skills. Then read `GLOBAL_CODEX/KNOWLEDGE_ROUTER.md` and load only the route relevant to the task.

For a write task, create a session and keep the returned ID:

```bash
IOS_AI="${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py"
python3 "$IOS_AI" protect begin --repo . --allow Sources/Foo.swift --task "Fix Foo"
# edit only the declared task scope
python3 "$IOS_AI" protect verify --repo . --session <SESSION_ID>
python3 "$IOS_AI" protect close  --repo . --session <SESSION_ID>
```

`verify` detects state differences after mutation; it is not process interception, backup, rollback, or proof that no transient write occurred.

Useful read/advisory operations:

```bash
python3 "$IOS_AI" context --repo . --ensure
python3 "$IOS_AI" guard --command "git diff --stat"
python3 "$IOS_AI" build-phases --repo .
python3 "$IOS_AI" declared-policy --repo .
```

Unknown commands, shell operators/redirection/substitution, interpreters, network/dependency/release tools, and mutating Git forms are never classified as `ALLOW_READ_ONLY` by default.


## Upgrading from V5.2 with existing protection state

Before replacing the V5.2 runtime, close every V5.2 `active`/`verified` protection session, including linked worktrees sharing one Git common-dir. Preserve the existing external state root. V5.4 reads valid schema-2 `closed` sessions as archival history only; it does not rewrite them or count their old verification as a V5.4 PASS. If an old writer is still `active`/`verified`, V5.4 refuses a new writer until that state is explicitly resolved with the V5.2 runtime. Do not delete the sessions directory or silently switch to a new state root to bypass this check.

## Writer concurrency

Protection uses one writer session per Git common directory. Linked worktrees share that writer slot because ordinary `refs/*` and repository config are shared. For concurrent writers, use independent repositories/clones with different Git common directories. Read-only reviewers/scouts can still run independently when current project rules permit them.
