# Release readiness — copy-only reference route

Use for a requested release/CI/signing review or a change that may affect shipping. Read local
release policy and identify the exact app, targets, version/build candidate, environment and
deployment scope first. This route is a review guide, not permission to archive, sign, upload,
publish, change credentials, modify CI secrets or alter Codex.

1. Map the candidate to its source revision and affected targets. Distinguish observed CI,
   build, test, archive and distribution evidence from planned checks; a green check for one
   configuration does not validate another.
   Trace artifact identity, version/build policy, toolchain/dependency inputs and environment
   parity. Inspect missing/skipped gates, swallowed failures and cache assumptions, not just
   the final green status. For parallel tests, account for every shard/result, shared-state
   isolation and diagnostic retries; a retry must not erase an earlier failure from the report.
   Recommend redacted logs/artifacts that discriminate source, toolchain, signing, service and
   flaky-test hypotheses. Signing/profile ownership or renewal is a review question, never
   permission to inspect keys, rotate credentials or modify a machine.
2. Inspect migration and existing-data risk; privacy/permissions, manifests and third-party
   changes; accessibility/localization; crash/performance signals; release notes and user impact.
   Mark each as checked, not applicable with reason, or unverified. Use current official policy
   sources for any time-sensitive store or platform requirement before asserting compliance.
   Distinguish user-facing notes from internal risk/migration/experiment/support notes; both
   must describe the actual candidate rather than an assumed branch contents list.
3. Ask whether rollout can be staged or contained and what recovery means for this change.
   Separate a code rollback from irreversible data or server-side effects. Identify monitoring
   signals and an owner before recommending shipment.
   If a feature flag is part of containment, inspect its safe default when configuration is
   absent or malformed, targeting, kill-switch limits, enabled/disabled evidence, analytics/monitoring,
   and named cleanup owner/date. Do not treat a flag as rollback for an irreversible effect.
   For remote configuration, inspect typed keys, cached value and TTL, stale/offline behavior,
   experiment owner and cleanup. A successful fetch is not proof that all consumers observe the
   intended version or that a kill switch can undo already-persisted effects.
4. Report blocking findings, missing evidence and the smallest worthwhile next gate. Do not
   claim release-ready, TestFlight-ready or App-Store-compliant from static inspection alone.
   Any signing, upload or rollout decision remains an explicit separately authorized action.

For an incident hotfix review, tie the production symptom and its evidence to the smallest
authorized correction and a targeted regression question. Compare the complete release delta
with the affected shipped version, including dependencies, configuration and migrations.
Name available flag/kill-switch containment, its limits and the recovery/rollback path.
Urgency does not supply missing evidence or permission to change code, tests or shipping state.
For an approved CI/release-process migration, propose a non-publishing comparison and a cutover/
recovery criterion. Do not interpret the old dual-run advice as authority to ship twice, execute
two side-effecting workflows, cherry-pick commits or retain credentials outside approved policy.

`AUTO` can perform only the already-authorized document/config/diff review. `ADVISORY` gives
prioritized verification and rollout advice. This retains the useful former `ioslib-release`
criteria without its global installation or executable release workflow.
