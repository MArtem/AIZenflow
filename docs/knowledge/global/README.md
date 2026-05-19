# Global Knowledge Base

## Purpose
Reusable assistant/project rules, prompt presets, and operating preferences that should be portable to future projects.

This section should avoid current-app file paths, app entity names, app-specific dimensions, and product-specific contracts.

## Contents
- `./agent-working-rules.md`: reusable user/assistant working rules.
- `./prompt-presets/`: reusable prompt templates for feature work, SwiftUI design work, refactoring, code review, ADRs, tests, CI/debugging, compile errors, signing, and flaky tests.

## Use In New Projects
When a new project starts:
1. Copy or reference this `global` folder.
2. Create a sibling project-specific folder named after the new project.
3. Put all app-specific contracts, file paths, product entities, UI values, persistence rules, and task constraints into that project folder.
4. Keep reusable rules here only if they are valid across projects.

## Rule Of Thumb
- If the rule mentions `TchopApp`, concrete app files, feed cards, SwiftData schema details, channel names, task ids, or current worktree paths, it belongs in the project-specific folder.
- If the rule describes general working style, prompt workflow, no-overengineering policy, documentation hygiene, or debugging/review/test methodology, it belongs here.
