# Release/CI semantic comparison — 2026-10-14

LIB-0204–LIB-0213: ten complete source bodies read; all thirty unit dispositions inspected. Ten active mappings and twenty archive dispositions adjudicated. Source-body reading preceded this checkpoint; the initially truncated unit-map output was replaced by two complete bounded map reads. This is documentation review, not CI/configuration/signing/release execution.

| Source U01 | Current semantic support and limits |
|---|---|
| 0204 CI pipeline | Xcode `Reproducibility And CI` and CI/CD `Required Execution Order`, `Reproducibility Rules`, `Result Semantics`: exact SHA/profile, conditional matrix/gates, bounded artifacts/cache compatibility, secret isolation. No automatic workflow authority. |
| 0205 parallelism | Testing `Determinism`, `Flaky Tests`: runtime allocation, isolated state, every selected shard and terminal result, retained retry history. Missing shard or retry success cannot erase failure. |
| 0206 signing | App Store `Release Candidate Trace` plus CI least privilege: declared strategy, certificate/profile owner, expiry/renewal. Metadata review does not grant key access, rotation or signing. |
| 0207 versioning | App Store `Release Candidate Trace`: actual product/build policy, source/artifact/release branch and migration compatibility; library SemVer is not automatically a product rule. |
| 0208 TestFlight | Same section explicitly retains groups/staged validation, feedback/crash metrics and scoped containment. No shipment follows from validation advice. |
| 0209 App Store | `Submission Contract`, `Encryption And Export`, `Release Evidence` and flags policy retain metadata/privacy/export, phased rollout, monitoring/support/rollback. Current external release requirements remain UNVERIFIED. |
| 0210 release notes | `Release Candidate Trace` distinguishes user notes from internal risk/migration/experiment/support notes tied to actual delta. |
| 0211 hotfix | Operations `Runtime Operations` preserves shipped symptom, minimal authorized correction, complete candidate versus shipped-base differences, targeted regression, recovery and postmortem. Cherry-pick shape or urgency does not establish safety. |
| 0212 release checklist | App Store `Release Evidence`, release checklist and common quality owners retain tests/migration/privacy/permissions/analytics/crash/performance/a11y/localization/store scope. Existing A09 receipt-label inconsistency remains; mapping support does not resolve that finding. |
| 0213 CI review | Xcode/CI/testing owners retain flakiness, missing gates, secret exposure, cache correctness, environment identity and release monitoring. PASS requires all applicable selected evidence and honest omissions. |

The full common source method remains supported by Engineering/Toolchain/Testing/current overrides: actual context, invariants, material alternatives, minimal diff, failure review and permission-bound evidence. U02 in each body archives the fixed minimum-two alternatives quota; U03 archives the old V2/mode/template/Library/deep-playbook delivery binding. Those archival dispositions were reviewed as retirements, never counted as active coverage. Linked OP bodies remain independently unread.

No additional loss of useful conditions established in these ten source templates. Existing A04/A09 and external freshness limits remain. Migration chronology (MIGRATED versus pre-existing coverage) is not newly proven by present-text comparison; historical block-39 self-assessment is not independent evidence.

Negative control specification, not executed: a selected two-shard run with one absent terminal result and a later green retry must retain missing/failing evidence and cannot become overall PASS. A release receipt for a different candidate/configuration must remain stale even if its metadata looks complete. No test files, workflows or fixtures created.
