# iOS Release Checklist

## Purpose
Production release gate for TestFlight/App Store delivery.

Before each release, load `./docs/knowledge/global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md` and re-check current Apple requirements; App Review, privacy, required-reason API, SDK, and regional rules are living inputs.

Release verification and delivery are user-triggered. No workflow, archive upload, TestFlight
delivery, staged rollout, or App Store submission starts automatically. A release-ready claim binds
all evidence to the exact candidate SHA/profile/toolchain and requires every applicable item below
to be `PASS` or valid `NOT_APPLICABLE`; `BLOCKED`, `SKIPPED`, missing, stale, unavailable, user-denied,
or bypassed evidence is not normal release PASS.

## Checklist
### Build And Signing
- Correct bundle IDs.
- Correct entitlements and App Groups.
- Signing/provisioning profiles valid.
- Version and build number updated.
- Archive succeeds on clean machine/CI.

### App Store / TestFlight
- Privacy labels reviewed.
- Privacy manifest reviewed.
- Usage descriptions reviewed.
- Export compliance reviewed if relevant.
- TestFlight notes and review notes prepared.
- Required-reason API declarations and third-party SDK privacy manifests/signatures reconciled with the distributed artifact.
- Account deletion, privacy policy, permission prompts, privacy labels, and actual data lifecycle agree where applicable.

### Runtime Readiness
- P0–P2 findings closed; P3 findings fixed or explicitly recorded.
- Internal Exhaustive review and exact-SHA receipt complete for the release PR range.
- Critical flows smoke-tested.
- Persistence/migration checked.
- Offline/error/session-expired states checked where relevant.
- Performance-sensitive screens exercised.

### Diagnostics
- Crash reporting configured.
- dSYM upload verified.
- Analytics/performance events verified.
- Production logging redaction verified.

### Rollout
- Feature-flag/remote-config applicability explicitly recorded; defaults are safe where applicable.
- Staged rollout, pause criteria, monitoring owner, and rollback/kill-switch authority are known
  where applicable.
- Previous recoverable build/configuration and the limits of rollback are documented.
- Support/debug instructions prepared.

## Manual Quality Modes

Use the user-triggered `full` mode for a release candidate unless the project profile defines a
smaller release-specific mode with equivalent applicable evidence. The pipeline follows
`./docs/CI_CD_QUALITY_GATES.md`: exact checkout, governed Xcode, dependency/profile validation,
format/lint/static checks, build, permitted tests, optional snapshot/UI checks, and archive/signing
only where applicable. The user may choose not to run it; the result is then
`NOT_RUN_BY_USER_DECISION` with release readiness not proven, never an implicit PASS.

## Release Receipt

Record candidate SHA, profile/engine/toolchain identity, permissions, manual workflow result,
archive/signing/artifact identity where applicable, compliance review date, internal pre-PR receipt,
runtime/manual evidence, flag/rollout applicability, unresolved risk, owner decision, and final
verdict: `READY`, `READY_WITH_ACCEPTED_RISK`, `NEEDS_OWNER_DECISION`, `NOT_READY`, `BLOCKED`, or
`BYPASSED`.
