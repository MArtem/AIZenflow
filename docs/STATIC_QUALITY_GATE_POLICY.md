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
- Every active project that has completed static-gate adoption maintains a project-specific local static gate that a developer or agent can run before review. It must reflect the current source graph, architecture, configuration, platform risks, and approved project facts; a copied generic template is not sufficient. Before adoption, report baseline checks only as their actual limited scope and record the adoption deferral under `NEW_PROJECT_START_CONTRACT.md`.
- The local gate evolves with the project. Reassess and update it when a feature, dependency, persistence/configuration boundary, build graph, or externally found escaped defect establishes a new deterministic high-signal risk. Do not add speculative or duplicate rules merely to make the gate larger.
- Each project-specific rule must be executable locally and identify its scope and remediation. In a project that has explicitly adopted GitHub static verification, its authoritative implementation or contract must also be shared with that workflow so the two gates cannot silently diverge.
- Scripts must prefer deterministic checks over subjective style opinions.
- A newly created or materially revised gate may publish a whole-target or whole-repository PASS
  only when it derives the checked source universe from an authoritative build, target, package, or
  repository membership contract. A convenient directory filter is not proof that all compiled or
  shipped sources were checked. Until that contract is implemented, report only the actual narrowed
  scope and never represent the result as a whole-target PASS. This policy does not treat an
  existing repository-root scan as authoritative membership merely because it exits successfully.
- Every check that compares repository changes or a review diff must name and validate the complete
  trusted base-to-head range. Do not silently default a review to the final commit or to an empty
  working-tree diff. Cross-tree parity and other non-history comparisons instead state their full
  input roots, authoritative source, and freshness contract.
- A newly created or materially revised credential gate may claim that a scope is credential-clean
  only when its classifier is kept in parity with the repository's declared credential inventory
  (for example, its ignore/security policy). A partial hard-coded list must state its actual
  patterns and must not imply inventory-wide cleanliness. This policy does not represent existing
  partial scanners as inventory-parity evidence until their executable classifier is updated.
- A script that produces broad pattern matches must state whether output is fail, warning, or review candidate.
- Generated files, build outputs, dependency caches, traces, and task attachments should be excluded unless the script explicitly audits artifacts.
- False positives should be reduced by scope, naming, allowlist comments, or severity downgrade; they must not be silently ignored.
- New forbidden-pattern rules should include target state and remediation guidance.
- Every blocking project static-gate rule must have a stable identifier, bounded scope, positive
  and negative fixtures, and a documented failure/remediation contract before universal adoption.
  Bootstrap and documentation-integrity validators instead fail only for a missing or inconsistent
  declared contract and identify the missing contract element directly.
- Heuristic regex matches default to Warn or Review Candidate unless fixtures demonstrate a
  deterministic unsafe subset.
- App names, scheme names, test-folder names, bundle identifiers, user paths, and product token
  allowlists must not be embedded in reusable scanner defaults.
- A missing dependency, malformed profile, invalid scope, stale result, or skipped command must not
  be converted into a successful finding set.
- Static gates must emit enough structured evidence to identify the source SHA, rule version,
  executed scope, input identity state, and classified findings without logging source secrets. A
  clean committed input may emit `PASS`; dirty or unborn input is `PROVISIONAL` and cannot support
  an exact-SHA claim; unavailable cleanliness is `FAIL`.
- SHA-bound scans exclude Git-ignored untracked content. A user who needs a secret/configuration
  check for such content must run a separate, explicitly scoped local check; it is not evidence
  for the committed source revision.

## Review Rules
- Passing scripts is not enough to claim production-ready.
- Failing scripts must be either fixed, classified, or recorded as remaining risk.
- Allowed exceptions are temporary; permanent exceptions should become documented architecture rules.
- Static execution remains user-controlled under
  `./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`; absence of a run is not a failure or PASS.
