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
- When a Codex app task creates or modifies a new project/app, create and maintain `plan.md`, `handoff.md`, and the relevant app-specific documentation without waiting for the user to ask for those files explicitly.
- If one task contains multiple Xcode projects/apps, keep each app's product plans, architecture decisions, ADRs, histories, local rules, and exceptions in its own app-specific documentation boundary.
- Do not let handoff become a full implementation log.
- Move superseded detail into archive or app-specific docs.
- Handoff must include the context transfer rule:
  **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
- The combined active `handoff.md` and `plan.md` budget is 3,500 words. Before handoff or route
  validation exceeds that budget, compact completed detail into app/task history and retain only
  current evidence, restrictions, decisions, risks, and next steps.
- Completed implementation history should collapse to one durable outcome plus evidence references;
  it must not grow as a chronological transcript of every corrective iteration.

## Handoff Maximum Shape
- identifiers;
- startup read order;
- current user restrictions;
- current app/task state;
- changed files summary;
- verification status;
- next safe steps;
- must-not-do list.
