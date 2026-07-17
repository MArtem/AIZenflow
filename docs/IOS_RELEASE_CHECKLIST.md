# iOS Release Checklist

## Purpose
Production release gate for TestFlight/App Store delivery.

Before each release, load `./docs/knowledge/global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md` and re-check current Apple requirements; App Review, privacy, required-reason API, SDK, and regional rules are living inputs.

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
- P0/P1 findings closed.
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
- Feature flags/remote config defaults safe.
- Rollback/kill-switch policy known where relevant.
- Support/debug instructions prepared.
