# AG-14 — Release readiness gate

- [ ] Clean archive/build/tests pass in release-like configuration.
- [ ] Signing/entitlements/provisioning validated.
- [ ] Migrations tested with previous-version data.
- [ ] Privacy manifest/report and third-party SDK requirements reviewed.
- [ ] Crash/performance regressions assessed.
- [ ] Feature flags/kill switch/staged rollout defined for risky changes.
- [ ] Backend/API compatibility with old app versions confirmed.
- [ ] Rollback/containment owner and procedure defined.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
