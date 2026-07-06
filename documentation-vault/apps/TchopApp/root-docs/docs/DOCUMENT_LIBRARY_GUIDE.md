# Document Library Guide

## Purpose
Keep the shared documentation library complete without making every task pay the cost of reading every document.

## Canonical Structure

### Startup / Current Task Rules
Read these first when a new chat/task requires bootstrap:

- `./AGENTS.md`
- `./docs/README.md`
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
- `./docs/MODEL_ROUTING_RULE.md`
- `./.zenflow/tasks/new-task-be0b/handoff.md`
- `./.zenflow/tasks/new-task-be0b/plan.md`

### Scope-Specific Active Docs
After startup, read only the docs needed for the actual task scope:

- UI/design/Figma: `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`, `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`
- Saved Codex App prompts: `./docs/saved-prompts/README.md`
- Full document inventory: `./docs/ALL_DOCUMENTS_INVENTORY.md`
- iOS production standards: route through `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- Package/source-only mode: `./docs/PACKAGE_USAGE_IN_TCHOPAPP.md`, `./PackagesInUse/README.md`, `./PackagesForReuse/README.md`

### Documentation Vault
`./documentation-vault` is a durable git-backed mirror/recovery library. Do not read both active docs and vault copies during normal work.

Use vault copies when:

1. recovering or auditing durable documentation state;
2. transferring reusable baseline into another project/task;
3. comparing app-specific docs across projects;
4. verifying that active durable docs were mirrored.

### Saved Prompts
Codex App saved prompt snapshots are canonical in:

- `./docs/saved-prompts/`

Shared durable mirror:

- `./documentation-vault/reusable/saved-prompts/`

Do not keep additional app-specific/split duplicates unless the saved prompt diverges by app.

### Full Inventory
The complete physical document inventory is canonical in:

- `./docs/ALL_DOCUMENTS_INVENTORY.md`

Durable mirror:

- `./documentation-vault/apps/TchopApp/root-docs/docs/ALL_DOCUMENTS_INVENTORY.md`

Do not read the full inventory on every task. Use it for audits, migration, missing-doc checks, and documentation-library maintenance.

## Resource Rule
Default to the smallest sufficient document set:

1. Startup docs.
2. Task-specific docs.
3. Prompt/skill docs only when triggered.
4. Full inventory/vault only for documentation-library, transfer, recovery, or completeness tasks.

## Consistency Rule
When a durable doc/rule/prompt/skill/template changes:

1. update the active canonical file;
2. update the matching vault copy;
3. update `./docs/README.md` if the file should be discoverable from the active index;
4. run docs/vault static checks.
