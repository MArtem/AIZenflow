# Existing-knowledge host entrypoint preview — not applied

Date: **2026-09-14**. This is a preparation artifact for the first-priority adoption gate. It is
not a host configuration change and does not claim that every project currently receives the
canonical knowledge automatically.

## Observed local inventory

- The parent `/Users/Artem/.zenflow/AGENTS.md` requires the canonical bootstrap before project
  action, but explicitly leaves repository-root `AGENTS.md` as the portable adoption mechanism.
- A first-level inventory found 16 Git worktree roots under `/Users/Artem/.zenflow/worktrees`; all
  now have an `AGENTS.md` containing the bootstrap/canonical marker.
- PanModal's `AGENTS.md` and `GLOBAL_RULES_PORTABLE_SNAPSHOT.md` are still untracked; no PanModal
  source or Git ref was changed.
- Nested repositories, non-Git active directories and actual fresh Desktop/open/import sessions
  still need a separate flow inventory.
- The current task process has not been granted exact authority to inspect `/Users/Artem/.codex`.
  The effective global `AGENTS.md`, optional `AGENTS.override.md`, and only-if-needed `config.toml`
  therefore remain `UNKNOWN`.

## Proposed safe sequence after exact authority

1. Read only `/Users/Artem/.codex/AGENTS.md` and, if present, `/Users/Artem/.codex/AGENTS.override.md`.
   Do not read credentials, auth, history, sessions or the whole home. Read `config.toml` only if
   the instruction discovery question cannot be resolved from those exact files and observed
   process settings.
2. Produce a byte-preserving preview: existing text, insertion point, managed block, precedence,
   canonical bootstrap path/revision and fallback behavior. Do not write during the preview.
3. Obtain separate exact write authority for the named file only. Preserve existing bytes and
   override precedence; never replace builtin instructions or change `CODEX_HOME`.
4. Start fresh sessions and record actual first-entry evidence for existing, new-empty,
   imported-without-AGENTS, new-worktree, nested, non-Git and unrelated non-iOS roots.

## Proposed managed common-host entrypoint contract

The host entrypoint must be task-type neutral. It delivers the common baseline before the first
project operation for every project/task in the explicitly scoped `.zenflow` area; it then routes
only the task-relevant specialist material. The separate candidate iOS block remains opt-in and
must not be activated for unrelated work. The entrypoint preserves project and nested overlays,
does not grant command permission, and reports `canonical-baseline-unavailable` plus non-PASS when
the canonical checkout is missing. A parent filesystem directory is not treated as a universal
include outside the explicitly defined host scope.

Proposed managed block (not applied):

```markdown
<!-- AIZENFLOW_COMMON_HOST_ENTRY_V1:BEGIN -->
For every project or task whose effective working directory is
`/Users/Artem/.zenflow` or a descendant of that directory, before the first project operation read
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md`.
Apply its common baseline to every project type, then select only task-relevant specialist routes.
This applies to existing, new, imported, nested and non-Git project directories in that scope,
including projects without a root AGENTS.md. Preserve project and nested instruction overlays.
Repository bootstrap markers provide portability; their absence must not suppress this host entry.
If the canonical file is unavailable, follow the approved portable-snapshot fallback where present
and report canonical-baseline-unavailable. Do not claim current canonical rules were loaded.
This block does not activate the new iOS library runtime or change command permissions.
Outside this directory scope, this block adds no instructions.
<!-- AIZENFLOW_COMMON_HOST_ENTRY_V1:END -->
```

## Acceptance matrix

| Flow | Required evidence | Current status |
|---|---|---|
| Existing root with `AGENTS.md` | fresh session loads global + root layers | not run |
| New empty Git root | fresh session receives global entry before project action | not run |
| Imported root without `AGENTS.md` | global entry still arrives | not run |
| New linked worktree | global entry and common-dir rules remain correct | not run |
| Nested repository | boundary is independent and explicit | not run |
| Non-Git directory | declared scope/route is explicit | not run |
| Unrelated non-iOS task | common baseline is delivered; iOS-only routes are not selected | not run |

Nothing in this preview authorizes host mutation. The exact authority needed later is:

> Разрешаю прочитать `/Users/Artem/.codex/AGENTS.md` и, если существует,
> `/Users/Artem/.codex/AGENTS.override.md` для read-only preview. `config.toml` читать только
> если без него невозможно установить effective discovery path. Запись не разрешаю этим текстом.
