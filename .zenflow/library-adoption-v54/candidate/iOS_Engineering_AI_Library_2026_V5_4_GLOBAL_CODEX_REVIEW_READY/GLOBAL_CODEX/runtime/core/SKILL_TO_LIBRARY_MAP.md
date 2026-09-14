# Skill → Deep Library Map
> **GLOBAL CODEX EDITION — PATH MAPPING**  
> This document originated in the repository-local evolution of the library. In this global edition, any repository-local infrastructure path below is a **logical legacy alias**, not an instruction to create that path in a client repository. Map it as follows:
> - `.ai/project` / `.ai/adaptive` → the external per-repository state returned by `python3 "${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py" path --repo .` (adaptive/generated data lives under that state directory).
> - `.ai/ios-library` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/library`.
> - `.ai/ios-core` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/core`.
> - `.ai/orchestration` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/orchestration` plus the external per-repository orchestration state.
> - `scripts/ai/...` → use the global `ios_ai.py` CLI above (or the exact command in an installed skill's `references/INSTALLATION.md`).
> - repository `.agents/skills` / `.codex/skills` → the **user-global skill root chosen by `install_global.py`**.
> - `REPOSITORY_KIT/repo-root` → historical packaging reference only; it is not installed into client repositories in this edition.
> **Never create/copy library `.ai`, `.agents`, `.codex`, or `scripts/ai` infrastructure inside a client repository unless the user explicitly asks for a repository-local export. Repository-local `AGENTS.md` and repository facts remain more specific than this global guidance.**


If `.ai/ios-library/` is installed, use this map to choose a narrow deep reference. Do not bulk-load directories.

- `ioslib-swift-concurrency` → `.ai/ios-library/03_CONCURRENCY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-architecture` → `.ai/ios-library/04_ARCHITECTURE/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-swiftui` → `.ai/ios-library/05_SWIFTUI/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-uikit` → `.ai/ios-library/06_UIKIT/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-navigation` → `.ai/ios-library/07_NAVIGATION_DEEPLINKS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-networking-auth` → `.ai/ios-library/08_NETWORKING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-api-contract` → `.ai/ios-library/01_DISCOVERY_PRODUCT/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-persistence` → `.ai/ios-library/09_PERSISTENCE_DATA/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-data-migration` → `.ai/ios-library/20_MIGRATION_LEGACY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-offline-sync` → `.ai/ios-library/09_PERSISTENCE_DATA/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-testing` → `.ai/ios-library/10_TESTING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-test-flake` → `.ai/ios-library/10_TESTING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-performance` → `.ai/ios-library/11_PERFORMANCE_MEMORY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-memory-leaks` → `.ai/ios-library/11_PERFORMANCE_MEMORY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-security-privacy` → `.ai/ios-library/12_SECURITY_PRIVACY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-accessibility-localization` → `.ai/ios-library/13_ACCESSIBILITY_LOCALIZATION/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-dependencies` → `.ai/ios-library/28_ECOSYSTEM_INTEROP/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-modularity-spm` → `.ai/ios-library/16_BUILD_MODULARITY_TOOLING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-build-ci` → `.ai/ios-library/17_CI_CD_RELEASE/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-release` → `.ai/ios-library/17_CI_CD_RELEASE/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-hotfix-release` → `.ai/ios-library/17_CI_CD_RELEASE/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-feature-flags` → `.ai/ios-library/01_DISCOVERY_PRODUCT/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-observability` → `.ai/ios-library/18_OBSERVABILITY_DEBUGGING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-storekit` → `.ai/ios-library/14_PLATFORM_SERVICES/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-app-intents` → `.ai/ios-library/14_PLATFORM_SERVICES/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-ai-ml` → `.ai/ios-library/15_AI_INTELLIGENCE/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-media-graphics` → `.ai/ios-library/25_MEDIA_GRAPHICS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-system-integrations` → `.ai/ios-library/27_SYSTEM_INTEGRATION/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-sdk-api` → `.ai/ios-library/28_ECOSYSTEM_INTEROP/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-legacy-modernization` → `.ai/ios-library/20_MIGRATION_LEGACY/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-background-execution` → `.ai/ios-library/14_PLATFORM_SERVICES/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-design-system` → `.ai/ios-library/29_DESIGN_SYSTEM/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-code-review` → `.ai/ios-library/19_CODE_REVIEW_REFACTOR/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-pr-review` → `.ai/ios-library/19_CODE_REVIEW_REFACTOR/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-diagnostic` → `.ai/ios-library/18_OBSERVABILITY_DEBUGGING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-crash-debugging` → `.ai/ios-library/18_OBSERVABILITY_DEBUGGING/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-implementation` → `.ai/ios-library/21_AGENT_WORKFLOWS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-change-plan` → `.ai/ios-library/21_AGENT_WORKFLOWS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-repo-intake` → `.ai/ios-library/21_AGENT_WORKFLOWS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
- `ioslib-task-router` → `.ai/ios-library/21_AGENT_WORKFLOWS/` + matching `.ai/ios-library/31_DEEP_PLAYBOOKS/OP-IOS-*`
