# Policy Router

Codex should not load every policy for every task. Classify the change, then read the mandatory core plus every triggered specialist policy.

## Always read for code changes

- `policies/00-engineering-principles.md`
- `policies/01-task-repository-analysis.md`
- `policies/02-architecture-boundaries.md`
- `policies/03-swift-language.md`
- `policies/14-testing.md`
- `policies/22-diff-review.md`
- `policies/23-git-commit-pr.md`
- `policies/26-ai-agent-rules.md`

## Trigger mapping

| Trigger | Read these additional policies |
|---|---|
| `CONCURRENCY` | `04-swift-concurrency.md`, `11-memory-lifetime.md`, `13-error-resilience.md` |
| `SWIFTUI` | `05-swiftui.md`, `07-state-navigation.md`, `15-accessibility.md`, `16-localization.md` |
| `UIKIT` | `06-uikit.md`, `07-state-navigation.md`, `11-memory-lifetime.md`, `15-accessibility.md`, `16-localization.md` |
| `NAVIGATION` | `07-state-navigation.md` |
| `NETWORKING` | `08-networking.md`, `10-security-privacy.md`, `13-error-resilience.md`, `18-logging-observability.md` |
| `AUTH` | `08-networking.md`, `10-security-privacy.md`, `11-memory-lifetime.md`, `13-error-resilience.md` |
| `PERSISTENCE` | `09-persistence-migrations.md`, `10-security-privacy.md`, `13-error-resilience.md` |
| `MIGRATION` | `09-persistence-migrations.md`, `24-release-safety.md` |
| `SECURITY` | `10-security-privacy.md`, `17-dependencies-spm.md`, `18-logging-observability.md` |
| `PRIVACY` | `10-security-privacy.md`, `16-localization.md`, `21-build-config-signing.md` |
| `MEMORY` | `11-memory-lifetime.md`, `12-performance.md` |
| `PERFORMANCE` | `12-performance.md`, `18-logging-observability.md` |
| `ERROR_HANDLING` | `13-error-resilience.md` |
| `ACCESSIBILITY` | `15-accessibility.md` |
| `LOCALIZATION` | `16-localization.md` |
| `DEPENDENCY` | `17-dependencies-spm.md`, `10-security-privacy.md`, `21-build-config-signing.md` |
| `LOGGING` | `18-logging-observability.md`, `10-security-privacy.md` |
| `BACKGROUND` | `19-background-lifecycle.md`, `04-swift-concurrency.md`, `13-error-resilience.md` |
| `PUBLIC_API` | `20-api-modularity.md`, `03-swift-language.md` |
| `BUILD_CONFIG` | `21-build-config-signing.md`, `10-security-privacy.md` |
| `RELEASE` | `24-release-safety.md`, `21-build-config-signing.md`, `10-security-privacy.md` |
| `LEGACY` | `25-legacy-modernization.md` |

## Automatic escalation triggers

Any of the following makes a change at least R3 unless the gate catalog explicitly says otherwise:

- actor isolation, `Sendable`, task ownership, locking, custom executors;
- authentication/session/token handling;
- persistence schema or migration;
- cryptography, Keychain, Secure Enclave, ATS, trust evaluation;
- new/updated dependency;
- entitlements, signing, capabilities, Info.plist privacy keys, privacy manifest;
- public API or cross-module contract changes;
- background execution;
- code handling money, credentials, identity, destructive actions, or irreversible remote operations;
- broad project/workspace/build-setting changes.

A change becomes R4/R5 when potential failure can cause data loss, account/security compromise, widespread production outage, broken upgrade path, or difficult rollback.
