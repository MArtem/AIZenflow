# Documentation Map

## Purpose
Entry point for active project documentation, production standards, prompt presets, reusable skills, and static quality gates.

## Default Read Order
1. `./PROJECT_DOCUMENTATION.md`
2. `./PROJECT_HEALTH.md`
3. `./docs/CURRENT_USER_OVERRIDES.md`
4. `./docs/AGENT_RULES.md`
5. `./docs/WORK_CONTINUITY.md`
6. `./docs/MODEL_ROUTING_RULE.md`
7. `./docs/DOCUMENT_LIBRARY_GUIDE.md`
8. `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
9. `./docs/ALL_DOCUMENTS_INVENTORY.md`
10. current task handoff/plan under `./.zenflow/tasks/<task-id>/` when available
11. scope-specific docs from this index

## Mandatory Active Documentation Index

### Project Baseline
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/MODEL_ROUTING_RULE.md`
- `./docs/DOCUMENT_LIBRARY_GUIDE.md`
- `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
- `./docs/SOURCE_OF_TRUTH_MAP.md`
- `./docs/AGENT_PREFLIGHT_CHECKLIST.md`
- `./docs/COMPLETION_REPORT_CONTRACT.md`
- `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md`
- `./docs/ALL_DOCUMENTS_INVENTORY.md`

### Documentation Boundary
- `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
- `./docs/SOURCE_OF_TRUTH_MAP.md`
- `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md`
- `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md`

Apply this before editing or moving reusable docs, app-specific docs, task docs, prompts, skills, package docs, architecture cases, manifests, or new-project bootstrap files.

Reusable/global material belongs in `documentation-vault/reusable/`; app-specific material belongs in `documentation-vault/apps/<AppName>/`; task-only state belongs in `documentation-vault/tasks/<task-id>/` or local task docs. Local app exceptions do not update reusable rules without explicit promotion approval.

### Bootstrap And Completion Contracts
- `./docs/NEW_PROJECT_START_CONTRACT.md`
- `./docs/AGENT_PREFLIGHT_CHECKLIST.md`
- `./docs/COMPLETION_REPORT_CONTRACT.md`

### Static Quality Gate Scripts
- `./scripts/check_bootstrap_contract.py`
- `./scripts/check_documentation_boundaries.py`

### Reusable Production Standards
- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `./docs/PRODUCTION_QUALITY_GATES.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/DEFINITION_OF_DONE.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`

### Prompt Presets
- `./docs/agent-prompts/README.md`
- `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`

### Reusable Skills
- `./.codex/skills/`

### App-Specific Docs
Add app-specific docs here after the product shape is known.
