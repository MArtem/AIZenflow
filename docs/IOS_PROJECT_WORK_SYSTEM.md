# iOS Project Work System

## Purpose, authority and use

This workflow coordinates exact project identity, permission-aware preparation and fresh
project memory for an iOS project integrator. Load it for project intake, memory refresh or
task preparation through the `ios-project-work-system` route, after canonical bootstrap
and Level 0. For each task in this workflow, apply the preparation/execution cycle in
Section 4A before its implementation; scale its detail to the actual risk and scope.
It adds no Level 0 requirement and does not activate a project or library.

Status: staged human workflow; identity and memory contracts are available for an explicitly
authorized pilot. End-to-end portability and general rollout require observed canaries.
Documentation Vault owns this contract. Review it when profile/mode identity, permission
authority, memory dependencies or pilot findings change.

Use existing authorities:

- [Source of truth](SOURCE_OF_TRUTH_MAP.md) and [boundaries](DOCUMENT_BOUNDARY_STANDARD.md)
  own placement. Source files own implemented behavior; approved app decisions own intent.
- [QC governance](UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md) owns decisions/readiness;
  QualityControl owns executable schemas, adapters and verification.
- [Change quality](ENGINEERING_CHANGE_QUALITY_STANDARD.md) owns invariants/final diff;
  [context transfer](CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md) owns resumed startup.
- [New project start](NEW_PROJECT_START_CONTRACT.md) and
  [adoption](STATIC_GATE_ADOPTION.md) own bootstrap and ADOPTED/DEFERRED obligations.

Current user/project rules and selected KB routes form the single mandatory chain.
Apply the existing engineering/evidence owners once; there is no separate Library pass,
provisional result for Library challenge, or mandatory Library status lookup. Transferred
knowledge is reached through the existing task routes, with their actual conditions.

Retain historical Library payloads, pins, canary results and mode observations as explicitly
inactive provenance/recovery material. A stored ON/AUTO, ON/ADVISORY, OFF or unknown record
does not select another read/review pass in this workflow. Documentation retirement neither
sets OFF nor changes a handler/profile/state record. Do not copy raw mode records into memory,
replay transitions, enable a project from a manifest or create another switch. Any future
handler lookup/transition or experimental comparison needs current exact human authority.
Claims about remaining consumers are limited to the roots actually traced; no host-wide
retirement or Library quality/token benefit follows from this documentation change.

No host installation/configuration, secrets, background work, backend, vector database,
custom MCP, automatic CI, app connection or extra command authority follows from this file.

## Quick user guide

1. Name the project/task, or explicitly delegate pilot selection. The integrator shows
   exact identity, relevant dirty state, current authority and selected KB routes.
2. Request scoped preparation or a full audit explicitly. The integrator uses current
   rules/KB first, analyzes affected consumers and creates one current task card.
3. Choose among material approaches after their benefits/downsides/recommendation.
   Select verification actions separately; an exact execution choice grants only that scope.
4. The integrator reviews the discrete plan, checks purpose before/after each block,
   performs permitted work and records one complete KB result with its evidence limits;
   historical supporting advice is not a new action or independent observation.
5. Review the complete diff and evidence limits. Unperformed required checks remain
   open; unrelated findings go to the app ledger, not automatic pilot development.
6. Resume from the current plan/handoff with fresh startup, identity and grants.
   Request detach for a reviewed owned-entrypoint diff; memory/history are preserved.

No special command, installer, service or background schedule is required. This is
an instruction workflow: historical canaries do not establish current app readiness;
each readiness claim still requires its existing evidence gates.

## 1. Select one exact scope

Before reading a client beyond the authorized intake, resolve and display:

| Field | Meaning / refusal rule |
|---|---|
| ProjectID | Opaque stable memory ID assigned within an approved or explicitly delegated association, unique among registered app manifests; not a remote URL, folder label, mode key or permission token. Missing/duplicate ID blocks memory association until resolved. |
| App boundary | Existing `apps/<AppName>/MANIFEST.md`; adapt it before adding a competing registry. Multiple independent apps keep separate IDs/boundaries. |
| Repository root | Exact physical authorized root, Git or explicit local-only. Symlink escape/out-of-sandbox paths block access. |
| Checkout | Worktree root and observed HEAD, relevant dirty ownership; a linked worktree is a checkout, not automatically another app. |
| Selector | Exact normalized repository-relative `.xcodeproj` or standalone `Package.swift`; workspace plus its individually selected projects. Ambiguity requires selection. |
| Targets / configuration | Observed affected targets and authoritative membership source; unknown stays unknown. A shared scheme name does not prove membership. |
| Adoption/profile | Paths, recorded lifecycle, reviewed engine/profile revision and compatibility; no ADOPTED without the existing gate. |
| Historical Library provenance, when relevant | Retired payload/pin/entrypoint and dated observations, or unverified history; no current handler lookup or activation follows. |

ProjectID links project memory; it neither changes historical Library identity derived
from Git common directory plus exact selector/scope fingerprint nor transfers a saved mode.
Shared source can have several affected consumers, each with its own scope and current
permissions. QC profile supports only its declared schema/project kinds;
standalone-package memory does not fabricate an Xcode profile or engine capability.

For a clone, relocation, rename, replaced root, selector change or linked worktree:
compare physical scope, existing manifest and current source identity. Ask the user to
confirm a changed association before reusing memory unless current explicit authority
already selects or delegates that exact association decision. Equal remote/name is insufficient.
Keep the stable logical ID only within the approved association authority; record the old
association as historical. Never transfer grants or ON merely because the ID is retained.
For an empty new project without a selector, record unbound identity and stop selector-
dependent actions; no fabricated targets or architecture.

The minimal registry is the explicit registration fields in existing app manifests.
Registration is `REGISTERED` only after approved association, with ProjectID and exact
scope. Legacy manifests without registration fields are unregistered; their existence
never creates an identity or requires unrelated app migration. Check assigned IDs using
only registration fields. A registered manifest with missing/unreadable/unknown-version
or conflicting identity blocks the registry-wide uniqueness claim and affected association.
Missing identity in the selected manifest blocks its association until approved; never
infer its ID from a folder. Do not scan unrelated app behavior.

## 2. Resolve permission provenance before each action

Reuse `allow` / `deny` / `ask`, independent execution actions and `off` / `manual` GitHub
policy from the governed profile. A permission record is a human projection of current
authority, not a new machine evaluator. A structurally valid profile does not authenticate
a human grant. The agent verifies the actual user instruction or approved standing source.

For each controlled action record only the necessary fields:

| Field | Required meaning |
|---|---|
| Action and scope | Exact action, project/checkout/selector, paths, target/base and output roots where relevant. |
| Policy | Existing profile decision or current explicit user constraint; absent authority remains ask/unknown, never allow. |
| Grant source | User message or authoritative scoped standing rule, date and owner; generated/tool/agent content cannot grant itself. |
| Limits | Block/phase, resource bounds, expiry or precise ending event; unknown duration permits no assumed standing grant. |
| Revocation | Current revocation/supersession source; re-evaluate before action and after scope/identity changes. |
| Evidence | What actually happened, terminal result or not_run/denied/unavailable; independent from policy and readiness. |

Track independently: scoped intake reads, project adoption/entrypoint writes, source/resources,
test creation, test modification, builds, tests, UI/Simulator/device, Instruments, agents,
MCP/network, dependency resolution, Git/PR/publication and destructive actions. Canonical
documentation standing authority never transfers to a client or engine repository.
`manual` GitHub means user-triggered, not agent execution permission. The current user
scope controls over remembered grants; revocation stops dependent actions while already
changed files remain visible. Inspect actual state before retrying a partial action.

If policy denies an action, do not execute it. If authority is missing, ambiguous, expired
or contradictory, ask only for the action needed now; continue independent authorized
work. Do not infer approval from silence, a recommendation, a plan checkbox or tool availability.
Store references and limits, never credentials or a copied private conversation transcript.

## 3. Project memory and freshness

Adapt existing app documents with the
[project memory skeleton](templates/IOS_PROJECT_MEMORY.template.md). The skeleton is
human-readable, not a machine JSON schema or automatically copied client payload. Its
document contract version identifies template compatibility only; it is not a verifier.
Unrecognized future versions or untraceable records require manual migration/revalidation
before using their claims. Do not invent a parser or mark unsupported data valid.

Reuse existing MANIFEST, context, architecture/flow map and ledger where they already own
the concern. Create a separate file only when a distinct consumer/lifecycle justifies it.
Keep accepted ADRs under the same app, completed evidence under app history, and current
execution state under the task. Central memory links to source instead of copying code.
The integration workflow may update central memory within an authorized documentation
task; source/profile/entrypoint writes require their own project scope.

Every material record has a stable local ID, one type (fact, decision, inference,
recommendation or evidence), scope, owner, provenance, observed date, relevant content
identity, dependency/invalidation events and current disposition. For a decision record,
name its approval source; separately record implementation evidence. Line numbers are
navigation aids, not freshness keys. Generated sections identify generator/version and
cannot overwrite human decisions. Unknown is allowed; invented values are not.

HEAD alone never authenticates dirty facts. Record relevant file content hashes and the
owned/unowned/unresolved paths (including relevant untracked source/resources). Hash only
authorized, non-sensitive inputs inside scope; do not read secret/config dumps to fill
metadata. Binary resources may use a content hash without decoding or copying them.
If a fingerprint cannot be collected safely, mark the dependent claim unverified and
do not reuse its evidence. An unavailable file, source anchor or schema is not PASS.

| Event | Invalidate and revalidate |
|---|---|
| Source content changes | Affected facts, traced flows, findings and checks, including shared consumers. |
| Targets/resources/generated ownership/dependency lock change | Membership map, compatibility and dependent task/evidence. A directory listing is not a shipped-source list. |
| Profile/toolchain/SDK/policy or relevant reference pin change | Relevant compatibility, route/delta and execution receipts. |
| Requirements/ADR/permission/identity change | Affected task scope, grants, acceptance and readiness; do not carry old authorization. |
| Interrupted/partial/cancelled run | Actual filesystem/diff/terminal results before retry or success claim. |
| Missing/conflicting/untraceable record | Preserve both sources, label stale/partial as appropriate and resolve from source/authority. No automatic reset/delete. |

Maintain dependency links in proportion to risk, not a whole-repository graph database.
Read the affected authoritative source once to refresh an invalidated fact. A timestamp
alone cannot establish freshness, and a new unrelated commit need not invalidate evidence
whose exact relevant inputs and required source-identity contract remain unchanged.
Exact-SHA engine receipts retain their own stricter identity rules.

Track structural inventory, semantic flow tracing and runtime evidence separately. Each
coverage row names its actual universe, route, sources/exclusions and checked,
not-applicable-with-reason, unverified or blocked state. These are coverage descriptors;
use QC governance for evidence status and decision. No sampled read becomes full coverage.

Retention: preserve approved human decisions and useful receipts; supersede stale facts
with links and reasons, archive completed task detail under its owning boundary. Raw
build products, caches and confidential dumps do not enter the vault. Restore only a
named record/version under explicit scope, preserve current human edits, and revalidate
identity/freshness before use. Restoring a file never restores a grant or library mode.

## 4. Next action and truthful status

Display selected identity, adoption, selected KB routes, current stage, blocking findings,
action permissions and unrun evidence. Historical mode remains dated/unobserved as appropriate;
it is not an execution or reading gate. Reject unscoped “all ready” summaries.

The next operational gate is a named-project read-only intake followed by proposed
adoption/deferral and separately authorized apply. Reuse the engine's inventory/dry-run/
apply/post-check/rollback lifecycle where suitable; it does not authorize invocation.
Rollback may remove only unchanged owned additions, never foreign files or central memory.
After selection load only the relevant source/rule routes. App implementation, full audit,
task execution and canary acceptance require their own scope and evidence; the existence
of this workflow and template proves none of them.

## 4A. Analyze, plan, decompose and review every task

Every task starts with an explicit preparation result, including a bug, feature,
refactor, audit, resource change or documentation task. Use the existing task packet
and plan, adapting the [compact task card](templates/IOS_PROJECT_MEMORY.template.md#compact-task-card--adapt-the-existing-packet)
as their current shared section. Memory/action tables link to that card; separate reports
are optional only for a distinct lifecycle/consumer. The [preflight](AGENT_PREFLIGHT_CHECKLIST.md) and
[change quality contract](ENGINEERING_CHANGE_QUALITY_STANDARD.md) remain authoritative.
A small task may express the entire cycle in a few lines. Greater ambiguity, impact
or consumer count requires deeper analysis and finer blocks, not fewer quality gates.
Record concise conclusions, decisions and evidence references, not private reasoning
transcripts or a second set of reports. Task preparation itself runs this cycle with
its own bounded objective; it does not recursively create a preparation task.

| Step | Required output / check |
|---|---|
| Analyze intent and context | Objective, current versus required behavior, acceptance/non-goals; exact identity, relevant source freshness, ownership, consumers, constraints, risks and missing decisions. Separate facts, assumptions and product questions. |
| Compare material approaches | When several approaches change behavior, ownership, compatibility, UX or meaningful cost/risk, give suitability, benefits, downsides and a recommendation. Obtain the user's choice unless current explicit authority already selects or delegates that decision. Routine implementation details do not require another approval. |
| Define contract and plan | Relevant invariants and failure semantics under the existing change standard; bounded outcome, affected paths/consumers, current authority and the sequence needed to reach acceptance. |
| Decompose | Small complete blocks ordered by dependencies. For each block identify its output, affected scope, completion criterion, relevant verification and required decisions/permissions. One small change can be one block; do not invent layers, services or parallel writers to lengthen the plan. |
| Review the plan before changes | Present the verification menu below after initial analysis and before implementation; resolve the user selection. Check requirement coverage, dependency/order correctness, source/consumer agreement, failure and rollback implications, verification sufficiency and permission/resource limits. Resolve material ambiguity or a blocking gap before dependent work; continue independent authorized work. A plan does not grant its proposed executions. |
| Execute and check each block | Targeted inspection, one bounded patch, permitted invariant-derived verification and review. Record actual results and mark completed steps only after their criteria are met. New facts, scope, permissions or a failed check trigger affected analysis and plan review before dependent continuation. |
| Review the whole result | Complete owned diff and affected consumers/claims under the engineering gate. Reuse unchanged valid evidence; distinguish static, compile, interaction and release claims. Unrun checks remain visible; confirmed candidate P0–P2 prevent completion without the governed correction/explicit exception. |
| Refresh and hand off | Update affected project memory, findings and task state; record exact evidence, residual risk and next safe action. Preserve human edits and decisions. Final completion and publication follow existing authority/gates, never a plan checkbox alone. |

Analyze the affected source/consumer graph and failure modes sufficiently for this task.
A whole-project audit is required only for an accepted whole-project question or a
concrete dependency that prevents scoped analysis. An existing broad ledger is context,
not authority to execute its backlog. Record coverage limits; do not skip an affected
consumer because the task is small or claim full audit from a sampled task analysis.

### Verification menu before implementation

After the initial analysis of every task and before implementing it, present a compact
verification plan for the user's choice. Reuse the task packet/action table; do not hide
testing decisions inside the implementation plan or add a separate verification service.
Apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality): omit
all iPad checks and physical-device checks, including actual VoiceOver, from every
project/task plan and continuation gate. Retain scoped evidence limits and applicable
source review/iPhone Simulator checks. Show the remaining actions independently,
including an explicit reason when not applicable:

| Proposed action | What the plan must specify |
|---|---|
| Write new tests | Invariants/regression scenarios, appropriate layer, exact affected test scope; value, effort and limits. This is separate from running those tests. |
| Modify existing tests | Why existing coverage needs a change, affected tests and regression risk; no automatic rewrites or removal to obtain PASS. |
| Build / compile | Exact target/configuration/destination, question answered, output/cache roots and bounds. Compilation alone does not verify feature interaction. |
| Run tests | Relevant existing/new suites and target/destination, prerequisites, deterministic scenarios and evidence; no full-suite expansion by default. |
| Verify feature on Simulator | Concrete user flows, positive/failure/boundary cases, UI/state/accessibility assertions appropriate to the feature; selected environment and manual/agent operator. |
| Static / other necessary checks | Complete diff/consumer/contract review and relevant static checks; additional runtime/performance/release actions only for a concrete uncertainty. |

For each action give purpose, applicability, qualitative effort/side effects, prerequisites,
benefits/limitations, recommendation and smallest adequate alternative. Keep the menu
brief for a small task; mark an irrelevant action not-applicable with a factual reason
rather than proposing ritual tests or device runs for a documentation edit. Identify
which evidence is needed for each intended completion claim and the residual risk if
omitted. Do not promise all checks or declare the feature tested from one passing layer.

Recommend a minimum adequate bundle by mapping each intended claim to its failure
modes and required evidence. Reuse valid unchanged receipts before proposing repeats.
Keep optional stronger evidence visible with its added value/cost; adding a test target
or running every suite is not a default quality ritual. Users select independent actions;
a recommended bundle creates no grant. If their selection leaves required evidence
missing, retain the limited verdict and named remaining gate.

The user chooses the actions to execute before implementation, unless an actual current
instruction already selects them within the exact task scope. A proposed/recommended
item is not selected, permitted, written or executed. Unresolved selection requires a
question before dependent implementation; continue independent authorized work. Record
the actual choice in the existing packet/plan, including delegated decisions and action
limits. An explicit user choice to perform a precisely scoped action is its grant;
do not request that same permission again. Verify the independent scope for test
writing/modification, builds, test runs, Simulator/device access and the operator;
clarify only missing bounds or authority. No default approval from
silence, tool availability, project source-write or pilot-selection permission.

A user-omitted check stays omitted/unverified in the final report. If this leaves a
required acceptance gate unmet, explain the limited readiness and necessary evidence;
do not turn the selection into a waiver or a false completion claim. New implementation
facts that change the relevant verification scope require a revised proposal/choice.
Existing engine/profile and evidence contracts still own execution and observed results.

Produce one complete KB result for each applicable step under Section 6, preserving
the actual evidence and unknowns. No separate Library result is required.
Plan review is the integrator's review unless a separately authorized independent
review actually occurs. No automatic agents, test creation, builds, Simulator, MCP,
Library transition or publication follows from this mandatory quality cycle.

Pilot tasks use the same cycle with a narrower purpose: answer a named system-acceptance
question. Before acting, name the smallest scenario and evidence, file/action bounds,
ending event and exit criterion in the existing packet. Select/associate a pilot only
under current exact or explicitly delegated authority. Stop expanding it when the
question is answered or requires a missing decision/action. App findings remain in its
ledger; unrelated features, architectural improvements and backlog execution require a
separate product task. A chosen pilot is not authority to finish developing that app.

## 4B. Check purpose before and after each block

Use the current card, including documentation and pilot work. Before a block name:
accepted objective/R-ID or system question; missing output/evidence and why existing
artifacts cannot suffice; smallest exact files/consumers/actions; current grant/resource
bounds and ending event; observable exit criterion. Reassess the model route.

After the block compare actual output/evidence with that criterion, reconcile failures
or changed facts, and name only the next necessary action. Stop expansion when the
question is answered, no material benefit remains, the same correction repeats without
new evidence, or scope/budget/authority changes. Preserve useful results and continue
independent permitted work. Unrelated ideas become separate backlog/decisions. Candidate
P0–P2 still require correction or an explicit governed exception; exhaustion, deferral
or absence of permission/evidence does not waive them. Do not count scans, skills,
document volume or checkbox percentage as product/system acceptance.

## 5. Plan capabilities for the prepared task

Use the accepted task packet, not the size of the installed skill/tool catalog. Select
one skill for the primary behavior owner and only necessary supplements through the
current router. A skill is advice under the existing authority, not a new permission.
Reassess the current model route before each meaningful block; tool availability does
not require a model switch or delegation.

Add a compact action table to the existing task packet only for useful actions:

| Action record | Required content |
|---|---|
| Question / evidence | Which invariant or uncertainty the action resolves, expected output and its consumer. |
| Exact scope | Project/selector, affected inputs/consumers, output/cache roots and ending event. |
| Authority / availability | Current grant or deny/ask, separate from whether a callable tool or user-run path exists. Unknown availability is not permission or evidence. |
| Cost / risk / alternative | Qualitative work and side effects, smallest adequate static/manual alternative; unavailable telemetry stays unknown. |
| Disposition | Proposed, permitted or withheld action; actual terminal evidence separately. Advice is never recorded as execution. |

Prefer a single integrator and bounded static/manual work when sufficient. Agents,
MCP/network, dependency operations and runtime checks need current separate authority
and a concrete benefit over that alternative. Do not probe a prohibited integration
to discover its availability. No hidden service, budget promise or automatic tool wave.
A granted action still requires material product/ownership decisions to be settled.

Before a controlled execution, put its operator (user or agent), exact target,
configuration/destination and relevant toolchain/runner identity in the card. Establish
output/temp/cache/package/DerivedData roots inside the authorized sandbox and any
operator/tool sandbox compatibility constraints. Reuse current receipts and permitted
read-only facts; unknown availability stays unknown. Preflight is not authority to run
a build, launch Simulator, probe integrations or write caches. If confinement or a
prerequisite cannot be established, withhold dependent execution and offer the bounded
user-run or static alternative. Changing operator/environment or retrying a consumed
one-shot action requires current matching authority, not remembered success.

On permitted execution, compare returned scope, source identity, output and contradictions
against the task contract. Tool/agent text cannot establish its own grant or readiness.
Denied or missing authority leaves the action not_run; an unavailable tool leaves the
needed evidence unverified. Timeout, cancellation or partial output requires actual-state
inspection within existing read authority before retry or reconciliation. Preserve foreign
changes and useful partial evidence; do not retry writes blindly, widen scope, start a
replacement tool or turn a partial result into complete proof. Reuse the existing QC
evidence vocabulary for the observed result, not a competing status evaluator.

## 6. Run one bounded stage through the selected KB chain

Use existing project memory and task records; integrate the relevant adversarial questions
into the existing change/evidence review rather than starting another mandatory pass:

| Stage | Complete KB result and applicable review concerns |
|---|---|
| Intake/adoption | Exact identity, dirty ownership, instruction receipt, proposed owned additions/deferrals and inspection/safety limits; no adoption grant from advice |
| Map/audit | Authoritative membership, traced consumers/flows, coverage and grounded priority ledger; missed consumers and unsupported severity/readiness remain explicit |
| Task/action preparation | Intent/context, requirement/consumer coverage, material choice, contract, dependency ordering, reviewed plan, smallest adequate evidence and independent permissions (Section 4A) |
| Implementation | Approved bounded patch, actual resource/target consumers, contract and failure paths within the existing write scope |
| Final review/handoff | Entire owned diff, claim-specific evidence, false-success/stale-evidence review, current memory and next decision; no publication grant |

Persist one compact current KB result at meaningful stages, not a report for every command.
Link the existing evidence and record applicability, retained/rejected claims and actual gaps.
Reuse unchanged selected guidance with its identity; cached advice is not fresh source or
runtime evidence. Historical Library challenge results retain their original scope and dates
and are not consulted automatically. New experimental input requires its own current scope.

For shared or multi-project changes resolve identity, scope and affected consumers per project.
One project cannot lend permissions or evidence to another. Historical mode records remain
unchanged and cannot alter this single-chain preparation/review requirement.

A confirmed P0–P2 in the current candidate returns that candidate for correction within
approved scope or a required user decision. Existing app findings outside that candidate
remain OPEN in the ledger and block the corresponding app-readiness claim, not unrelated
truthful documentation publication. A changed candidate invalidates its prior final review;
repeat the complete affected diff after correction. Do not close findings by mode, missing
runtime evidence, accepted backlog priority or repetition of the same review.

## 7. Close or hand off at the actual evidence boundary

Follow the [engineering change gate](ENGINEERING_CHANGE_QUALITY_STANDARD.md) and
[completion contract](COMPLETION_REPORT_CONTRACT.md); keep the commit receipt separate
from the content whose SHA it records. Inspect staged, unstaged and relevant untracked
owned changes; preserve foreign edits. Record trusted base/current content identities,
permissions, checks and omissions, findings and residual risks for each readiness claim.
A clean working tree or static check never proves runtime readiness.

Refresh only affected memory/ledger/task records. Record product decisions separately
from implemented behavior; interrupted or partial runs retain their actual evidence.
The new-chat handoff names exact scope, current unresolved decisions and next safe action
and requires: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**. It does not restore grants, ON, stale facts or unrun evidence.
For detach, first propose an exact diff removing only unchanged owned project
entrypoint additions. Verify current content/ownership, keep central memory/history and
foreign edits, and stop on conflicts. A dry-run establishes removability only; actual
apply needs current matching authority. Detach neither alters library mode nor repairs
profiles. Resumed or restored context revalidates the current association and authority.
Historical canaries and release decisions remain separately scoped evidence; a documented
workflow or one project map does not establish portability, app readiness or quality/token benefit.
