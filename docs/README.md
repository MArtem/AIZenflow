# Documentation Map

## Purpose
Entry point for active project documentation, production standards, prompt presets, local skills, and static quality gates.

- Read active docs before substantive work.
- Apply `./docs/CURRENT_USER_OVERRIDES.md` before general defaults.
- Use archives only when active docs are insufficient.
- If a rule/contract changed, refresh this map before continuing.
- Documentation is part of the product baseline, not optional commentary.

## Default Read Order
1. `./PROJECT_DOCUMENTATION.md`
2. `./PROJECT_HEALTH.md`
3. `./docs/CURRENT_USER_OVERRIDES.md`
4. `./docs/AGENT_RULES.md`
5. `./docs/WORK_CONTINUITY.md`
6. Current task docs: `./.zenflow/tasks/new-task-be0b/handoff.md`, `./.zenflow/tasks/new-task-be0b/plan.md`, task rules
7. Scope-specific docs from the index below.

## One-Time Bootstrap After Chat Reset
On a new chat/context reset, read once:
1. this file
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/WORK_CONTINUITY.md`
5. `./docs/CURRENT_USER_OVERRIDES.md`
6. `./docs/AGENT_RULES.md`
7. current task docs: `./.zenflow/tasks/new-task-be0b/handoff.md`, `./.zenflow/tasks/new-task-be0b/plan.md`
8. relevant prompt/skill/standard docs for the task.

Re-read the full stack only when architecture/rules/phase changed, continuity is unclear, or the user explicitly asks to refresh documentation state.

## Mandatory Active Documentation Index

### Project Baseline
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
- `./docs/CURRENT_USER_OVERRIDES.md`

### Production Quality And Review Gates
- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PR_REVIEW_TEMPLATE.md`
- `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`
- `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`
- `./docs/IOS_PRODUCTION_SCORECARD.md`
- `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`
- `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`
- `./docs/PRODUCTION_QUALITY_GATES.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `./docs/DEFINITION_OF_DONE.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`
- `./docs/STATIC_QUALITY_GATE_POLICY.md`

### Product, Governance, And Operating Model
- `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`
- `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`
- `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md`
- `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`
- `./docs/INCIDENT_RESPONSE_STANDARD.md`
- `./docs/PRODUCT_HEALTH_SLO.md`
- `./docs/RISK_REGISTER.md`
- `./docs/TECH_DEBT_REGISTER.md`

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
- `./docs/MODULAR_ARCHITECTURE_STANDARD.md`
- `./docs/IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`
- `./docs/DEVELOPER_EXPERIENCE_STANDARD.md`
- `./docs/QA_TEST_PLAN_STANDARD.md`
- `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`
- `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`
- `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`
- `./docs/COMPATIBILITY_MATRIX.md`
- `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`
- `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`
- `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`
- `./docs/IOS_MVVM_INTENT_API_STANDARD.md`
- `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`
- `./docs/IOS_OFFLINE_SYNC_STANDARD.md`
- `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`
- `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`
- `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`
- `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`
- `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`
- `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`
- `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`

### TchopApp-Specific Runtime Docs
- `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`
- `./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`
- `./docs/PACKAGES_AND_MANAGERS.md`
- `./docs/PACKAGE_USAGE_IN_TCHOPAPP.md`
- `./Packages/SDKCreation/README.md`
- `./PackagesForReuse/AppSecureStorage/README.md`
- `./PackagesForReuse/AppFeatureFlags/README.md`
- `./PackagesForReuse/AppLogging/README.md`
- `./PackagesForReuse/AppObservability/README.md`
- `./PackagesForReuse/AppConnectivity/README.md`
- `./PackagesForReuse/AppDeviceInfo/README.md`
- `./PackagesForReuse/AppEnvironment/README.md`
- `./PackagesForReuse/AppPermissions/README.md`
- `./PackagesInUse/README.md`
- `./PackagesForReuse/README.md`
- `./PackagesForReuse/CONNECTING_PACKAGES.md`
- `./PackagesForReuse/ADOPTION_AUDIT.md`
- `./docs/IOS_ARCHITECTURE_REFERENCE.md`
- `./docs/SHARE_EXTENSION_VALIDATION.md`

### Prompt Presets And Knowledge
- `./docs/agent-prompts/README.md`
- `./docs/knowledge/global/README.md`
- `./docs/knowledge/global/ios/README.md`
- `./docs/knowledge/TchopApp/README.md`


### Documentation Split / Transfer Baseline
- `./docs/documentation-split/README.md`
- `./docs/documentation-split/app-specific/APP_SPECIFIC_MANIFEST.md`
- `./docs/documentation-split/reusable/REUSABLE_MANIFEST.md`
- `./docs/documentation-split/reusable/REUSABLE_USER_AND_AGENT_RULES.md`
- `./docs/documentation-split/reusable/NEW_PROJECT_PORTING_GUIDE.md`
- `./docs/documentation-split/reusable/NEUTRAL_PACKAGE_PROMOTION_GUIDE.md`
- `./docs/documentation-split/reusable/EXTERNAL_SKILL_DEPENDENCIES.md`
- `./docs/documentation-split/reusable/TRANSFER_CHECKLIST.md`
- `./docs/documentation-split/reusable/infrastructure-sdk/README.md`
- `./docs/documentation-split/reusable/scripts/install_reusable_baseline.sh`

### Task Docs
- `./.zenflow/tasks/new-task-be0b/handoff.md`
- `./.zenflow/tasks/new-task-be0b/plan.md`
- `./.zenflow/tasks/new-task-be0b/ios-engineering-rules.md`
- `./.zenflow/tasks/new-task-be0b/services-engineering-rules.md`
- `./.zenflow/tasks/new-task-be0b/share-extension-validation-report.md`

### Local Skills
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
- `./.codex/skills/ios-product-governance/SKILL.md`
- `./.codex/skills/ios-incident-ops/SKILL.md`
- `./.codex/skills/ios-modular-architecture/SKILL.md`
- `./.codex/skills/ios-qa-localization/SKILL.md`
- `./.codex/skills/ios-evidence-gate/SKILL.md`
- `./.codex/skills/ios-concurrency-runtime/SKILL.md`
- `./.codex/skills/ios-memory-cache-media/SKILL.md`
- `./.codex/skills/ios-network-resilience/SKILL.md`
- `./.codex/skills/ios-offline-sync/SKILL.md`
- `./.codex/skills/ios-lifecycle-background/SKILL.md`
- `./.codex/skills/ios-error-handling/SKILL.md`
- `./.codex/skills/ios-configuration-environments/SKILL.md`
- `./.codex/skills/ios-input-validation/SKILL.md`
- `./.codex/skills/ios-code-documentation/SKILL.md`

### Static Quality Gate Scripts
- `./scripts/check_docs_index.py`
- `./scripts/check_forbidden_patterns.py`
- `./scripts/check_secrets.py`
- `./scripts/check_large_files.py`
- `./scripts/check_localization.py`
- `./scripts/check_swiftui_hot_path_patterns.py`
- `./scripts/run_static_quality_gates.sh`
- `./scripts/validate_ios_production_framework.py`

## Canonical Document Roles

### Core Rules
- **`./PROJECT_DOCUMENTATION.md`**: stable app architecture and runtime baseline.
- **`./PROJECT_HEALTH.md`**: package/manager ownership boundaries.
- **`./TESTING_INSTRUCTIONS.md`**: active verification workflow and levels for this project.
- **`./docs/AGENT_RULES.md`**: short mandatory implementation guardrails.
- **`./docs/CURRENT_USER_OVERRIDES.md`**: current task/user overrides that must be applied before general defaults.
- **`./docs/WORK_CONTINUITY.md`**: durable resume state and universal transition prompt.
- **`./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`**: proactive new-chat trigger and compact transition-spec requirements.

### Review And Completion
- **`./docs/IOS_PRODUCTION_FRAMEWORK.md`**: canonical reusable iOS production framework and coverage matrix.
- **`./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`**: end-to-end feature workflow from intake to operation.
- **`./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`**: uniform broad audit matrix and finding format.
- **`./docs/IOS_PR_REVIEW_TEMPLATE.md`**: reusable iOS PR review template.
- **`./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`**: template for installing the framework into a new app.
- **`./docs/IOS_AGENT_PROMPT_ROUTER.md`**: routing table from task type to prompt/skill.
- **`./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`**: explicit exception/waiver policy.
- **`./docs/IOS_PRODUCTION_SCORECARD.md`**: production-readiness scoring model.
- **`./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`**: documentation ownership and freshness rules.
- **`./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`**: inline Swift/iOS documentation comment standard for contracts, ownership, external usage, side effects, concurrency, errors, invariants, and rationale.
- **`./docs/PRODUCTION_QUALITY_GATES.md`**: mandatory broad production-quality review gates.
- **`./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`**: concrete audit/review checklist and forbidden-pattern stop list.
- **`./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`**: broad review trigger and completeness gate for `ревью`/review/audit.
- **`./docs/IOS_PRODUCTION_READINESS_STANDARD.md`**: cross-cutting iOS production-ready definition.
- **`./docs/DEFINITION_OF_DONE.md`**: task completion contract.
- **`./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`**: proof requirements for claims, completion reports, and “done” status.
- **`./docs/STATIC_QUALITY_GATE_POLICY.md`**: severity and exception policy for static quality scripts.

### Product And Governance
- **`./docs/PRODUCT_REQUIREMENTS_STANDARD.md`**: product behavior, states, acceptance criteria, and non-goal requirements.
- **`./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`**: ADR threshold, decision ownership, and reversal rules.
- **`./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md`**: ownership, review routing, and blocked-change criteria.
- **`./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`**: flag lifecycle, rollout controls, rollback expectations.
- **`./docs/INCIDENT_RESPONSE_STANDARD.md`**: severity, triage, mitigation, and postmortem expectations.
- **`./docs/PRODUCT_HEALTH_SLO.md`**: product health signals, budgets, and escalation thresholds.
- **`./docs/RISK_REGISTER.md`**: known risks, owners, mitigation, and review cadence.
- **`./docs/TECH_DEBT_REGISTER.md`**: intentional debt, owner, expiry, and paydown policy.

### iOS Engineering Standards
- **`./docs/IOS_TESTING_STRATEGY.md`**: production test/verification decision matrix.
- **`./docs/IOS_SECURITY_PRIVACY_GATE.md`**: security/privacy/logging/sensitive-data gate.
- **`./docs/IOS_OBSERVABILITY_STANDARD.md`**: crash, analytics, logs, and performance signal rules.
- **`./docs/IOS_RELEASE_CHECKLIST.md`**: TestFlight/App Store/signing/release checklist.
- **`./docs/IOS_ACCESSIBILITY_STANDARD.md`**: accessibility gate.
- **`./docs/IOS_PERFORMANCE_BUDGETS.md`**: measurable performance expectations.
- **`./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`**: API/backend integration rules.
- **`./docs/IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`**: neutral reusable infrastructure package rules for new iOS projects.
- **`./docs/IOS_DATA_MIGRATION_STANDARD.md`**: data migration and compatibility rules.
- **`./docs/DESIGN_SYSTEM_GOVERNANCE.md`**: token/component/visual-effect governance.
- **`./docs/CI_CD_QUALITY_GATES.md`**: automated quality gates.
- **`./docs/DEPENDENCY_POLICY.md`**: third-party dependency policy.
- **`./docs/MODULAR_ARCHITECTURE_STANDARD.md`**: module boundaries, dependency direction, package/API ownership.
- **`./docs/DEVELOPER_EXPERIENCE_STANDARD.md`**: local setup, diagnostics, scripts, and repeatable workflows.
- **`./docs/QA_TEST_PLAN_STANDARD.md`**: manual/automated QA plan structure.
- **`./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`**: localization, pluralization, length, RTL, locale formatting.
- **`./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`**: entitlements, app groups, background modes, extensions, widgets, deep links.
- **`./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`**: data classification, retention, export/delete, and compliance expectations.
- **`./docs/COMPATIBILITY_MATRIX.md`**: supported OS/devices/features and degradation expectations.
- **`./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`**: async/await, actor ownership, task lifecycle, cancellation, Sendable, Swift 6 readiness.
- **`./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`**: memory, cache, media, file, thumbnail, and large-asset rules.
- **`./docs/IOS_MVVM_INTENT_API_STANDARD.md`**: default ViewModel API standard: explicit intent methods, no generic `send(_ action:)` dispatcher by default.
- **`./docs/IOS_UI_STATE_RENDERING_STANDARD.md`**: SwiftUI/UIKit state invalidation, lazy rendering, row identity, and render-path rules.
- **`./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`**: mobile network reliability, retries, cancellation, idempotency, and error taxonomy.
- **`./docs/IOS_OFFLINE_SYNC_STANDARD.md`**: offline mutations, pending sync, conflicts, app-group durability.
- **`./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`**: launch, scenes, background work, push, deep links, widgets, extensions.
- **`./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`**: user-visible failure states, retry, optimistic UI, localized errors.
- **`./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`**: analytics event ownership, privacy, bounded properties, product signals.
- **`./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`**: dev/staging/prod config, secrets, debug gating, flags, diagnostics.
- **`./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`**: imported content, external URLs, rich text, payload validation.
- **`./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`**: StoreKit/payments/subscription production rules when applicable.
- **`./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`**: permissions, files, photos, camera, security-scoped resources.

## Placement Rules For New Information
- **Product requirements / acceptance criteria** → `./docs/PRODUCT_REQUIREMENTS_STANDARD.md` or feature-specific task docs.
- **Architecture/runtime baseline** → `./PROJECT_DOCUMENTATION.md`.
- **Architecture decisions** → `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md` plus an ADR if needed.
- **Package/module ownership** → `./PROJECT_HEALTH.md`, `./docs/PACKAGES_AND_MANAGERS.md`, or `./docs/MODULAR_ARCHITECTURE_STANDARD.md`.
- **Verification workflow** → `./TESTING_INSTRUCTIONS.md`, `./docs/IOS_TESTING_STRATEGY.md`, `./docs/QA_TEST_PLAN_STANDARD.md`, or `./docs/CI_CD_QUALITY_GATES.md`.
- **Short implementation guardrails** → `./docs/AGENT_RULES.md`.
- **Current task/user overrides** → `./docs/CURRENT_USER_OVERRIDES.md`.
- **Reusable iOS framework / umbrella coverage** → `./docs/IOS_PRODUCTION_FRAMEWORK.md`.
- **Feature lifecycle** → `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`.
- **Broad audit matrix** → `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`.
- **PR review template** → `./docs/IOS_PR_REVIEW_TEMPLATE.md`.
- **New project bootstrap** → `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`.
- **Prompt/skill routing** → `./docs/IOS_AGENT_PROMPT_ROUTER.md`.
- **Exceptions/waivers** → `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`.
- **Readiness scoring** → `./docs/IOS_PRODUCTION_SCORECARD.md`.
- **Documentation maintenance** → `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`.
- **Inline code documentation/comments** → `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`.
- **Production gates/checklists** → `./docs/PRODUCTION_QUALITY_GATES.md`, `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`, `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`, `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`, `./docs/DEFINITION_OF_DONE.md`, `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`, `./docs/STATIC_QUALITY_GATE_POLICY.md`.
- **Security/privacy/data compliance** → `./docs/IOS_SECURITY_PRIVACY_GATE.md` or `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`.
- **Observability/incidents/SLOs** → `./docs/IOS_OBSERVABILITY_STANDARD.md`, `./docs/INCIDENT_RESPONSE_STANDARD.md`, or `./docs/PRODUCT_HEALTH_SLO.md`.
- **Rollouts/release** → `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md` or `./docs/IOS_RELEASE_CHECKLIST.md`.
- **Accessibility** → `./docs/IOS_ACCESSIBILITY_STANDARD.md`.
- **Performance budgets** → `./docs/IOS_PERFORMANCE_BUDGETS.md`.
- **API/backend contracts** → `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`.
- **Data migration** → `./docs/IOS_DATA_MIGRATION_STANDARD.md`.
- **Design system** → `./docs/DESIGN_SYSTEM_GOVERNANCE.md`.
- **Dependencies** → `./docs/DEPENDENCY_POLICY.md`.
- **Concurrency/runtime** → `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`.
- **Memory/cache/media/files** → `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`.
- **UI rendering/state** → `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`.
- **Network resilience** → `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`.
- **Offline/sync** → `./docs/IOS_OFFLINE_SYNC_STANDARD.md`.
- **Lifecycle/background/deep links/push/widgets/extensions** → `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`.
- **Error handling/user feedback** → `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`.
- **Analytics/telemetry taxonomy** → `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`.
- **Configuration/environments** → `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`.
- **Input validation/content safety** → `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`.
- **StoreKit/payments** → `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`.
- **Camera/photos/files/permissions** → `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`.
- **Reusable prompt presets** → `./docs/agent-prompts/`.
- **Reusable cross-project knowledge** → `./docs/knowledge/global/`.
- **Project-specific knowledge** → project-specific folder under `./docs/knowledge/`.
- **Current task state** → `./.zenflow/tasks/new-task-be0b/handoff.md`.
- **Current task plan/steps** → `./.zenflow/tasks/new-task-be0b/plan.md`.
- **Obsolete history** → `./docs/archive/` or task archive folder.

## Hierarchy Of Truth
1. Current explicit user instruction for this worktree/task.
2. Global assistant policy.
3. Current user overrides.
4. Canonical project docs.
5. Task overlay rules.
6. Current task docs.
7. Archives.
