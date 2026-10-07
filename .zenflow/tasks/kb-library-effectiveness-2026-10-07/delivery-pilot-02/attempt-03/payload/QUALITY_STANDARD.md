# Reference quality contract for iOS work

This is advisory knowledge for an explicitly opted-in project, not a permission source. Read and
apply current user instructions, project rules, local knowledge, and task constraints first. An
`OFF` project still receives the complete task-appropriate local engineering workflow; `ON` adds
this reference review at every applicable stage, including the final complete candidate diff.

For every changed iOS artifact, establish the intended behavior, owner, affected producers and
consumers, state and time ordering, input and resource bounds, failure semantics, compatibility,
and relevant evidence before claiming readiness. Do not invent SDK behavior or project
requirements. Keep the smallest correct change and preserve existing contracts unless the user
authorized a change.

Route checks by the actual change surface, not by a generic checklist:

- Swift and concurrency: type safety, availability, isolation, ownership, cancellation,
  reentrancy, task lifetime, ARC and relevant negative paths.
- UI and design resources: state ownership, lifecycle, design-source fidelity when supplied,
  supported sizes, accessibility, localization, RTL, and asset provenance.
- Data and integration: schema/migration compatibility, privacy, authentication boundaries,
  error mapping, retry/idempotency, offline behavior, and deterministic tests where permitted.
- Project structure: target and extension membership, module/package boundaries, dependency
  direction, resource-bundle lookup, capabilities, deployment range, and affected build graph.
- Release-facing changes: signing, entitlements, privacy manifests, third-party supply chain,
  observability, and rollback/compatibility where relevant.

At planning, inspect the relevant local facts and reference risks. At design, challenge proposed
ownership and contracts. During implementation, review each meaningful changed boundary. During
verification, compare claims with observed evidence and report missing checks. Before presenting
code or resources for user review, review the **whole changed artifact set** and resolve blocking
findings. A later edit invalidates that final review. Advice and read-only review produce
evidence-backed recommendations instead of a fictitious code diff.

For relevant shared changes, identify the existing module/feature reviewer and escalation owner;
do not invent a team process or bottleneck. Prioritize debt by concrete risk, change frequency
and expected outcome, with a bounded payoff rather than an automatic rewrite. Deprecation or
breaking changes need consumer inventory, migration/version/removal criteria and communication.
Keep necessary engineering docs tied to actual contracts, source of truth, owner and code/release
update triggers; record useful examples and failure modes, not stale tutorials or duplicated rules.
Explain review trade-offs without rewriting to reviewer preference. Recommend process automation
only when it improves gate signal or recurring cost and is separately authorized.

For each applicable gate, record the inspected artifact/scenario and evidence; distinguish
`CHECKED`, `NOT_APPLICABLE` with a reason, `FINDING`, `UNVERIFIED` and `BLOCKED`. An empty
checkbox, unavailable test or accepted uncertainty is not PASS. Risk acceptance does not supply
missing evidence or override a local prohibition; unresolved P0–P2 require correction or an
explicit higher-authority exception. Archived gate wording never permits concurrency escape
hatches, test edits, signing, release actions or host changes forbidden by current rules.

Use only the relevant fields of a task brief, invariant sheet, decision record, bug investigation,
review report, migration plan, performance experiment or release-risk brief. Preserve observable
outcome/non-goals, environment and consumers, falsifiable hypotheses, negative paths, comparable
measurements, rollout/cleanup ownership and verification gaps where applicable. Reuse existing
project records instead of creating parallel templates. Separate static reasoning from execution
and production observation; numeric evidence/risk labels from archived templates do not replace
the current evidence policy or project severity contract.

Archived code patterns are conceptual review material, not verified drop-in implementations.
Re-establish the actual types, isolation, availability, error and lifecycle contracts before
adapting one. A request ID alone does not prove cancellation safety; single-flight work alone
does not prove logout ordering or prevent stale credential publication; a termination callback
alone does not prove thread-safe subscription cleanup. Compare each proposed implementation
with the specialist route rather than copying its illustrative syntax. Archived prompt modes,
playbook bindings and instructions to implement or run checks never expand the current task.

Tests, builds, device checks, Git operations, network actions, dependency changes, and PR creation
remain subject to user and project authorization. If a required check is unavailable, report
`INSUFFICIENT_EVIDENCE`; do not present the candidate as fully verified or PR-ready. See
[EVIDENCE_POLICY.md](EVIDENCE_POLICY.md) for claim levels.
