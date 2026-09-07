# Library Structure

```text
AGENTS.md
README.md
MASTER_PLAN.md
POLICY_ROUTER.md

config/
  project.env.example
  PROJECT_PROFILE.example.yaml
  risk-policy.yaml

policies/
  00-engineering-principles.md
  01-task-repository-analysis.md
  02-architecture-boundaries.md
  03-swift-language.md
  04-swift-concurrency.md
  05-swiftui.md
  06-uikit.md
  07-state-navigation.md
  08-networking.md
  09-persistence-migrations.md
  10-security-privacy.md
  11-memory-lifetime.md
  12-performance.md
  13-error-resilience.md
  14-testing.md
  15-accessibility.md
  16-localization.md
  17-dependencies-spm.md
  18-logging-observability.md
  19-background-lifecycle.md
  20-api-modularity.md
  21-build-config-signing.md
  22-diff-review.md
  23-git-commit-pr.md
  24-release-safety.md
  25-legacy-modernization.md
  26-ai-agent-rules.md

gates/
  GATE_MATRIX.md
  GATE_CATALOG.md
  gates.yaml

checklists/
  pre-change.md
  pre-commit.md
  pre-pr.md
  concurrency.md
  security-privacy.md
  migration.md
  ui-accessibility-localization.md

templates/
  PROJECT_PROFILE.yaml
  TASK_ANALYSIS.md
  CHANGE_PLAN.md
  VERIFICATION_REPORT.md
  ADR.md
  EXCEPTION.md
  PULL_REQUEST.md

scripts/
  discover_project.sh
  quality_gate.sh
  build.sh
  test.sh
  static_checks.sh
  diff_check.sh
  dependency_check.sh
  privacy_check.sh
  secrets_check.sh
  forbidden_patterns.sh
  lib/common.sh

references/
  SOURCES.md
```

## Why not one giant AGENTS.md?

Codex automatically aggregates `AGENTS.md`/`AGENTS.override.md` instructions through the directory hierarchy and the default project-document budget is finite. The root contract therefore stays compact and commands the agent to load only the policies relevant to the current change.

A real project may add deeper `AGENTS.md` files to modules/features when local constraints genuinely differ. More-specific scoped instructions should be used for real differences, not to duplicate the global library.
