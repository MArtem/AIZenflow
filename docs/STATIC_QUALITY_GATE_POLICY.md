# Static Quality Gate Policy

## Purpose
Define how static scripts should be interpreted so they improve engineering quality without creating noisy or misleading CI failures.

This policy owns human interpretation of static findings. Executable rule IDs, schemas, fixtures,
and scanner implementations belong to the versioned quality-control engine when it exists. Project
profiles own only project facts and selected configuration.

## Severity Levels
- **Fail**: likely production defect, secret leak, generated artifact committed, app-breaking config, or known forbidden hot-path pattern.
- **Warn**: suspicious pattern requiring human classification.
- **Review Candidate**: context-dependent signal that must be checked during review but should not block alone.
- **Allowed Exception**: explicitly documented tradeoff with owner, reason, scope, and expiry/revisit condition.

## Rules For Scripts
- Scripts must prefer deterministic checks over subjective style opinions.
- A script that produces broad pattern matches must state whether output is fail, warning, or review candidate.
- Generated files, build outputs, dependency caches, traces, and task attachments should be excluded unless the script explicitly audits artifacts.
- False positives should be reduced by scope, naming, allowlist comments, or severity downgrade; they must not be silently ignored.
- New forbidden-pattern rules should include target state and remediation guidance.
- Every blocking rule must have a stable identifier, bounded scope, positive and negative fixtures,
  and a documented failure/remediation contract before universal adoption.
- Heuristic regex matches default to Warn or Review Candidate unless fixtures demonstrate a
  deterministic unsafe subset.
- App names, scheme names, test-folder names, bundle identifiers, user paths, and product token
  allowlists must not be embedded in reusable scanner defaults.
- A missing dependency, malformed profile, invalid scope, stale result, or skipped command must not
  be converted into a successful finding set.
- Static gates must emit enough structured evidence to identify the source SHA, rule version,
  executed scope, and classified findings without logging source secrets.

## Review Rules
- Passing scripts is not enough to claim production-ready.
- Failing scripts must be either fixed, classified, or recorded as remaining risk.
- Allowed exceptions are temporary; permanent exceptions should become documented architecture rules.
- Static execution remains user-controlled under
  `./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`; absence of a run is not a failure or PASS.
