# New Chat Handoff

## Identifiers
- Project: `TchopApp`
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`
- Task ID: `be0b925f-37c1-468e-a4b0-061fc6ae30cd`
- Current chat ID: `fb883206-9c44-4907-bef4-5c6f359c6ee8`
- Linked project worktree: `/Users/Artem/.zenflow/worktrees/mvvmexample-3c80`
- Model routing: apply `./docs/MODEL_ROUTING_RULE.md`; `GPT-5.5` remains required for planning/high-risk/final gates.

## Mandatory Startup Rule
Before any code, documentation, git, project, build, or task action:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Local Sandbox Rule
The user explicitly expanded the local sandbox for this task:

- Allowed root: `/Users/Artem/.zenflow`
- Current worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Do not write/read project artifacts, caches, logs, temporary package verification output, DerivedData, traces, or cloned package state outside `/Users/Artem/.zenflow`.
- Do not use `/tmp`, `/Users/Artem/Library`, global SwiftPM/Xcode caches, or any path outside `/Users/Artem/.zenflow` for project work.

## Mandatory Startup Read Order
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
8. `./docs/MODEL_ROUTING_RULE.md`
9. `./.zenflow/tasks/new-task-be0b/handoff.md`
10. `./.zenflow/tasks/new-task-be0b/plan.md`
11. `./PackagesForReuse/README.md`
12. `./PackagesInUse/README.md`
13. `./docs/PACKAGE_USAGE_IN_TCHOPAPP.md`
14. `./docs/documentation-split/reusable/REUSABLE_USER_AND_AGENT_RULES.md`
15. `./docs/documentation-split/reusable/REUSABLE_MANIFEST.md`
16. `./docs/agent-prompts/README.md`

## Mandatory Working Response Header
Every working, status, readiness, planning, confirmation, or task-orientation response must start with:

- model
- active phase
- files being inspected or changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation inside `/Users/Artem/.zenflow`

## Current User Rules
- Treat every implementation/review as product-staff-level production work; demo/test/sample/prototype/pre-release labels do not lower quality.
- For reviews, audits, planning, and requirement analysis, provide full unbiased analysis with priorities.
- Do not guess product decisions. Ask when behavior, ownership, state flow, or acceptance criteria are ambiguous.
- Avoid speculative UI/logic and decorative wrappers, protocols, factories, adapters, use cases, or managers.
- Reusable packages provide mechanisms; app/feature layers provide product decisions.
- New-project MVVM defaults to explicit intent methods. Do not use generic `send(_:)`, `dispatch(_:)`, or UI action enums as boilerplate without explicit approval and documented rationale.
- Do not modify `./TchopAppTests` or package/UI test files unless the user explicitly allows test writing again or asks to fix a specific failing test.
- Do not run builds, tests, simulator UI, manual validation, or Instruments unless explicitly requested or already approved for the block.
- Keep `./.zenflow/tasks/new-task-be0b/plan.md` updated before finishing a work block.

## Current Package Mode
- `./PackagesInUse` = active source-only reusable package subset compiled into app/share/widget targets.
- `./PackagesForReuse` = complete reviewed reusable package vault.
- `./Packages` = SDK/package creation documentation, templates, reports, and optional copy-file helpers only.
- Do not reintroduce `./Packages/TchopInfrastructure` as an active runtime package path.
- Do not use SwiftPM for app integration unless there is an explicit current reason.

## Current Task State
Current block: approved documentation/rules/skills cleanup after a full read-only audit.

Approved scope:
1. align old `GPT-5.5 for all/default` remnants with `./docs/MODEL_ROUTING_RULE.md`;
2. replace retired `./Packages/TchopInfrastructure` rules with current `./PackagesInUse` / `./PackagesForReuse` / source-only package mode;
3. refresh stale continuity/handoff state;
4. convert active absolute workspace links to portable `./` paths where practical;
5. sync app-specific/reusable split copies for touched docs;
6. clarify reusable manifest relative paths;
7. keep external assistant-home links as optional/non-authoritative because the sandbox is now `/Users/Artem/.zenflow`;
8. add root `./AGENTS.md` for current worktree agent bootstrap;
9. add or prepare lightweight consistency checks only if useful without overengineering.

## Latest Verification Baseline Before This Block
- Latest package-vault verification for `./PackagesForReuse/AppValidationCore/Scripts/verify_package.sh` succeeded.
- `python3 ./scripts/check_docs_index.py` succeeded.
- Package artifact scan returned empty.
- `git diff --check` succeeded.
- No app build/plutil was required for the latest vault-only package adoption.

## Verification Expected For This Docs-Only Block
Run only:
1. `python3 ./scripts/check_docs_index.py`
2. `python3 ./scripts/validate_ios_production_framework.py`
3. `git diff --check`

Do not run app build/tests/simulator/Instruments for docs/prompts/skills/templates-only changes.

## Linked MVVMExample Rule
Before any action in `/Users/Artem/.zenflow/worktrees/mvvmexample-3c80`:
- run `git status --short` there;
- read its local `./AGENTS.md`, docs, and task plan;
- do not overwrite or discard uncommitted work.

No MVVMExample changes are currently required for this docs cleanup unless the user explicitly asks for sync.

## Must Not Do
- Do not treat test counts alone as proof of production readiness.
- Do not add speculative packages/features to either worktree.
- Do not rename all current `Tchop*` app-specific entities solely for cosmetic neutrality.
- Do not suppress warnings or weaken strict-concurrency rules.
- Do not expose sensitive HTTP/body/header/token/user data in logs/diagnostics.
- Do not run app test targets, simulator UI, manual validation, or Instruments without explicit permission.

## Completion Rule
After each coherent block:
1. update `./.zenflow/tasks/new-task-be0b/plan.md`;
2. run the approved verification for the block;
3. report changed files, verification, remaining risks, and whether build/tests were intentionally skipped.
