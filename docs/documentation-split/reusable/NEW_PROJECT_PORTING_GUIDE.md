# New Project Porting Guide

## Purpose
Use this guide when starting a new iOS project/task from the reusable baseline.

## Recommended Steps
1. Create or clone the new repository/worktree.
2. Copy the contents of `./docs/documentation-split/reusable/` into the new project.
3. Confirm the new project has `./docs/DOCUMENT_BOUNDARY_STANDARD.md`, `./docs/NEW_PROJECT_START_CONTRACT.md`, and `./docs/SOURCE_OF_TRUTH_MAP.md`; read them before any code/docs/git/project action.
4. Keep generic docs under `./docs/` and generic skills under `./.codex/skills/`.
5. Create new app-specific docs instead of copying <AppName>-specific material:
   - `./PROJECT_DOCUMENTATION.md`
   - `./PROJECT_HEALTH.md`
   - `./TESTING_INSTRUCTIONS.md`
   - `./docs/CURRENT_USER_OVERRIDES.md`
   - `./docs/WORK_CONTINUITY.md`
   - app-specific feature contracts
6. Place durable app-specific docs in `documentation-vault/apps/<AppName>/` and task-only state in `documentation-vault/tasks/<task-id>/` when using the shared vault.
7. Replace project/task names, bundle IDs, paths, simulator/device assumptions, verification commands, and repository URLs.
8. Read the reusable baseline before implementation and create app-specific rules only after the product shape is known.

## Do Not Copy By Default
Do not copy `./docs/documentation-split/app-specific/` into a new unrelated project. It contains source-app feature contracts, current task history, and project-specific paths.

## No-Loss Cumulative Transfer Requirement
Every new task/project/worktree must receive the complete reusable baseline: docs, prompt presets, project-local skills, external environment skill snapshots, templates, scripts, user/agent rules, and `./docs/DOCUMENT_BOUNDARY_STANDARD.md`. If any item cannot be transferred or activated, document it as an explicit remaining risk before implementation starts.

The boundary standard is a startup gate, not a cleanup step. Apply it before creating or moving app docs, task docs, prompts, skills, package docs, architecture docs, or reusable rules.

The highest-quality default is a startup rule: every project uses the strongest reusable standards and best current rules unless the user explicitly approves a narrower local exception.

## Preferred Automated Install
From this reusable baseline folder, run:

```zsh
./scripts/install_reusable_baseline.sh <target-project-root> <AppName> <task-id>
```

Then replace placeholders and project-specific commands in the generated files.

Before implementation, run:

```zsh
python3 scripts/check_bootstrap_contract.py
```

Also confirm the generated `AGENTS.md`, `docs/README.md`, `PROJECT_DOCUMENTATION.md`, `docs/CURRENT_USER_OVERRIDES.md`, and `docs/WORK_CONTINUITY.md` all include `./docs/DOCUMENT_BOUNDARY_STANDARD.md` in their startup/boundary rules.


## Neutral Infrastructure Package Recommendation
For a new unrelated iOS project, create or copy reusable infrastructure under neutral names. Recommended initial shape:

```text
Packages/AppInfrastructure/
  Sources/
    AppNetworking/
    AppErrors/
    AppLocalization/
    AppConfiguration/
    AppLogging/
```

Do not copy source-app branded names such as `source-app*` into a generic project unless the user explicitly accepts that branding. Use previous package implementations as reference material, then rename and remove app-specific policy before adoption.


## Sync Existing Project After Baseline Changes
When reusable non-app-specific documentation, prompts, scripts, skills, templates, or specs change after a project has already been created, run:

```zsh
./scripts/sync_reusable_baseline_to_project.sh <target-project-root> <AppName> <task-id>
```

This refreshes generic docs, scripts, skill snapshots, and `./docs/reusable-baseline/` contents in the target project. Existing project-specific root files are not blindly overwritten; update them explicitly when a global rule must become active in that project.
