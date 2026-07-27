# Documentation Vault Summary

## Purpose
Human-readable summary of the global documentation repository layout. Use this before opening the generated root manifest; retired component inventories are not authoritative.

## Canonical Repository
- GitHub: `https://github.com/MArtem/AIZenflowDocumentation`
- Local checkout: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Default branch: `main`

## Top-Level Areas
- `reusable/`: global rules, prompt presets, reusable skills, templates, package docs, architecture cases, and app-neutral knowledge.
- `apps/`: app-specific documentation, decisions, plans, exceptions, snapshots, and histories.
- `tasks/`: task recovery material, plans, handoffs, and assistant archives.
- `DOCUMENT_LIBRARY_GUIDE.md`: how to use the repository without over-reading.
- `MANIFEST.md`: generated detailed inventory.
- `MANIFEST_SUMMARY.md`: compact human-readable overview.

## App Areas
- `apps/<AppName>/`: app-specific material, local rules, local exceptions, plans, architecture decisions, history, and recovery snapshots.
- Legacy references may exist under the owning app area. They are app-specific recovery material, not reusable policy.

## Reusable Areas
- `reusable/baseline/`: bootstrap docs and root rules copied into new worktrees.
- `reusable/agent-prompts/`: app-neutral prompt presets, including `AI_iOS_MASTER_PROMPT.md`.
- `reusable/package-vault-docs/`: reusable package and manager documentation.
- `reusable/architecture-cases/`: architecture catalog and examples.
- `reusable/knowledge-global/`: cross-project reusable knowledge.
- `reusable/sdk-creation/`: package creation standards and templates.

## Completion Rule
Global documentation changes are complete only after:

1. the correct `reusable/`, `apps/`, or `tasks/` area is updated;
2. docs/static checks pass;
3. changes are committed on `main`;
4. changes are pushed to `MArtem/AIZenflowDocumentation`;
5. `scripts/check_documentation_remote_state.py` passes from the active worktree.
