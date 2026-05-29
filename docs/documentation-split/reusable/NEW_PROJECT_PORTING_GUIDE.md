# New Project Porting Guide

## Purpose
Use this guide when starting a new iOS project/task from the reusable baseline.

## Recommended Steps
1. Create or clone the new repository/worktree.
2. Copy the contents of `./docs/documentation-split/reusable/` into the new project.
3. Keep generic docs under `./docs/` and generic skills under `./.codex/skills/`.
4. Create new app-specific docs instead of copying <AppName>-specific material:
   - `./PROJECT_DOCUMENTATION.md`
   - `./PROJECT_HEALTH.md`
   - `./TESTING_INSTRUCTIONS.md`
   - `./docs/CURRENT_USER_OVERRIDES.md`
   - `./docs/WORK_CONTINUITY.md`
   - app-specific feature contracts
5. Replace project/task names, bundle IDs, paths, simulator/device assumptions, verification commands, and repository URLs.
6. Read the reusable baseline before implementation and create app-specific rules only after the product shape is known.

## Do Not Copy By Default
Do not copy `./docs/documentation-split/app-specific/` into a new unrelated project. It contains source-app feature contracts, current task history, and project-specific paths.

## No-Loss Cumulative Transfer Requirement
Every new task/project must receive the complete reusable baseline: docs, prompt presets, project-local skills, external environment skill snapshots, templates, scripts, and user/agent rules. If any item cannot be transferred or activated, document it as an explicit remaining risk before implementation starts.

## Preferred Automated Install
From this reusable baseline folder, run:

```zsh
./scripts/install_reusable_baseline.sh <target-project-root> <AppName> <task-id>
```

Then replace placeholders and project-specific commands in the generated files.
