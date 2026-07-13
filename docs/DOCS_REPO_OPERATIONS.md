# Global Documentation Repository Operations

## Purpose
This runbook defines how agents and users should work with the global documentation repository.

## Canonical Repository
- GitHub: `https://github.com/MArtem/AIZenflowDocumentation`
- Local checkout: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Default branch: `main`

## SourceTree
Open this exact local path in SourceTree:

`/Users/Artem/.zenflow/worktrees/documentation-vault`

If SourceTree does not show the latest documentation commits, verify that it is not opened on another clone of `MArtem/AIZenflowDocumentation`.

## Completion Rule
Global documentation work is complete only when all are true:

1. Changes are in `/Users/Artem/.zenflow/worktrees/documentation-vault`.
2. The changes are committed on `main`.
3. The commit is pushed to `https://github.com/MArtem/AIZenflowDocumentation`.
4. `python3 scripts/check_documentation_remote_state.py` passes from the active project worktree.

Local-only commits do not count as completed global documentation updates.

## Standard Check Commands
From the active project worktree:

```bash
python3 scripts/check_docs_index.py
python3 scripts/check_bootstrap_contract.py
python3 scripts/check_documentation_boundaries.py
python3 scripts/check_documentation_remote_state.py
git diff --check
```

From `/Users/Artem/.zenflow/worktrees/documentation-vault`:

```bash
git status --short --branch
git log --oneline --decorate -5
```

## Boundary Rules
- Reusable/global docs belong under `reusable/`.
- App-specific docs belong under `apps/<AppName>/`.
- Task recovery/history belongs under `tasks/<TaskId>/`.
- Local app exceptions never change reusable/global rules without explicit promotion approval.
