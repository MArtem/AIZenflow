# Universal Xcode Quality Control Governance

## Purpose

Define the reusable human policy for quality control across existing and future Xcode projects
without embedding project names, schemes, test assumptions, paid services, or unverifiable proof.

Load this document when designing or operating shared quality tooling, project quality profiles,
manual GitHub checks, PR risk recommendations, verifier evidence, exceptions, hooks, bootstrap, or
quality metrics.

## Authority And Lifecycle

- This is the canonical human-readable governance entry point in
  `MArtem/AIZenflowDocumentation`.
- Status: active human policy. The public `MArtem/AIZenflowQualityControl` repository now owns the
  bounded Stage 5 executable foundation, but it is not yet a verified verifier or stable release.
- Machine schemas, adapters, fixtures, workflows, and verifier self-tests belong in the versioned
  `MArtem/AIZenflowQualityControl` repository. Missing or not-yet-validated executable behavior
  remains governed by this human policy and cannot be represented as normal `PASS` evidence.
- Project facts and selected permissions belong in each project profile and local exception
  records, not in this reusable rule.
- Task audits and rollout evidence remain task recovery until explicitly promoted.
- Review this policy when test authority, CI cost, PR review, evidence semantics, exception
  authority, engine ownership, or rollout policy changes.

## Source-Of-Truth Separation

```text
Documentation Vault
  human policy, intent, authority, routing, and interpretation

Quality-control engine
  executable commands, schemas, adapters, fixtures, workflows, and machine evidence

Project repository
  project/workspace facts, schemes, source roots, permissions, exceptions, and thin launcher
```

Do not maintain a separately evolving verifier implementation in every project. A project-local
`verify.sh` may remain an app-specific helper, but it is not universal authority merely because of
its name.

## User Authority

The user retains independent control over:

- creating tests;
- modifying tests;
- running tests locally;
- running GitHub verification;
- UI tests;
- Simulator or physical-device work;
- performance and Instruments work;
- requesting normal or exhaustive Codex Review;
- approving HIGH/CRITICAL exceptions and emergency bypasses.

One permission never implies another. An unavailable or denied check must be reported as not run
with remaining risk; it must never be converted into PASS.

## Project Modes And Test Defaults

| Project mode | Test creation | Test modification | Local execution | GitHub execution |
| --- | --- | --- | --- | --- |
| `prototype` | `deny` | `deny` | `ask` | `off` |
| `controlled` | `ask` | `ask` | `ask` | `manual` |
| `production` | `ask` | `ask` | `ask` | `manual` |

New Xcode projects default to `controlled` until the user explicitly selects another mode. UI,
Simulator/device, and performance/Instruments permissions remain independently `ask` in every
mode unless the user changes them.

## Manual GitHub Verification

GitHub verification is advisory and manually triggered for every project. Supported planned modes
are:

- `static` — deterministic source/repository checks;
- `build` — static checks plus selected Xcode build;
- `build-and-tests` — build plus tests only when test execution is permitted;
- `full` — the approved maximum project-specific verification within all current permissions.

The absence of a run is not PASS or FAIL and must not silently block merge. A failing run may make
the engineering verdict `NOT_READY`, but GitHub branch protection remains deferred unless the user
explicitly reopens and approves it for a real release project.

GitHub Actions must add no monetary charge: use standard included runners where available, never
use larger paid runners by default, stop before paid overage, and do not call paid AI APIs. Initial
time budgets are 5 minutes for `static`, 15 for `build`, 30 for `build-and-tests`, and 60 for
`full`.

Apply `./docs/CI_CD_QUALITY_GATES.md` for workflow reproducibility, evidence, and safety details.

## Pre-Push Local Review Gate

Apply `./docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md` to every material quality-control engine,
policy/schema, workflow, bootstrap, adapter, evidence, or fail-closed verdict change. The change
contract must explicitly cover trust authority, producer/verifier agreement, aggregate resource
limits, process/filesystem boundaries, time ordering, and every route that could emit false `PASS`.

Tests and static checks remain permission-bound supporting evidence. High-risk control-plane work
uses an independent reviewer when available and receives an exhaustive review recommendation for
the final pushed SHA. Missing independent or runtime evidence remains residual risk, never `PASS`.

## Codex Review

Codex Review is always user-triggered and advisory. A high recommendation does not authorize the
assistant to request or purchase a review automatically. A material push changes the reviewed SHA
and requires a new recommendation; the user decides whether to request another review.

Normal review is the default recommendation for substantial but bounded risk. Exhaustive review is
reserved for broad, ambiguous, security/privacy, persistence/migration, concurrency, control-plane,
or otherwise high-risk changes where repeated search can materially reduce missed findings.

## Required Recommendation Output

Before a PR and after a material push, report separately:

```text
GitHub Manual Check: <0-100%>
Recommended mode: none | static | build | build-and-tests | full
Expected monetary cost: $0 | blocked
Test permission state: allow | deny | ask

Codex Review: <0-100%>
Recommended mode: none | normal | exhaustive

Manual/UI Check: required | recommended | not needed
Residual risk: low | medium | high | critical
Merge readiness: ready | needs verification | not ready | blocked
```

Scores are explainable recommendations, not permission or proof. Recalculate them when the diff,
permissions, evidence, or reviewed SHA materially changes.

## Evidence And Verdict Rules

- Evidence identifies the exact source SHA, engine/profile version, toolchain, selected permissions,
  commands actually executed, results, and remaining risk.
- Missing, stale, malformed, skipped, user-denied, or forgeable evidence cannot produce normal PASS.
- Static success does not prove runtime behavior, accessibility, performance, migration safety, or
  product correctness.
- Review output does not prove a build or test ran.
- Coverage is supporting evidence, not a substitute for assertions, behavior, or test quality.
- Completion claims follow `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` and
  `./docs/COMPLETION_REPORT_CONTRACT.md`.

## Exceptions And Bypass

Exceptions are exact-scope, owned, reasoned, visible, and expiring. The normal expiry is 30 days.
Only the user approves HIGH/CRITICAL exceptions or emergency bypasses in the solo workflow. A
bypass must remain distinguishable from PASS and record the unverified risk.

Use `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` and the local exception ADR template; never weaken
the reusable rule to hide a project-specific deviation.

## Bootstrap And Adoption

Adoption remains explicit opt-in until two structurally different pilots validate the system.
Existing-project migration must use inventory, dry-run conflict reporting, explicit apply,
post-check, and reversible rollback. Broad file copying or replacement is not an acceptable
migrator.

Proven behavior progresses through canary, first project pilot, second different pilot, and only
then explicit reusable promotion. No project-specific workaround becomes an engine default.

## Explicit Non-Goals

- No mandatory CI under the active policy.
- No branch protection until separately reopened and approved.
- No automatic test writing or execution.
- No automatic Codex Review or paid API call.
- No giant verifier that guesses projects, schemes, destinations, or test targets.
- No reduction of HIGH/CRITICAL human review merely because automated checks pass.
- No claim that the executable engine exists before its repository and verifier evidence exist.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
