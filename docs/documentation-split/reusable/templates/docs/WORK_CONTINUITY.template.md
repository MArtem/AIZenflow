# Work Continuity

## Purpose
Durable resume checkpoint for `<AppName>` when chat/task context is lost.

## Chat Transition Rule
- Keep and update a universal transition prompt here.
- After reset, run bootstrap read once per new chat.
- Every context-transfer prompt must include:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Universal Transition Prompt Template
```text
Работаем в проекте `<AppName>` в worktree:
`<worktree-path>`

Перед началом прочитай:
1) ./docs/README.md
2) ./PROJECT_DOCUMENTATION.md
3) ./PROJECT_HEALTH.md
4) ./docs/CURRENT_USER_OVERRIDES.md
5) ./docs/AGENT_RULES.md
6) ./docs/WORK_CONTINUITY.md
7) ./docs/MODEL_ROUTING_RULE.md
8) ./docs/DOCUMENT_LIBRARY_GUIDE.md
9) ./docs/DOCUMENT_BOUNDARY_STANDARD.md
10) текущие task docs under ./.zenflow/tasks/<task-id>/ если есть

Правило после очистки контекста:
- перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
- reusable baseline является накопительным и не должен теряться при переходе между проектами
- применять docs boundary: reusable/global docs stay under documentation-vault/reusable; app-specific docs stay under documentation-vault/apps/<AppName>; task docs stay under documentation-vault/tasks/<task-id> or local task state; local exceptions never change reusable rules without explicit promotion approval
- применять highest-quality default: every project uses the strongest reusable standards and best current rules unless the user explicitly approves a narrower local exception
- применять preflight/completion contracts: ./docs/NEW_PROJECT_START_CONTRACT.md, ./docs/AGENT_PREFLIGHT_CHECKLIST.md, ./docs/SOURCE_OF_TRUTH_MAP.md, ./docs/COMPLETION_REPORT_CONTRACT.md, ./docs/TASK_STATE_DOCUMENTATION_STANDARD.md
- применять `./docs/MODEL_ROUTING_RULE.md`: `GPT-5.4` для approved-plan low-risk execution, `GPT-5.5` для planning/high-risk/final gates
```
