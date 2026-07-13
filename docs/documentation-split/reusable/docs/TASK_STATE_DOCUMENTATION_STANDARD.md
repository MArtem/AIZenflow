# Task State Documentation Standard

## Purpose
Keep task state concise and prevent task documents from becoming a mixed archive of project history, reusable rules, and app-specific decisions.

## Files
- `plan.md`: current executable plan and checklist only.
- `handoff.md`: compact resume state for a new chat or agent.
- `archive/`: old handoffs, superseded plans, long logs, or historical recovery material.
- `documentation-vault/tasks/<TaskId>/`: durable task recovery copy.
- `documentation-vault/apps/<AppName>/`: durable app decisions, ADRs, product plans, and app-specific history.
- `documentation-vault/reusable/`: durable app-neutral rules only.

## Rules
- Do not store durable reusable rules in task docs.
- Do not store durable app decisions only in task docs.
- Do not let handoff become a full implementation log.
- Move superseded detail into archive or app-specific docs.
- Handoff must include the context transfer rule:
  **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Handoff Maximum Shape
- identifiers;
- startup read order;
- current user restrictions;
- current app/task state;
- changed files summary;
- verification status;
- next safe steps;
- must-not-do list.
