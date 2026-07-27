# Document Library Guide

## Purpose
Keep the shared documentation library complete without making every task pay the cost of reading every document.

## Startup / Current Task Rules
Read these first when a new chat/task requires bootstrap:

- `./AGENTS.md`
- `./docs/README.md`
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md` when present
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
- `./docs/MODEL_ROUTING_RULE.md`
- `./docs/DOCUMENT_LIBRARY_GUIDE.md`
- `./docs/ALL_DOCUMENTS_INVENTORY.md`
- current task handoff/plan under `./.zenflow/tasks/<task-id>/` when present

## Scope-Specific Docs
After startup, read only the docs needed for the actual task scope:

- UI/design/Figma: `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`, `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`
- iOS production standards: route through `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- Architecture style work: `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`
- Full local inventory: `./docs/ALL_DOCUMENTS_INVENTORY.md`

## Documentation Vault
A project may provide a git-backed `./documentation-vault` or an external central vault path. Do not read both active docs and vault copies during normal work.

Use vault copies only for transfer, recovery, cross-project comparison, documentation-library audits, or checking that durable docs were mirrored.

## Resource Rule
Default to the smallest sufficient document set:

1. Startup docs.
2. Task-specific docs.
3. Prompt/skill docs only when triggered.
4. Full inventory/vault only for documentation-library, transfer, recovery, or completeness tasks.

## Consistency Rule
When a durable doc/rule/prompt/skill/template changes:

1. update the active canonical file;
2. update the matching vault copy if the project has one;
3. update `./docs/README.md` if the file should be discoverable from the active index;
4. run docs/vault static checks.

## Context Transfer Rule
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
