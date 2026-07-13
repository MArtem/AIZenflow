# Document Library Guide

## Purpose
Keep the shared documentation library complete without making every task pay the cost of reading every document.

## Canonical Location
The shared documentation library for all Zenflow tasks is:

- GitHub repository: `MArtem/AIZenflowDocumentation`
- Remote URL: `https://github.com/MArtem/AIZenflowDocumentation`
- `/Users/Artem/.zenflow/worktrees/documentation-vault`

This is the single shared source for reusable agent rules, prompt presets, skills, templates, package documentation, architecture cases, and app-specific documentation snapshots.

Global documentation work is complete only after changes are committed in the local checkout and pushed to `MArtem/AIZenflowDocumentation`.

## Boundary Rule
Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` before moving, copying, promoting, or editing documentation that may be reusable or app-specific.

Local project exceptions stay under the matching app or task area and never weaken reusable rules without explicit promotion approval.

## Startup / Current Task Rules
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
- `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
- `./.zenflow/tasks/new-task-be0b/handoff.md`
- `./.zenflow/tasks/new-task-be0b/plan.md`

### Scope-Specific Active Docs
After startup, read only the docs needed for the actual task scope:

- UI/design/Figma: `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`, `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`
- Saved Codex App prompts: `./docs/saved-prompts/README.md`
- Full document inventory: `./docs/ALL_DOCUMENTS_INVENTORY.md`
- iOS production standards: route through `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- Package/source-only mode: `./docs/PACKAGE_USAGE_SOURCE_ONLY.md`, `./PackagesInUse/README.md`, `./PackagesForReuse/README.md`

## Central Library Areas
- `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/`: reusable non-app-specific docs, prompts, skills, templates, package docs, architecture cases, package/manager docs, reusable scripts, and app-neutral knowledge.
- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/Tchop/`: Tchop-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/`: MVVMExample-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/BattleshipGame/`: BattleshipGame-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook/`: AIFieldbook-specific snapshots, local rules, exceptions, histories, plans, and app decisions.
- `/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/`: task and assistant recovery archives.

## Resource Rule
Default to the smallest sufficient document set:

1. Startup docs.
2. The document-boundary standard.
3. Task-specific docs.
4. Prompt/skill docs only when triggered.
5. Full inventory/vault only for documentation-library, transfer, recovery, or completeness tasks.

## Consistency Rule
When a durable reusable doc/rule/prompt/skill/template changes:

1. update the active canonical file;
2. update the matching vault copy under `documentation-vault/reusable/`;
3. update `./docs/README.md` if the file should be discoverable from the active index;
4. run docs/vault static checks;
5. commit and push the corresponding `documentation-vault` changes to `MArtem/AIZenflowDocumentation`.

When an app-specific rule, plan, ADR, exception, prompt, skill, or history changes, update only the matching `documentation-vault/apps/<AppName>/` area.

When a task-only handoff, plan, or recovery note changes, update only `documentation-vault/tasks/<TaskId>/` and the local task docs.

Promote local app decisions into reusable docs only after explicit user approval and app-neutral rewriting.

## Context Transfer Rule
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
