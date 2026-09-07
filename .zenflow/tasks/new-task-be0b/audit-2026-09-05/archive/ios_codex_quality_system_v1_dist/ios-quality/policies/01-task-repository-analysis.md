# 01 — Task and Repository Analysis

## Purpose

Prevent the agent from coding against assumptions that the repository could answer directly.

## Before editing, MUST inspect

- `git status` and current branch;
- relevant `AGENTS.md` / local instructions;
- project/workspace and affected scheme/target/module;
- current implementation around the requested behavior;
- nearby tests and mocks/fakes;
- public protocols/types crossed by the change;
- configuration/resources involved (Info.plist, entitlements, privacy manifest, string catalogs, Package.resolved) when relevant.

## Task analysis MUST state

- requested behavior;
- acceptance criteria;
- non-goals;
- affected modules/files likely to change;
- observed existing architecture/conventions;
- risk level and trigger tags;
- invariants that must remain true;
- test strategy;
- unresolved ambiguity.

## Clarification rule

Ask the user only when a missing decision can materially alter correctness, product behavior, public compatibility, security/privacy, migration outcome, or dependency choice and cannot be safely inferred from code/specification.

Do not ask for information that repository inspection can resolve.

## Scope discipline

MUST NOT:

- reformat unrelated files;
- rename unrelated symbols;
- upgrade tools/dependencies “because they are old”;
- migrate architecture as a side effect of a feature;
- modify generated files unless they are source-controlled and the generator/workflow requires it;
- change deployment targets or Swift language mode without explicit project-level decision.

## Dirty working tree

If pre-existing changes exist:

- identify them before editing;
- do not overwrite or revert them;
- distinguish pre-existing from agent-created diff in verification;
- stop if the task cannot be safely isolated.
