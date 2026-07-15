# <AppName> Developer Onboarding Guide

## Purpose
Stable onboarding document for `<AppName>`.

Read this file for:
- app shape
- architecture boundaries
- runtime baselines
- documentation entry points
- top-level folder ownership

Do not use this file for temporary task history or debugging notes.

## First Read For Agents
Use `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`. This onboarding document is loaded for project/code/package orientation; it is not an always-read startup document.

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Quick Orientation
`<AppName>` is a `<platform/product summary>`.

Replace this section with:
- main user flows
- primary modules/features
- persistence/runtime choices
- package/shared-code boundaries
- extension/widget/background capabilities when relevant

## Stable Runtime Baselines
- Deployment target: `<iOS version>`
- UI state approach: `<Observation / ObservableObject / mixed>`
- Persistence: `<SwiftData / CoreData / SQLite / files / none>`
- Networking/API: `<client/package/contract>`
- Architecture constraints: `<known boundaries>`

## Current Task Overrides
Current task/user overrides live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Highest-Quality Default
`<AppName>` uses the highest reusable standards and best current rules by default until the user explicitly approves a narrower local exception.

## Documentation Boundary
Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` before moving, copying, promoting, or editing documentation that may be reusable, app-specific, task-specific, prompt-related, skill-related, package-related, or bootstrap-related.

Reusable/global knowledge must stay app-neutral. App-specific plans, local rules, exceptions, compromises, histories, ADRs, and task decisions must stay under the corresponding app/task area. A local exception can become a reusable rule only after explicit promotion approval and app-neutral rewriting.

## Knowledge Organization
- Reusable cross-project knowledge: `./docs/knowledge/global/`
- App-specific knowledge: `./docs/knowledge/<AppName>/`

Use `./docs/SOURCE_OF_TRUTH_MAP.md` before deciding where durable knowledge belongs.
