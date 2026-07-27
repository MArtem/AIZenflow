# Context Transfer And New Chat Standard

## Purpose
Prevent context overload and preserve work continuity when a chat becomes too large or the current agent context becomes risky.

## Agent Responsibility
The agent must proactively tell the user when it is time to move to a new chat. Do not wait until the context is already unreliable.

## Trigger Conditions
Recommend a new chat when one or more conditions are true:

- the conversation has accumulated multiple large implementation/review phases;
- the agent starts relying on summaries instead of current files/docs for important decisions;
- the user asks to start a new independent phase or project;
- the current answer would need to restate too much history to stay safe;
- task state, docs, plans, or changed files are becoming hard to track;
- there was a tool/runtime interruption and continuity is not fully obvious;
- the next block is high-risk and should start from a clean reread of docs and current files.

## Required Transition Spec

## Result Model And Context Reporting
- Every result/completion report must state which model(s) worked and what each one did.
- Every result/completion report must include a context-health recommendation: no refresh needed, refresh desirable, or new chat needed.
- New-chat recommendations must be proactive, not delayed until context is already failing.

When recommending a new chat, provide a compact handoff spec with:

1. project/worktree/task/chat identifiers;
2. current model rule;
3. mandatory startup read order;
4. current user rules and restrictions;
5. changed files and verification status;
6. exact current task state;
7. next safe steps;
8. what must not be done;
9. the rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.

## Output Size Rule
The transition spec should be complete but compact. Do not include raw command logs, full diffs, tool output, or long scripts unless the user explicitly requests them.

## After Transfer
The new chat must start by rereading the current documentation and rules before making code, docs, git, or project changes.
