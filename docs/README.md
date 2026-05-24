# Documentation Map

## Purpose
Entry point for project docs: what to read first and where to place new information.

- Read active docs first.
- Use archives only when active docs are insufficient.
- Documentation is not optional: before substantive work, confirm the active docs/rules needed for the current task are loaded and use them as the source of truth.
- After any chat/context reset, run the bootstrap read before coding or changing docs.

## Default Read Order
1. `./PROJECT_DOCUMENTATION.md`
2. `./PROJECT_HEALTH.md`
3. `./docs/CURRENT_USER_OVERRIDES.md`
4. `./docs/AGENT_RULES.md`
5. `./docs/WORK_CONTINUITY.md`
6. Current task docs: `./.zenflow/tasks/new-task-be0b/handoff.md`, `./.zenflow/tasks/new-task-be0b/plan.md`, task rules
7. Scope-specific docs listed below.

## One-Time Bootstrap After Chat Reset
On new chat/context reset, read once:
1. this file
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/WORK_CONTINUITY.md`
5. `./docs/CURRENT_USER_OVERRIDES.md`
6. `./docs/AGENT_RULES.md`
7. current task docs (`./.zenflow/tasks/new-task-be0b/handoff.md`, `./.zenflow/tasks/new-task-be0b/plan.md`, task rules)

Re-read full stack if architecture/rules/phase changed, continuity is unclear, or the user explicitly asks to refresh documentation state.

## Mandatory Active Documentation Index
For the current `new-task-be0b` worktree/task, the active documentation set is:

### Project Baseline
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CURRENT_USER_OVERRIDES.md`

### Production Quality And Review Gates
- `./docs/PRODUCTION_QUALITY_GATES.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `./docs/DEFINITION_OF_DONE.md`

### iOS Production Standards
- `./docs/IOS_TESTING_STRATEGY.md`
- `./docs/IOS_SECURITY_PRIVACY_GATE.md`
- `./docs/IOS_OBSERVABILITY_STANDARD.md`
- `./docs/IOS_RELEASE_CHECKLIST.md`
- `./docs/IOS_ACCESSIBILITY_STANDARD.md`
- `./docs/IOS_PERFORMANCE_BUDGETS.md`
- `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`
- `./docs/IOS_DATA_MIGRATION_STANDARD.md`
- `./docs/DESIGN_SYSTEM_GOVERNANCE.md`
- `./docs/CI_CD_QUALITY_GATES.md`
- `./docs/DEPENDENCY_POLICY.md`

### TchopApp-Specific Runtime Docs
- `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`
- `./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `./docs/PACKAGES_AND_MANAGERS.md`
- `./docs/IOS_ARCHITECTURE_REFERENCE.md`
- `./docs/SHARE_EXTENSION_VALIDATION.md`

### Prompts And Knowledge
- `./docs/agent-prompts/README.md`
- `./docs/knowledge/global/README.md`
- `./docs/knowledge/global/ios/README.md`
- `./docs/knowledge/TchopApp/README.md`

### Task Docs
- `./.zenflow/tasks/new-task-be0b/handoff.md`
- `./.zenflow/tasks/new-task-be0b/plan.md`
- `./.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `./.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
- `./.zenflow/tasks/new-task-be0b/share-extension-validation-report.md`

### Skills
- `./.codex/skills/tchop-feed-cards/SKILL.md`
- `./.codex/skills/tchop-feed-cards/references/feed-card-contract.md`
- `./.codex/skills/tchop-packages/SKILL.md`
- `./.codex/skills/tchop-packages/references/package-rules.md`
- `./.codex/skills/ios-production-auditor/SKILL.md`
- `./.codex/skills/ios-performance-profiler/SKILL.md`
- `./.codex/skills/ios-security-privacy/SKILL.md`
- `./.codex/skills/ios-accessibility/SKILL.md`
- `./.codex/skills/ios-release-engineering/SKILL.md`
- `./.codex/skills/ios-data-migration/SKILL.md`
- `./.codex/skills/ios-api-contracts/SKILL.md`
- `./.codex/skills/ios-test-strategy/SKILL.md`

## Canonical Document Roles
- **`./PROJECT_DOCUMENTATION.md`**: stable app architecture and runtime baseline.
- **`./PROJECT_HEALTH.md`**: package/manager ownership boundaries.
- **`./TESTING_INSTRUCTIONS.md`**: active verification workflow and levels for this project.
- **`./docs/AGENT_RULES.md`**: short mandatory implementation guardrails.
- **`./docs/CURRENT_USER_OVERRIDES.md`**: current task/user overrides that must be applied before general defaults.
- **`./docs/PRODUCTION_QUALITY_GATES.md`**: mandatory broad production-quality review gates.
- **`./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`**: concrete audit/review checklist and forbidden-pattern stop list.
- **`./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`**: broad review trigger and completeness gate for `ревью`/review/audit.
- **`./docs/IOS_PRODUCTION_READINESS_STANDARD.md`**: cross-cutting iOS production-ready definition.
- **`./docs/IOS_TESTING_STRATEGY.md`**: production test/verification decision matrix.
- **`./docs/IOS_SECURITY_PRIVACY_GATE.md`**: security/privacy/logging/sensitive-data gate.
- **`./docs/IOS_OBSERVABILITY_STANDARD.md`**: crash, analytics, logs, and performance signal rules.
- **`./docs/IOS_RELEASE_CHECKLIST.md`**: TestFlight/App Store/signing/release checklist.
- **`./docs/IOS_ACCESSIBILITY_STANDARD.md`**: accessibility gate.
- **`./docs/IOS_PERFORMANCE_BUDGETS.md`**: measurable performance expectations.
- **`./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`**: API/backend integration rules.
- **`./docs/IOS_DATA_MIGRATION_STANDARD.md`**: data migration and compatibility rules.
- **`./docs/DESIGN_SYSTEM_GOVERNANCE.md`**: token/component/visual-effect governance.
- **`./docs/DEFINITION_OF_DONE.md`**: task completion contract.
- **`./docs/CI_CD_QUALITY_GATES.md`**: automated quality gates.
- **`./docs/DEPENDENCY_POLICY.md`**: third-party dependency policy.
- **`./docs/UI_PIXEL_PERFECT_WORKFLOW.md`**: UI/design implementation workflow from screenshots/Figma/PDF/CSS.
- **`./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`**: feed card persistence and media durability contract.
- **`./docs/PACKAGES_AND_MANAGERS.md`**: reusable package/manager integration guide.
- **`./docs/WORK_CONTINUITY.md`**: durable resume state and universal transition prompt.
- **`./docs/SHARE_EXTENSION_VALIDATION.md`**: share-extension validation matrix.
- **`./docs/agent-prompts/README.md`**: prompt preset index and conflict rules.
- **`./docs/knowledge/global/`**: reusable cross-project rules and prompt presets.
- **`./docs/knowledge/TchopApp/`**: project-specific TchopApp rules/contracts/context.
- **`./.zenflow/tasks/.../handoff.md`**: current task status/resume context.
- **`./.zenflow/tasks/.../plan.md`**: current execution plan only.

## Placement Rules For New Information
- **Architecture/runtime baseline** → `./PROJECT_DOCUMENTATION.md`
- **Package/manager ownership** → `./PROJECT_HEALTH.md`
- **Verification workflow** → `./TESTING_INSTRUCTIONS.md` or `./docs/IOS_TESTING_STRATEGY.md`
- **Short implementation guardrails** → `./docs/AGENT_RULES.md`
- **Current task/user overrides** → `./docs/CURRENT_USER_OVERRIDES.md`
- **Production gates/checklists** → `./docs/PRODUCTION_QUALITY_GATES.md`, `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`, `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`, `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`, `./docs/DEFINITION_OF_DONE.md`
- **Security/privacy** → `./docs/IOS_SECURITY_PRIVACY_GATE.md`
- **Observability** → `./docs/IOS_OBSERVABILITY_STANDARD.md`
- **Release** → `./docs/IOS_RELEASE_CHECKLIST.md`
- **Accessibility** → `./docs/IOS_ACCESSIBILITY_STANDARD.md`
- **Performance budgets** → `./docs/IOS_PERFORMANCE_BUDGETS.md`
- **API/backend contracts** → `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`
- **Data migration** → `./docs/IOS_DATA_MIGRATION_STANDARD.md`
- **Design system** → `./docs/DESIGN_SYSTEM_GOVERNANCE.md`
- **CI/CD** → `./docs/CI_CD_QUALITY_GATES.md`
- **Dependencies** → `./docs/DEPENDENCY_POLICY.md`
- **Reusable prompt presets** → `./docs/agent-prompts/`
- **Reusable cross-project knowledge** → `./docs/knowledge/global/`
- **Project-specific knowledge** → `./docs/knowledge/<ProjectName>/`
- **Current task state** → `./.zenflow/tasks/new-task-be0b/handoff.md`
- **Current task plan/steps** → `./.zenflow/tasks/new-task-be0b/plan.md`
- **Obsolete history** → `./docs/archive/` or `./.zenflow/tasks/.../archive/`

## Hierarchy Of Truth
1. Current explicit user instruction for this worktree/task
2. Global assistant policy
3. Current user overrides
4. Canonical project docs
5. Task overlay rules
6. Current task docs
7. Archives
