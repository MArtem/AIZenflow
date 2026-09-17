# L5 proposed routing changeset and skill inventory

Date: **2026-09-12**. Status: **PROPOSED / NOT PROMOTED**.

This is a task-local adoption proposal, not a change to the canonical documentation vault and
not a global installation. It records the smallest route that can be evaluated safely.

## Authority and observed starting point

- The existing canonical documentation router remains the authority for Level 0 startup and
  domain routing. The candidate must not replace or copy it.
- The candidate's `GLOBAL_CODEX/AGENTS.global.block.md` is conditionally applicable to iOS/Swift
  work, but it is still model guidance, not a sandbox, approval grant or command interceptor.
- The candidate's `TASK_ROUTING_MATRIX.md` routes by task outcome, while the candidate's 60
  `ioslib-*` skills are additional provider skills. They are not evidence that all 60 are
  compatible with the currently active canonical `ios-*` skills.
- The current local worktree exposes 31 canonical `ios-*` skills. The name sets do not match one
  to one; therefore the inventory below is a trigger/capability triage, not semantic acceptance.

## Proposed minimal automatic route

The changeset to review for future canonical promotion is:

1. At task start, use the existing canonical router to determine platform, affected symbols and
   risk. Do not ask the user to select a library document manually when a supported route matches.
2. For an iOS/Swift review, load the common engineering/evidence contract plus only the pinned
   subset below. The subset is identified by the candidate input SHA and per-file manifest hashes.
3. Route specialized knowledge only when observed task/repository signals support it. For an
   unknown or non-iOS project, use the common route and mark iOS specialty as unsupported.
4. Keep knowledge passive: reading a reference must not invoke the CLI, write state, change Git,
   run build/test/network/dependency/signing/release commands, or create a project file.
5. Permit the runtime only in a separately explicit runtime task. Its exact state root and
   repository scope must be written in that task packet; it never follows automatically from
   loading a skill.
6. If the pinned root, manifest or source hash is unavailable/altered, mark the dependent
   knowledge route unavailable and continue only with canonical baseline rules. Do not silently
   substitute another version.

Pinned pilot subset:

| Route | Candidate references | Required gate |
|---|---|---|
| concurrency/task lifetime | `03_CONCURRENCY/IOS-03-06_TASK_LIFETIME.md`, `IOS-03-07_CANCELLATION.md` | Swift/compiler semantics and actual lifecycle evidence remain consumer-specific |
| SwiftUI state/identity | `05_SWIFTUI/IOS-05-02_STATE_OWNERSHIP.md`, `IOS-05-03_VIEW_IDENTITY.md` | ownership and task identity must be tied to concrete call sites |
| auth/retry | `08_NETWORKING/IOS-08-02_AUTH_REFRESH.md`, `IOS-08-03_RETRY_BACKOFF.md` | backend replay/idempotency/token-rotation contract required |
| persistence migration | `09_PERSISTENCE_DATA/IOS-09-05_MIGRATIONS.md` | representative old-data fixtures and rollback/failure semantics required |
| security/auth | `12_SECURITY_PRIVACY/IOS-12-03_AUTHENTICATION.md`, `IOS-12-12_SECURITY_REVIEW.md` | threat model, current policy and project evidence required |
| memory/performance | `11_PERFORMANCE_MEMORY/IOS-11-05_MEMORY_LEAK.md`, `IOS-11-11_PERF_BUDGET.md` | Instruments/measurement required for runtime claims |
| accessibility | `13_ACCESSIBILITY_LOCALIZATION/IOS-13-01_VOICEOVER.md` | reference-only until consumer/device traversal is available |

This route is automatic at the route-selection level but deliberately not automatic at the
runtime-command level. A route can say “check required evidence” without executing the check.

## Candidate skill inventory

Status meanings:

- **reuse existing** — do not activate the candidate duplicate; use the named canonical route.
- **adapt necessary delta** — candidate trigger covers a useful gap, but its instruction contract
  must be reconciled before activation.
- **excluded from automatic activation** — authority/control-plane overlap is too risky for the
  pilot; keep as reference material only.
- **pending domain review** — no adoption decision without a separate semantic/source/consumer
  review; it is not included in the minimal route.

| Candidate skill | Canonical comparison | Proposed status |
|---|---|---|
| `ioslib-accessibility-localization` | `ios-accessibility`, `ios-qa-localization` | adapt necessary delta |
| `ioslib-active-skill-selection` | `ios-architecture-router`, canonical task routing | excluded from automatic activation |
| `ioslib-ai-ml` | no current matching canonical route | pending domain review |
| `ioslib-api-contract` | `ios-api-contracts` | reuse existing |
| `ioslib-app-intents` | `ios-platform-capabilities` | pending domain review |
| `ioslib-architecture` | `ios-architecture-router`, `ios-modular-architecture` | adapt necessary delta |
| `ioslib-architecture-mapping` | `ios-architecture-router` | reuse existing |
| `ioslib-background-execution` | `ios-lifecycle-background`, `ios-platform-capabilities` | reuse existing |
| `ioslib-build-ci` | `ios-build-system`, `ios-release-engineering` | adapt necessary delta |
| `ioslib-change-plan` | `ios-product-governance`, task plan rules | reuse existing |
| `ioslib-client-code-protection` | `ios-evidence-gate`, project protection rules | excluded from automatic activation |
| `ioslib-code-review` | `ios-production-auditor`, `ios-test-strategy` and domain routes | adapt necessary delta |
| `ioslib-command-discovery` | `ios-build-system`, `ios-test-strategy` | reuse existing |
| `ioslib-conflict-resolution` | canonical evidence/authority rules | excluded from automatic activation |
| `ioslib-context-drift` | `ios-architecture-router`, `ios-reusable-packages` | adapt necessary delta |
| `ioslib-crash-debugging` | `ios-incident-ops`, `ios-performance-profiler` | reuse existing |
| `ioslib-data-migration` | `ios-data-migration` | reuse existing |
| `ioslib-delegation-planner` | no direct canonical skill; native task orchestration owns this | excluded from automatic activation |
| `ioslib-dependencies` | `ios-build-system`, `ios-reusable-packages` | reuse existing |
| `ioslib-design-system` | `ios-content-cards`, `ios-accessibility` | pending domain review |
| `ioslib-diagnostic` | `ios-testing-debugging`, `ios-incident-ops` | reuse existing |
| `ioslib-evidence-synthesis` | `ios-evidence-gate` | reuse existing |
| `ioslib-feature-flags` | `ios-incident-ops`, `ios-platform-capabilities` | pending domain review |
| `ioslib-hotfix-release` | `ios-incident-ops`, `ios-release-engineering` | adapt necessary delta |
| `ioslib-implementation` | `ios-architecture-router`, `ios-test-strategy` | adapt necessary delta |
| `ioslib-integration-review` | `ios-modular-architecture`, `ios-reusable-packages` | adapt necessary delta |
| `ioslib-legacy-modernization` | `ios-data-migration`, `ios-architecture-router` | reuse existing |
| `ioslib-media-graphics` | `ios-memory-cache-media`, `ios-platform-capabilities` | reuse existing |
| `ioslib-memory-leaks` | `ios-memory-cache-media`, `ios-performance-profiler` | reuse existing |
| `ioslib-modularity-spm` | `ios-modular-architecture`, `ios-reusable-packages` | reuse existing |
| `ioslib-multi-agent-orchestrator` | native task orchestration and evidence rules | excluded from automatic activation |
| `ioslib-navigation` | `ios-platform-capabilities`, architecture routing | reuse existing |
| `ioslib-nested-agents-design` | canonical directory/documentation rules | excluded from automatic activation |
| `ioslib-networking-auth` | `ios-api-contracts`, `ios-network-resilience`, `ios-identity-authentication` | adapt necessary delta |
| `ioslib-observability` | `ios-incident-ops`, `ios-production-auditor` | adapt necessary delta |
| `ioslib-offline-sync` | `ios-offline-sync`, `ios-network-resilience` | reuse existing |
| `ioslib-orchestration-budget` | native delegation/task budget rules | excluded from automatic activation |
| `ioslib-parallel-investigation` | native read-only research/task routing | excluded from automatic activation |
| `ioslib-parallel-review` | native review/evidence routing | excluded from automatic activation |
| `ioslib-performance` | `ios-performance-profiler` | reuse existing |
| `ioslib-persistence` | `ios-data-migration`, `ios-reusable-packages` | adapt necessary delta |
| `ioslib-pr-review` | `ios-production-auditor`, `ios-evidence-gate` | adapt necessary delta |
| `ioslib-project-adaptation` | `ios-architecture-router`, `ios-configuration-environments` | reuse existing |
| `ioslib-release` | `ios-release-engineering`, `ios-app-store-compliance` | reuse existing |
| `ioslib-repo-intake` | `ios-architecture-router`, `ios-product-governance` | reuse existing |
| `ioslib-risk-mapping` | `ios-production-auditor`, `ios-evidence-gate` | adapt necessary delta |
| `ioslib-safe-command-execution` | canonical approval/sandbox rules | excluded from automatic activation |
| `ioslib-sdk-api` | `ios-swift-runtime`, `ios-reusable-packages` | adapt necessary delta |
| `ioslib-security-privacy` | `ios-security-privacy` | reuse existing |
| `ioslib-storekit` | `ios-platform-capabilities`, `ios-app-store-compliance` | pending domain review |
| `ioslib-swift-concurrency` | `ios-concurrency-runtime`, `ios-swift-runtime` | reuse existing |
| `ioslib-swiftui` | `ios-architecture-router`, `ios-accessibility` | adapt necessary delta |
| `ioslib-system-integrations` | `ios-platform-capabilities`, `ios-lifecycle-background` | pending domain review |
| `ioslib-target-discovery` | `ios-build-system`, `ios-qa-localization` | reuse existing |
| `ioslib-task-router` | canonical task/documentation router | excluded from automatic activation |
| `ioslib-test-flake` | `ios-testing-debugging`, `ios-test-strategy` | reuse existing |
| `ioslib-testing` | `ios-test-strategy`, `ios-testing-debugging` | reuse existing |
| `ioslib-uikit` | `ios-platform-capabilities`, `ios-architecture-router` | adapt necessary delta |
| `ioslib-verification-fanout` | `ios-evidence-gate`, native task orchestration | excluded from automatic activation |
| `ioslib-write-scope-partition` | canonical protection and worktree rules | excluded from automatic activation |

The inventory is intentionally conservative: a candidate skill is not promoted merely because
its name sounds useful. “Reuse existing” means the candidate copy should not be installed; it
does not mean every candidate sentence has been accepted into the canonical route.

## Disable and recovery

- Knowledge-only: remove the task-local pinned route entry or stop referencing the extracted root;
  no project, Git or global file needs to be changed.
- Explicit runtime: stop invoking the CLI, preserve external state, and report incomplete/active
  sessions rather than deleting them. Recovery uses the exact state-root procedure in the runtime
  receipt.
- Installed reference/full, if separately authorized later: use the matching dry-run and the
  manifest-aware `sync_global.py`/`uninstall_global.py`; preserve unknown or modified files and
  never delete state as a shortcut.
- Pin changes require a new candidate hash, route review and pilot; no auto-update is allowed.

## Proposed changeset verdict

The route is suitable as a reviewable task-local proposal. It is not yet a canonical promotion:
L2 blind utility, provenance/license, independent final review and real consumer adoption remain
open. No candidate skill receives permission authority from this proposal.
