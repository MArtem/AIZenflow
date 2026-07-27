# Reusable Baseline Transfer Checklist

## Purpose
Repeatable checklist for moving the accumulated non-app-specific baseline into a new task/project without losing documentation, rules, prompts, skills, templates, or environment knowledge.

## Before Transfer
- Confirm target project/task name.
- Confirm target repository URL.
- Confirm target worktree path.
- Confirm whether the target already has app-specific docs.
- Read `./docs/DOCUMENT_BOUNDARY_STANDARD.md` and decide the target app name used for `documentation-vault/apps/<AppName>/`.
- Read `./docs/NEW_PROJECT_START_CONTRACT.md` and `./docs/SOURCE_OF_TRUTH_MAP.md`.

## Copy Required Baseline
- Copy `./docs/` from this reusable baseline into the target project.
- Confirm `./docs/DOCUMENT_BOUNDARY_STANDARD.md` exists in the target project before any code/docs work starts.
- Confirm `./docs/NEW_PROJECT_START_CONTRACT.md`, `./docs/SOURCE_OF_TRUTH_MAP.md`, `./docs/AGENT_PREFLIGHT_CHECKLIST.md`, `./docs/COMPLETION_REPORT_CONTRACT.md`, `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md`, and `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` exist in the target project.
- Copy `./.codex/skills/` from this reusable baseline into the target project.
- Copy `./external-environment/skills/` into the target project documentation or recovery area.
- Copy `./REUSABLE_USER_AND_AGENT_RULES.md`, `./EXTERNAL_SKILL_DEPENDENCIES.md`, and this checklist.
- Copy `./templates/` and instantiate project-specific docs from them.

## Instantiate Project-Specific Files
Create or update:
- `./AGENTS.md`
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/README.md`
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/WORK_CONTINUITY.md`
- app-specific feature contracts when known

## Replace Placeholders
Replace:
- `<AppName>`
- `<task-id>`
- `<worktree-path>`
- `<repository-url>`
- bundle IDs
- device/simulator assumptions
- build/test commands

## Verify No Source-App Leakage
Search the target for source-app tokens before first commit.

```zsh
rg -n "<SourceAppName>|<SourceTaskId>|<SourceUserHome>|<SourceAppSpecificToken>" ./docs ./.codex ./PROJECT_DOCUMENTATION.md ./PROJECT_HEALTH.md ./TESTING_INSTRUCTIONS.md || true
```

Any hit must be intentionally app-specific for the new project or removed.

## Verify Documentation Boundary
- Reusable/global docs must be under `documentation-vault/reusable/`.
- App-specific docs must be under `documentation-vault/apps/<AppName>/`.
- Task-only state must be under `documentation-vault/tasks/<task-id>/` or local task docs.
- Do not copy another app's docs into the new app/task as baseline.
- If the new project intentionally violates a reusable rule, record the exception only in its app/task docs.
- Do not promote app-local exceptions to reusable/global docs without explicit user approval and app-neutral rewriting.

## Verify Baseline Integrity
Run:

```zsh
python3 scripts/check_bootstrap_contract.py
git diff --check
```

If the new project has a docs index checker, run it too.

## Completion Report
Report:
- files copied
- templates instantiated
- boundary standard activated
- bootstrap/source-of-truth/preflight/completion contracts activated
- external skills available/missing
- placeholder replacements done
- checks run
- remaining risks


## Sync Existing Project After Baseline Changes
When reusable non-app-specific documentation, prompts, scripts, skills, templates, or specs change after a project has already been created, run:

```zsh
./scripts/sync_reusable_baseline_to_project.sh <target-project-root> <AppName> <task-id>
```

This refreshes generic docs, scripts, skill snapshots, and `./docs/reusable-baseline/` contents in the target project. Existing project-specific root files are not blindly overwritten; update them explicitly when a global rule must become active in that project.

## Infrastructure SDK Creation Baseline
- [ ] Copy `./docs/documentation-split/reusable/infrastructure-sdk/` into the target project under `./docs/reusable-baseline/infrastructure-sdk/`.
- [ ] Use the package template only after filling `PackageContract.md`; do not create speculative packages for symmetry.
