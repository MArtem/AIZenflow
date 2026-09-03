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
- requesting external normal or exhaustive Codex Review;
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

GitHub verification is advisory and manually triggered by the user for every project. The reusable
workflow trigger is `workflow_dispatch`. Do not add `pull_request`, `push`, `schedule`, merge-queue,
or another automatic trigger unless the user approves a project-local exception. Supported modes
are:

- `static` — deterministic source/repository checks;
- `build` — static checks plus selected Xcode build;
- `build-and-tests` — build plus tests only when test execution is permitted;
- `full` — the approved maximum project-specific verification within all current permissions.

The absence of a run is not PASS or FAIL and must not silently block merge. Once the user requests
a mode, however, every applicable check in that mode must run to a terminal result or report
`BLOCKED`; missing, skipped, unavailable, or stale evidence cannot be summarized as success. A
failing run may make the engineering verdict `NOT_READY`, but GitHub branch protection remains
deferred unless the user explicitly reopens and approves it for a real release project.

GitHub Actions must add no monetary charge: use standard included runners where available, never
use larger paid runners by default, stop before paid overage, and do not call paid AI APIs. Initial
time budgets are 5 minutes for `static`, 15 for `build`, 30 for `build-and-tests`, and 60 for
`full`.

Apply `./docs/CI_CD_QUALITY_GATES.md` for workflow reproducibility, evidence, and safety details.

## Mandatory Internal Pre-PR Review Gate

Apply `./docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md` to every material quality-control engine,
policy/schema, workflow, bootstrap, adapter, evidence, or fail-closed verdict change. The change
contract must explicitly cover trust authority, producer/verifier agreement, aggregate resource
limits, process/filesystem boundaries, time ordering, and every route that could emit false `PASS`.

Tests and static checks remain permission-bound supporting evidence. High-risk control-plane work
uses an independent reviewer when available and receives an exhaustive review recommendation for
the final pushed SHA. Missing independent or runtime evidence remains residual risk, never `PASS`.

When the implementing agent reports that a change is ready for a PR, that report does not authorize
commit, push, or PR creation. After the user explicitly says to create the PR, the same agent must
perform an internal Exhaustive review of the complete candidate PR range against its trusted target
before committing or pushing. This gate is mandatory for every new PR, independent of the risk-based
recommendation for external Codex Review. It grants no permission to run builds, tests, Simulator,
paid services, or other separately controlled evidence.

The local gate has two required points when PR/commit authority is in scope: review the full proposed
PR diff before commit, then review the exact committed SHA and complete PR range against its trusted
base before push. Resolve all P0–P2 findings, record or resolve P3, and repeat one complete review
after corrective changes. Without commit authority, retain the proposed-diff review and report the
exact-SHA receipt as pending. The second review records the compact receipt required by
`ENGINEERING_CHANGE_QUALITY_STANDARD.md`; any
later commit or recorded-input change invalidates it. Revalidate its inputs immediately before an
authorized push and verify the remote branch resolves to that reviewed SHA after push. Static checks
and user-triggered external Codex Review are supporting, independent barriers and cannot replace the
internal Exhaustive review or exact-SHA semantic receipt.

## External Codex Review

External Codex Review is always user-triggered and advisory. The internal Exhaustive pre-PR gate
above is a separate agent responsibility and must not invoke the external service. A high external
recommendation does not authorize the assistant to request or purchase a review automatically. A
material push changes the reviewed SHA
and requires a new recommendation; the user decides whether to request another review.

Normal review is the default recommendation for substantial but bounded risk. Exhaustive review is
reserved for broad, ambiguous, security/privacy, persistence/migration, concurrency, control-plane,
or otherwise high-risk changes where repeated search can materially reduce missed findings.

Use a bounded two-phase sequence: complete the local proposed-diff and exact-SHA reviews first,
then request one user-controlled external review for the final SHA. A material P0–P2 correction
receives one consolidated patch, a new local receipt, and one new external-review recommendation.
If the next round introduces an unrelated risk class or quality-tool expansion, stop for the
user's choice of one required fix, backlog, or merge/stop; the latter two are available only when
no P0–P2 finding remains. With an unresolved P0–P2, require the fix or an explicit documented
higher-authority exception. Do not allow a product PR to become an open-ended verifier project.

## Required Recommendation Output

Before a PR and after a material push, report separately:

```text
Internal Exhaustive pre-PR review: pending | pass | findings
Reviewed target/range/HEAD: <target ref and SHA> | <range> | <HEAD or pending>

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

The human policy is global for every current and future iOS/Xcode Git repository. A repository
created through Codex must receive the governed bootstrap before its first project action. When
Codex first encounters an externally created repository without that bootstrap, project work is
blocked until bootstrap completes or the user records an explicit, owned deferral. Existing-project
migration must use inventory, dry-run conflict reporting, explicit apply, post-check, and reversible
rollback. Broad file copying or replacement is not an acceptable migrator.

Only the delivery/consumer layer belongs in an app repository: bootstrap activation, the governed
portable fallback, project profile and facts, thin workflow/launcher wiring, adoption state, and
explicit local exceptions. Reusable policy and engine behavior remain owned by their canonical
repositories. Executable rollout may remain staged until two structurally different pilots validate
it; staged rollout does not make the global human policy optional.

Proven behavior progresses through canary, first project pilot, second different pilot, and only
then explicit reusable promotion. No project-specific workaround becomes an engine default.

Every adopting project uses the reusable PR risk card and the risk-to-evidence matrix from
`ENGINEERING_CHANGE_QUALITY_STANDARD.md`. Existing projects receive them during their next
meaningful baseline synchronization; new projects receive them at bootstrap. The format is
project-neutral and may be represented in a repository pull-request template or an equivalent
documented review form.

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
