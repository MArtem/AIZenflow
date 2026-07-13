# Work Continuity

## Purpose
Durable resume checkpoint for `source-app` when chat/task context is lost.

## Chat Transition Rule (Universal)
- Keep this file compact and current; long historical implementation logs belong in `./.zenflow/tasks/new-task-be0b/plan.md` or archives.
- When context gets large or a phase boundary is reached, propose a new chat proactively.
- After reset, run bootstrap read **once per new chat**.
- If the user asks to refresh docs/rules state, re-read the active documentation set listed in `./docs/README.md` before continuing.
- Every context-transfer prompt must explicitly include this rule:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Working Mode Rule
- When the user has already approved a clear implementation plan, the assistant may batch multiple consecutive plan steps into one larger execution block instead of reporting after each small step.
- Choose batch size based on efficiency, code quality, architectural safety, and context churn.
- Report back after a meaningful block is complete, or earlier if a blocker, ambiguity, or architecture-risk decision appears.
- If the user creates a separate new task, treat it as an independent unit and provide a completion report for that task specifically.

## Filesystem Sandbox Rule
- The user explicitly expanded the local sandbox for this task from `/Users/Artem/.zenflow/worktrees` to `/Users/Artem/.zenflow`.
- All project work, build output, package verification output, Xcode DerivedData, cloned package state, logs, traces, and temporary project artifacts must stay inside `/Users/Artem/.zenflow`.
- Do not use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any other path outside `/Users/Artem/.zenflow` for project work.
- If a command/tool would default outside the Zenflow sandbox, override its output paths before running it.
- The only allowed external filesystem action is deleting previously created source-app/MVVMExample traces outside the sandbox when explicitly requested by the user.

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
13. `./docs/PACKAGE_USAGE_SOURCE_ONLY.md`
14. `./docs/documentation-split/reusable/REUSABLE_USER_AND_AGENT_RULES.md`
15. `./docs/documentation-split/reusable/REUSABLE_MANIFEST.md`
16. `./docs/agent-prompts/README.md`

## Current Working Baseline
- Apply `./docs/MODEL_ROUTING_RULE.md`: `GPT-5.4` only for approved low-risk execution; `GPT-5.5` for planning, architecture, high-risk domains, package adoption/app integration, and final gates.
- Every working/status/readiness/planning response must start with model, phase, files, next safe step, build need, and sandbox confirmation.
- Do not run builds, tests, simulator UI, or Instruments unless explicitly requested or already approved for the current block.
- Do not touch `./app test targets` or UI/package test files unless the user explicitly reopens test-writing work or asks to fix a specific failing test.
- No speculative UI, speculative business logic, decorative wrappers/protocols/factories/adapters/use cases, or per-view models without a concrete current problem.
- Reviews/audits/planning must provide full unbiased analysis and prioritized recommendations.

## Current Package Mode
- `./PackagesInUse` contains active source-only package copies compiled directly into app/share/widget targets.
- `./PackagesForReuse` contains the complete reviewed reusable package vault.
- `./Packages` contains SDK/package creation docs, templates, reports, and optional copy-file helpers only.
- Do not reintroduce `./Packages/source-app infrastructure` as an active runtime package path.
- Do not use SwiftPM for app integration unless there is an explicit current reason; source-only mode is the active disk-control strategy.

## Current Functional Baseline
- Active app runtime: SwiftUI + Observation + SwiftData-first persistence.
- Feed/composer product contract: `text`, `photo`, `video`, `audio`, `pdf` cards.
- Text order: `text`, `headline`, `subheadline`, `source`.
- Composer/share/feed runtime is source-neutral and local-first.
- Product-specific behavior stays in `./source-app`; reusable mechanics stay in `./PackagesInUse` / `./PackagesForReuse`.

## Current Task State
The current approved block is documentation/rules/skills cleanup after a read-only audit of active docs, task docs, reusable baseline, prompt presets, saved prompt snippets, local skills, package usage docs, continuity/handoff/model-routing rules, and reusable templates.

Latest user approvals:
- apply all nine audit recommendations;
- update the sandbox rule to allow work anywhere under `/Users/Artem/.zenflow`, but nowhere beyond it;
- keep build/tests/simulator/Instruments disabled for docs-only changes.

## Next Safe Steps
1. Complete docs/rules/skills cleanup for model routing, sandbox, package mode, stale handoff/continuity, absolute workspace links, reusable manifest path clarity, and root `./AGENTS.md`.
2. Run docs/static verification only:
   - `python3 ./scripts/check_docs_index.py`
   - `python3 ./scripts/validate_ios_production_framework.py`
   - `git diff --check`
3. Update `./.zenflow/tasks/new-task-be0b/plan.md` before reporting completion.

## Context Transfer Prompt Template
```text
Работаем в проекте `source-app` в worktree:
`/Users/Artem/.zenflow/worktrees/new-task-be0b`

Локальная sandbox-граница для этой задачи расширена пользователем до:
`/Users/Artem/.zenflow`
Нельзя работать за пределами этой папки.

Перед началом перечитай:
1) ./docs/README.md
2) ./PROJECT_DOCUMENTATION.md
3) ./PROJECT_HEALTH.md
4) ./docs/CURRENT_USER_OVERRIDES.md
5) ./docs/AGENT_RULES.md
6) ./docs/WORK_CONTINUITY.md
7) ./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md
8) ./docs/MODEL_ROUTING_RULE.md
9) ./.zenflow/tasks/new-task-be0b/handoff.md
10) ./.zenflow/tasks/new-task-be0b/plan.md
11) ./PackagesForReuse/README.md
12) ./PackagesInUse/README.md
13) ./docs/PACKAGE_USAGE_SOURCE_ONLY.md
14) ./docs/documentation-split/reusable/REUSABLE_USER_AND_AGENT_RULES.md
15) ./docs/documentation-split/reusable/REUSABLE_MANIFEST.md
16) ./docs/agent-prompts/README.md

Обязательное правило переноса контекста:
перечитать весь актуальный набор документации и правил для этого worktree и task-контекста

Критичные правила:
- Использовать ./docs/MODEL_ROUTING_RULE.md.
- Начинать рабочие ответы с обязательного response header.
- Не запускать build/tests/simulator/Instruments без явного разрешения.
- Не трогать ./app test targets без явного разрешения.
- Package mode: ./PackagesInUse = active source-only packages; ./PackagesForReuse = reusable package vault; ./Packages = SDK/package docs/templates only.
```
