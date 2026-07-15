# Task Type Documentation Router

## Purpose
Keep quality high while reducing unnecessary context load.

Agents must read the compact Level 0 baseline first, then select only the task-specific routes below. Do not read the entire documentation library by default.

## Core Rule
Use this router after the Level 0 startup read and before opening deep standards, prompts, package docs, skills, or archived material.

Report the selected route in working/completion messages:

```text
Docs route: Level 0 + <route names>
Deep references skipped/applied: <reason>
```

If a task crosses multiple concerns, combine routes. If a route reveals ambiguity or risk, read the next deeper reference for that concern.

## Levels

### Level 0 — Always-read operating baseline
Read once after a new chat/context reset, or when the user explicitly asks to refresh rules:

1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
8. `./docs/MODEL_ROUTING_RULE.md`
9. `./docs/DOCUMENT_BOUNDARY_STANDARD.md`
10. current task `handoff.md` and `plan.md`
11. this router

Level 0 is not enough for implementation, review, or completion claims. It only orients the agent.

### Level 1 — Governance routers and source-of-truth maps
Read when the task touches documentation movement, reusable rules, task state, new projects, completion reporting, or non-trivial work planning:

- `./docs/SOURCE_OF_TRUTH_MAP.md`
- `./docs/AGENT_PREFLIGHT_CHECKLIST.md`
- `./docs/COMPLETION_REPORT_CONTRACT.md`
- `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md`
- `./docs/NEW_PROJECT_START_CONTRACT.md` for new tasks/projects/worktrees/apps
- `./docs/DOCS_REPO_OPERATIONS.md` for global documentation repository operations

### Level 2 — Task-specific standards and prompts
Read only the standards relevant to the current task type.

| Task type | Read |
|---|---|
| iOS feature implementation or refactor | `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`, `./docs/PRODUCTION_QUALITY_GATES.md`, `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`, relevant iOS standard below |
| iOS review/audit/production-ready claim | `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`, `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`, `./docs/DEFINITION_OF_DONE.md`, `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` |
| New iOS app/project bootstrap | `./docs/NEW_PROJECT_START_CONTRACT.md`, `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`, `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md` |
| Architecture/navigation/state ownership | `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`, `./docs/MODULAR_ARCHITECTURE_STANDARD.md`, `./docs/IOS_MVVM_INTENT_API_STANDARD.md` |
| Swift concurrency/runtime/task lifecycle | `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md` |
| SwiftUI rendering/performance | `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`, `./docs/IOS_PERFORMANCE_BUDGETS.md` |
| Memory/cache/media/files | `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`, `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md` |
| Persistence/migration/data loss | `./docs/IOS_DATA_MIGRATION_STANDARD.md`, `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md` |
| Network/API/offline/sync | `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`, `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`, `./docs/IOS_OFFLINE_SYNC_STANDARD.md` |
| Security/privacy/secrets/imported project intake | `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md`, `./docs/IOS_SECURITY_PRIVACY_GATE.md`, `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`, `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md` |
| Accessibility/localization/QA | `./docs/IOS_ACCESSIBILITY_STANDARD.md`, `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`, `./docs/QA_TEST_PLAN_STANDARD.md` |
| Release/signing/TestFlight/App Store | `./docs/IOS_RELEASE_CHECKLIST.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, `./docs/CI_CD_QUALITY_GATES.md` |
| Observability/incidents/rollout | `./docs/IOS_OBSERVABILITY_STANDARD.md`, `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`, `./docs/INCIDENT_RESPONSE_STANDARD.md`, `./docs/PRODUCT_HEALTH_SLO.md` |
| Figma/design-to-SwiftUI | `./docs/agent-prompts/figma-mcp-swiftui-implementation.md`, `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`, `./docs/DESIGN_SYSTEM_GOVERNANCE.md` |
| AI/App Intents/Foundation Models | `./docs/agent-prompts/AI_iOS_MASTER_PROMPT.md`, `./PackagesForReuse/AppIntentSupport/README.md` when package adoption is relevant |
| Code comments/documentation pass | `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`, `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md` |
| Reusable packages/managers/package adoption | `./docs/PACKAGES_AND_MANAGERS.md`, `./docs/IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`, relevant package README/catalog |
| Static gates/scripts | `./docs/STATIC_QUALITY_GATE_POLICY.md`, relevant `./scripts/check_*.py` or `./scripts/run_static_quality_gates.sh` |

### Level 3 — Deep references
Read only when Level 2 says more depth is required, the task is broad/high-risk, or the user asks for a full audit/design:

- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PRODUCTION_SCORECARD.md`
- `./docs/IOS_ARCHITECTURE_REFERENCE.md`
- architecture catalog under `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/architecture-cases/`
- complete package vault docs under `./PackagesForReuse/`

### Archive — Not default input
Read archive/history/recovery material only when:

- active docs contradict each other;
- current task state is unclear;
- the user asks to recover or compare historical decisions;
- a migration needs old behavior.

## Route Selection Examples

- “Fix a SwiftUI redraw bug”: Level 0 + SwiftUI rendering/performance + relevant source files.
- “Audit imported project for secrets”: Level 0 + Governance + Security/privacy/secrets + static secret checks.
- “Implement Figma screen”: Level 0 + Figma/design-to-SwiftUI + design-system + accessibility if UI will be implemented.
- “Create a new iOS app”: Level 0 + Governance + New iOS app/project bootstrap + architecture/navigation/state ownership + secrets.
- “Add App Intents with Foundation Models”: Level 0 + AI/App Intents/Foundation Models + security/privacy + product requirements + relevant package docs.

## Non-Goals
- This router does not lower the engineering bar.
- This router does not remove mandatory gates for work that actually needs them.
- This router does not permit completion claims without evidence.
- This router does not override explicit user instructions, `AGENTS.md`, or task-local rules.

