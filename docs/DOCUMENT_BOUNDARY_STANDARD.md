# Document Boundary Standard

## Purpose
This standard prevents reusable knowledge and app-specific knowledge from mixing.

It applies to every current and future project in this Zenflow workspace:
- Tchop;
- MVVMExample;
- BattleshipGame;
- AIFieldbook;
- the architecture catalog;
- reusable packages/managers;
- future apps and experiments.

## Canonical Roots
The durable documentation library lives at:

`/Users/Artem/.zenflow/worktrees/documentation-vault`

Use these roots:

- `reusable/`: shared rules, standards, prompts, skills, templates, architecture cases, package/manager docs, reusable scripts, and app-neutral knowledge.
- `apps/<AppName>/`: app-specific docs, local rules, local exceptions, plans, history, ADRs, handoffs, project snapshots, app-specific skills, app-specific prompts, and app-specific decisions.
- `tasks/<TaskId>/`: task recovery material, transient handoffs, task plans, and task history.
- worktree-local docs: small operational copies needed by the current task/worktree only.

## App-Specific Roots
Each app owns its own documentation boundary:

- `apps/Tchop/`
- `apps/MVVMExample/`
- `apps/BattleshipGame/`
- `apps/AIFieldbook/`

If legacy folders exist under older names, treat them as app-specific recovery snapshots. Do not copy them into `reusable/` without the promotion process below.

## Reusable Roots
Reusable material belongs only when it is app-neutral and useful across projects:

- `reusable/baseline/`: project bootstrap baseline and universal rules.
- `reusable/agent-prompts/`: app-neutral prompt presets.
- `reusable/local-ios-skills/`: app-neutral iOS skills.
- `reusable/architecture-cases/`: the architecture catalog, including the 14 architecture cases.
- `reusable/package-vault-docs/`: package/manager docs for reusable infrastructure.
- `reusable/knowledge-global/`: app-neutral knowledge.
- `reusable/sdk-creation/`: package creation standards, templates, scripts, and release rules.

## Hard Separation Rules
1. No upward leakage.
   App-specific decisions, exceptions, shortcuts, naming, runtime constraints, bug history, or task history must not be copied into `reusable/`.

2. No sideways leakage.
   Docs from one app must not be copied into another app as baseline. They may be read only as explicitly requested reference material.

3. Local exceptions stay local.
   If an app intentionally violates a reusable rule, record the exception only under `apps/<AppName>/` and/or the current task docs. That exception must not weaken the reusable rule.

4. Reusable docs must be app-neutral.
   A reusable document must not contain app names, app file paths, bundle IDs, feature names, credentials, task IDs, local compromises, or source-app branding unless it is explicitly describing this boundary rule.

5. App docs may reference reusable docs.
   An app-specific doc may link to reusable rules. The reusable doc must not link back to app-specific policy as authority.

6. Task docs are not durable reusable rules.
   Task plans, handoffs, and temporary decisions may summarize reusable rules, but they do not replace the canonical reusable copy.

## Promotion Gate
A local app decision becomes reusable only through an explicit promotion step.

Promotion requires:
- explicit user approval or task instruction to promote the rule;
- removal of app names, paths, bundle IDs, feature-specific assumptions, and task history;
- rewriting the rule in app-neutral language;
- choosing the correct reusable root;
- updating the reusable manifest/index;
- verifying that no app-specific terms leaked into the reusable copy.

Without that promotion step, the decision remains local forever.

## Import Gate
When starting a new project, use this read order:

1. project-local `AGENTS.md`, handoff, and plan;
2. this standard;
3. reusable baseline docs needed for the task;
4. the current app's own `apps/<AppName>/` docs, if they exist;
5. other apps' docs only when the user explicitly asks for cross-app reference.

Do not bootstrap a new app by copying another app's docs.

## Architecture Catalog Boundary
The architecture catalog is reusable reference material.

It may describe MVVM, SwiftUI Native State, Coordinator/Flow, Clean, VIPER, TCA, RIBs, and other cases. It must not contain app-specific policy unless a case is explicitly marked as an example and not a default rule.

## Package/Manager Boundary
Reusable packages/managers own app-neutral mechanisms. Package docs must not describe product-specific behavior as package policy.

If an app integrates a package in a special way, document that integration under `apps/<AppName>/` or the current app task, not inside the package's reusable contract.

## Required Checks
After changing documentation boundaries:

- search reusable docs for app-specific names and source-app branding;
- search app-specific docs for misplaced reusable policy that should be promoted separately;
- run docs index/static checks when the local worktree has them;
- report any legacy folders that remain as app-specific recovery snapshots.

## Completion Language
When reporting documentation-boundary work, state:

- which reusable docs changed;
- which app-specific docs changed;
- whether any local exceptions were promoted;
- whether any app-specific material remains only as legacy/recovery content;
- which checks were run.
