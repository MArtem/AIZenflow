# Engineering Change Quality Standard

## Purpose

Produce correct, maintainable code before external review while spending only the evidence and
context needed for the actual risk. This standard owns the app-neutral implementation and
pre-push quality loop. Platform, product, security, persistence, UI, and quality-control documents
add specialized gates; they do not duplicate this loop.

## Trigger And Authority

Apply this standard to every non-trivial source, executable policy/schema, workflow, bootstrap,
migration, security/privacy, persistence, concurrency, or quality-control change. Mechanical edits
may use a smaller verification set when correctness is directly observable.

Quality is the first priority. Economy removes duplicate reading, repeated passing checks,
unrelated sweeps, and review theatre; it never removes a relevant invariant or required evidence.

## 1. Change Contract Before Implementation

Before editing, write a compact change contract in working notes or commentary. Include only rows
that can affect the requested change:

| Concern | Required answer |
| --- | --- |
| Behavior | What exact outcome changes, and what is explicitly unchanged? |
| Authority | Which inputs are trusted, untrusted, caller-owned, or user-controlled? |
| Producer/consumer | Which schemas, callers, verifiers, docs, and error contracts must agree? |
| State and time | What may happen before, during, after, concurrently, on cancellation, or on retry? |
| Input envelope | Empty, malformed, unknown, duplicate, maximum-size, aggregate-size, and unavailable inputs that are credible here. |
| Resource envelope | Time, memory, disk, descriptors, processes, output, recursion, and collection bounds that apply. |
| Failure semantics | How failure is surfaced, what is rolled back or cleaned up, and what must never become success or partial proof. |
| Affected surface | Direct implementation, call sites, mirrored claims/docs, tests, schemas, and configuration that may become stale. |

Resolve product behavior, ownership, persistence, privacy, and public-contract ambiguity before
implementation. Do not invent speculative cases unrelated to the changed boundary.

## 1A. PR Risk Card And Scope

Use the compact risk card in `IOS_PR_REVIEW_TEMPLATE.md` for every non-trivial PR. It is the
review-facing projection of the change contract, not a second competing checklist. Choose one
primary high-risk class: UI/accessibility, state/concurrency, persistence/import/export, external
input, dependency, build graph/workflow, security/privacy, or control-plane. A PR may include more
than one only when they are inseparable; name the dependency and cover both evidence paths.

Select the smallest sufficient evidence from this matrix:

| Primary risk | Minimum evidence in addition to final-diff review |
| --- | --- |
| UI/accessibility | Relevant static inspection plus the user-owned interaction/accessibility scenario. |
| State/concurrency | Ordering/cancellation/retry reasoning; targeted test or runtime/sanitizer evidence only when permitted and relevant. |
| Persistence/import/export | Data-preservation and failure-path scenario; migration or legacy-read evidence when compatibility changes. |
| External input | Strict form, malformed, boundary, and ownership validation at the entry boundary. |
| Dependency | Dependency diff/security review and explicit version, license, maintenance, and ownership decision. |
| Build graph/workflow | Authoritative target/scheme/workflow inspection and the relevant build or static evidence. |
| Security/privacy | Threat/authority review, secret/privacy-data boundary inspection, and the permitted negative or static evidence. |
| Control-plane | Authority/provenance, producer-consumer/schema parity, failure-closed, and aggregate-resource review; use an independent reviewer when available. |

This matrix does not grant permission to create or run tests, builds, CI, simulators, or external
services. Report missing user-owned evidence as residual risk.

## 2. Implementation From Invariants

- Enforce each relevant invariant at the narrowest authoritative boundary.
- Make invalid or untrusted states fail closed; comments and caller discipline are not enforcement.
- Keep one self-contained patch and avoid unrelated cleanup.
- Search direct callers and consumers before changing a contract.
- When test creation/modification is allowed, derive positive, negative, boundary, and regression
  tests from the change contract. Tests should prove behavior, not reproduce implementation detail.
- When tests are not allowed, state the missing evidence and use the strongest permitted static
  check; never create a disguised test artifact.

## 3. Verification Ladder

Use the smallest sufficient ladder and stop when its evidence is current:

1. Targeted source/call-site inspection and deterministic static checks.
2. One targeted test or type/build check during development when permitted and relevant.
3. Review the complete final diff against every relevant change-contract row before committing.
4. Commit only when no P0–P2 finding remains; record or close each P3.
5. Review the exact committed `HEAD` against its trusted base, confirm a clean worktree, and run the
   final relevant checks at that SHA. A later commit invalidates this receipt.
6. If push authority is explicitly granted or in current standing scope, verify that `HEAD` did not
   change, push, and confirm the remote branch points to the reviewed SHA. Otherwise retain the
   local exact-SHA receipt and report that remote review remains pending the user's push decision.
   Recommend user-triggered external review only for the final remote SHA.
7. User-owned build, UI, device, performance, GitHub, or external review when required.

Do not rerun an unchanged PASS. A changed source, input, configuration, toolchain, new risk, or
finding is required before repeating or widening a check.

## 4. Final Adversarial Review

Review the final diff from a clean perspective, not only the previously edited lines:

- trace success and every failure route end to end;
- test the credible boundary values and ordering/race scenarios from the change contract;
- verify aggregate limits, not only per-item limits;
- verify producer/consumer and error-code consistency;
- search affected call sites and status/README claims for stale or contradictory statements;
- confirm cleanup, rollback, cancellation, timeout, and partial-output behavior;
- inspect every route that could emit false success, trusted evidence, or irreversible state.

For executable policy, schema, verifier, workflow, bootstrap, or other control-plane work, also
inspect the exact diff for:

- authority and provenance: no untrusted input may authorize itself, supply a trusted expected
  outcome, or inject an identity/hash;
- schema/runtime parity and explicit version handling, including unknown-version failure;
- aggregate encoded and decoded resource bounds, including escaped Unicode or other expansion;
- public APIs that bypass verification or permit false success;
- filesystem containment, symlinks, TOCTOU, and cleanup; and
- all producers, consumers, call sites, fixtures, and human claims that depend on the contract.

For newly introduced or materially revised whole-target static gates and workflows, additionally
confirm that the reported source universe is derived from authoritative target/package/repository
membership and that every review comparison uses the complete trusted base-to-HEAD range. A partial
path list, last-commit-only range, or empty working-tree comparison is insufficient evidence for a
whole-target PASS. Keep credential classifiers aligned with the repository's declared credential
inventory before asserting inventory-wide cleanliness; otherwise report the actual limited scope.

Record findings. P0–P2 block commit and push. P3 must be fixed or explicitly reported. After a
fix, repeat the complete final-diff review once; do not start an unbounded review loop.

Use an independent reviewer when available for high-risk or control-plane work. If unavailable,
report that limitation and recommend the appropriate user-triggered review for the final SHA.

## 5. Exact-SHA Review Receipt

Before push, retain a compact receipt in the completion report or task evidence. It must name the
trusted base SHA, reviewed HEAD SHA and range, clean-worktree result, contract rows reviewed,
findings and disposition, commands and results, reused or intentionally omitted evidence, and
residual risk. The receipt is invalid if HEAD, relevant inputs, configuration, or toolchain changes.

External review is an independent second barrier, never a substitute for this local receipt.

## 6. Escaped-Finding Feedback

For every external-review finding that escaped the local gate, classify the cause as one of:

- missing or incorrect invariant;
- authority, provenance, or ownership-model error;
- producer/consumer/schema disagreement;
- incomplete affected-surface or public-API exposure review;
- inadequate adversarial or boundary evidence;
- stale documentation or claim; or
- implementation defect despite a correct contract.

Fix the code first. Update this or a specialized standard only when the cause is reusable across
changes; do not add a permanent rule for a one-off typo. For each escaped P0–P2 retain the finding
ID/severity, reviewed SHA, primary and secondary cause, missing gate, fix SHA, regression evidence,
and whether the correction is reusable or one-off. Track quality by new external findings on the
final SHA, with zero new P0–P2 as the target rather than a guaranteed claim.

Keep this feedback as a compact entry in the PR receipt, task evidence, or project risk record;
do not create a second global log per project. Promote a reusable rule only after the same failure
class occurs in two independent real PRs. Revisit a promoted deterministic rule after ten relevant
PRs if it has prevented no recurrence: retain it only when the risk is still material, otherwise
demote it to a review candidate or remove it.

## 7. Bounded External-Review Loop

External review is requested only after the exact-SHA self-review and relevant evidence are
complete. If it finds P0–P2 issues, make one consolidated corrective patch for the approved scope,
repeat the full self-review and exact-SHA receipt, then recommend one fresh external review of the
new SHA.

If a further round reveals an unrelated risk class or starts expanding tools, policies, or
infrastructure rather than correcting the approved product change, stop and report: completed
work, remaining concrete risk, cost of continuation, and the bounded choices of merge/stop, one
required fix, or backlog. Merge/stop or backlog is available only when no P0–P2 finding remains.
With an unresolved P0–P2, the only choices are the required fix or an explicit higher-authority
user exception. Do not convert a product PR into an unbounded quality-tool project.

## Completion Contract

Report the change contract applied, relevant checks run, checks intentionally not run, external
review still required, exact-SHA receipt, and residual risk. Completion means no known unresolved
blocking finding after the checked gates—not that unperformed runtime or independent review has
implicitly passed.
