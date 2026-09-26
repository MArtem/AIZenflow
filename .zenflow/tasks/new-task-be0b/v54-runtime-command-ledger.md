# Mixed V5.4 runtime command ledger — read-only source analysis

Historical pre-publication command inventory. Its uncommitted-deletion claim
is superseded by `v54-retirement-published-status.md`; old commands remain
non-authoritative and must not be executed as a copy-only library.

Purpose: account for useful behavior before removing the retired executable CLI from the
current Git tree. No command below was executed. The old ignored runtime has already been
quarantined; this ledger concerns tracked historical source, not active Codex configuration.

| Old `ios_ai.py` command | Useful behavior to preserve | Former coupling / side effect | Copy-only disposition |
| --- | --- | --- | --- |
| `doctor`, `path` | Distinguish observed library/project identity from a readiness claim | Depends on installed descriptor, package identity and external state | Convert to explicit payload/link and project-scope checks; old command excluded |
| `guard` | Classify uncertain command effects before running | Advisory parser in protection runtime; never OS enforcement | Curated repository-safety route and A2 action advice; no implied command permission |
| `build-phases` | Identify Xcode script phases and their risks | Runtime/protection imports and project inspection | Curated build-graph route; read-only inspection when applicable, execute tools only when authorized |
| `context` (`--status/--ensure/--force`) | Bounded repository inventory, evidence provenance, drift detection | `ensure/force` writes generated external project state; adapter scans project inputs | Curated project-facts/inspection routes and focused refresh; no hidden state generator |
| `plan` (`--write`) | Risk/domain-aware task decomposition | Optional external task-graph write; heuristic classification can be wrong | Curated risk and agent-coordination guidance; separate facts from heuristic and require authority for writes |
| `declared-policy` | Show policy/permission boundaries | Runtime-specific report | Preserve local-rules-first and permission accounting in reference control docs |
| `profile status/build` | Detect stale source/candidate content and track selection | Profile/activation metadata and optional state write | Static content manifest/link check; no Codex runtime selector or activation mechanism |
| `protect begin/status/verify/close/list` | Exact write scope, dirty-worktree preservation, final-diff comparison, one integrator | Creates/manages external protection sessions and writer leases | Curated copy-only repository-safety route; do not pretend it enforces an OS/session lock |

The CLI imports `GLOBAL_CODEX/runtime/protection/protection.py`, `vendor/adapt_project.py`,
`knowledge_profile.py`, and `install_global.py` for package identity. The last import is already
removed from the current working tree, so the tracked CLI is not a valid standalone runtime.

Helper-module accounting from function inventory (source inspection, not runtime proof):

- `protection.py` combines bounded Git/file observation, repository/nested-repo identity,
  baseline comparison, protected-path/scope logic and build-phase/command classification with
  external-state directory creation, secure JSON writes and session support. Preserve the
  observation/scope principles in the curated safety/build-graph routes; do not import this
  module or claim copy-only reference provides its enforcement.
- `vendor/adapt_project.py` contains bounded project input scanning, fallible command metadata,
  fact classification, model and report rendering. Preserve observed/derived/heuristic/unknown
  distinctions and relevant target/dependency/CI refresh triggers in project-facts/inspection.
  Do not copy discovered command text into an executable plan or create hidden project state.
- `knowledge_profile.py` scans and hashes candidate/source trees and builds activation/status
  metadata. Preserve exact allowlist, link and content-drift checks as static release evidence;
  exclude runtime profile activation and installed-selector semantics.

`MANUAL_SHIM/bin/ios_ai.py` is a descriptor-driven launcher for it;
`MANUAL_SHIM/bin/manual_preflight.py` checks a manual installation. Their initial deletion was
rejected by auto-review because the mixed CLI's useful audit, adaptation and protection behavior
had not yet been fully accounted for. After semantic accounting, the user explicitly authorized
removal conditional on preserving important behavior; the candidate
`LEGACY_CAPABILITY_MAP.md` records the copy-only replacements and the old enforcement features
that cannot honestly survive without runtime. The exact three tracked files are now deleted in
the working tree, **uncommitted**. No old CLI was executed and no Codex host file changed. Git
history retains the exact source.
