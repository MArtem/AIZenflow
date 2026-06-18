# Agent Instructions

## Mandatory Response Header
Every working, status, readiness, confirmation, task-orientation, planning, or clarification response must start with:

- **Модель:** current model
- **Фаза:** current phase
- **Файлы:** files being inspected/changed, or `none`
- **Следующий безопасный шаг:** next safe step
- **Build/tests:** whether build/tests are needed and why
- **Sandbox:** confirmation that project work stays inside `/Users/Artem/.zenflow`

Short answers such as “готов”, “да, всё ясно”, “готов к новым задачам”, or “можешь присылать” are not exempt.

## Startup Read Rule
Before code, docs, git, project, build, or task changes, read:

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
11. task-relevant package/prompt/skill docs.

Always include the context-transfer rule when handing off:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Model Routing
- Apply `./docs/MODEL_ROUTING_RULE.md` before implementation, planning, review, or package-adoption work.
- Classify tasks before editing code or documentation.
- Use `GPT-5.4` only for approved-plan low-risk execution.
- Use `GPT-5.5` for planning, architecture, persistence, concurrency, navigation, state ownership, public APIs, package boundaries/adoption, security/privacy, data-loss/sync, performance-sensitive work, Xcode/app runtime integration, and high-risk final reviews.

## Filesystem Sandbox
- The user explicitly expanded this task's local sandbox to `/Users/Artem/.zenflow`.
- Keep all project work, build output, package caches, Xcode DerivedData, cloned package state, logs, traces, and temporary project artifacts inside `/Users/Artem/.zenflow`.
- Do not use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any path outside `/Users/Artem/.zenflow` for project work.
- If a tool defaults outside the sandbox, override its output/cache/DerivedData paths before running it.

## Current Package Mode

## Documentation Vault
- Durable rules, prompts, skills, templates, package docs, and app-specific docs are mirrored into `./documentation-vault` inside the `AIZenflow` repo.
- When changing a durable doc/rule/prompt/skill used by agents, update both the active worktree copy and the matching `./documentation-vault` copy in the same block.
- Keep reusable docs under `./documentation-vault/reusable/` and app-specific docs under `./documentation-vault/apps/<AppName>/`.
- Do not copy docs from another app into this worktree's local task docs; read other app context from `./documentation-vault/apps/<AppName>/` when explicitly needed.

- `./PackagesInUse` contains active source-only reusable package code compiled into app/share/widget targets.
- `./PackagesForReuse` contains the full reviewed reusable package vault.
- `./Packages` contains SDK/package creation docs, templates, reports, and optional copy-file helpers only.
- Do not reintroduce `./Packages/TchopInfrastructure` as an active runtime package path.
- Do not use SwiftPM for app integration unless there is an explicit current reason.

## Tests And Verification
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not touch `./TchopAppTests` or UI/package test files unless explicitly allowed.
- Do not run builds/tests/simulator UI/Instruments unless explicitly requested or already approved for the current block.
- `git diff --check`, docs index checks, and read-only/static checks are allowed when useful.

## Implementation Style
- Do not guess product behavior. Ask when requirements, ownership, state flow, or acceptance criteria are unclear.
- Do not add speculative UI, speculative business logic, decorative wrappers, protocols, factories, adapters, use cases, or extra abstractions.
- Prefer the simplest correct implementation that preserves runtime correctness, UX, maintainability, and package/app ownership.
- ViewModels expose explicit intent methods by default; generic `send(_:)`, `dispatch(_:)`, or UI action enums require explicit approval and documented rationale.

## Plan Rule
If new approved work benefits from a breakdown, update `./.zenflow/tasks/new-task-be0b/plan.md` with checkbox steps and mark completed steps before reporting completion.
