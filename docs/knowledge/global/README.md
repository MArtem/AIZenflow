# Global Knowledge Base

## Purpose
Reusable app-neutral iOS knowledge that should be portable to future projects.

This section should avoid current-app file paths, app entity names, app-specific dimensions, and product-specific contracts.

## Contents
- `./ios/`: reusable iOS production knowledge index.
- Active reusable agent rules live in `../../CURRENT_USER_OVERRIDES.md` and related routed governance documents.
- Active prompt templates live in `../../agent-prompts/`; this knowledge directory does not duplicate them.

## Use In New Projects
When a new project starts:
1. Copy or reference the routed reusable baseline and this `global/ios` knowledge area.
2. Create a sibling project-specific folder named after the new project.
3. Put all app-specific contracts, file paths, product entities, UI values, persistence rules, and task constraints into that project folder.
4. Keep reusable rules here only if they are valid across projects.

## Rule Of Thumb
- If the rule mentions `source-app`, concrete app files, feed cards, SwiftData schema details, channel names, task ids, or current worktree paths, it belongs in the project-specific folder.
- General working style, prompt workflow, and documentation governance belong in the routed baseline rule or `agent-prompts` area, not in a second knowledge copy.

## Additional Reusable Production Coverage
For large iOS/product projects, keep reusable standards for:
- product requirements and acceptance criteria
- architecture decision governance
- code ownership and review policy
- evidence-based completion
- feature flags and rollout/rollback
- incident response and product health SLOs
- risk and tech-debt registers
- modular architecture and developer experience
- QA planning and localization/internationalization
- platform capabilities, data governance, and compatibility matrices

These are project-agnostic and should be copied or adapted into new serious iOS products before feature work scales.
