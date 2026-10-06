# iOS Project Work System

## Purpose, authority and use

This workflow coordinates exact project identity, permission-aware preparation and fresh
project memory for an iOS project integrator. Load it for project intake, memory refresh or
task preparation through the `ios-project-work-system` route, after canonical bootstrap
and Level 0. It adds no Level 0 requirement and does not activate a project or library.

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

The mandatory first layer is current user/project rules and KB routes. An exact approved
IOS Library ON adoption adds a second pass after the provisional first-layer result at
each applicable stage. OFF retains the complete first layer. Missing/invalid/unknown
library status never implies ON. AUTO grants only in-session reasoning within existing
authority; ADVISORY advice is not performed evidence. Use the exact adopted payload and
its mode contract; do not consult an inactive general candidate as an installed release.
Do not create another mode switch, copy raw mode records into memory, replay transitions
from history or enable a project from a manifest. Library uplift and workflow readiness
remain separate release decisions.

No host installation/configuration, secrets, background work, backend, vector database,
custom MCP, automatic CI, app connection or extra command authority follows from this file.

## 1. Select one exact scope

Before reading a client beyond the authorized intake, resolve and display:

| Field | Meaning / refusal rule |
|---|---|
| ProjectID | User-confirmed opaque stable memory ID, unique among active app manifests; not a remote URL, folder label, mode key or permission token. Missing/duplicate ID blocks memory association until resolved. |
| App boundary | Existing `apps/<AppName>/MANIFEST.md`; adapt it before adding a competing registry. Multiple independent apps keep separate IDs/boundaries. |
| Repository root | Exact physical authorized root, Git or explicit local-only. Symlink escape/out-of-sandbox paths block access. |
| Checkout | Worktree root and observed HEAD, relevant dirty ownership; a linked worktree is a checkout, not automatically another app. |
| Selector | Exact normalized repository-relative `.xcodeproj` or standalone `Package.swift`; workspace plus its individually selected projects. Ambiguity requires selection. |
| Targets / configuration | Observed affected targets and authoritative membership source; unknown stays unknown. A shared scheme name does not prove membership. |
| Adoption/profile | Paths, recorded lifecycle, reviewed engine/profile revision and compatibility; no ADOPTED without the existing gate. |
| Library adoption | Exact project-approved payload/pin/entrypoint and current observation of existing mode handler, or explicit unverified state. |

ProjectID links project memory; it must not change the existing library identity derived
from Git common directory plus exact selector and scope fingerprint. A workspace is not
one shared library switch. Shared source can have several affected consumers, each with
its own permissions/mode. QC profile supports only its declared schema/project kinds;
standalone-package memory does not fabricate an Xcode profile or engine capability.

For a clone, relocation, rename, replaced root, selector change or linked worktree:
compare physical scope, existing manifest and current source identity. Ask the user to
confirm a changed association before reusing memory. Equal remote/name is insufficient.
Keep the stable logical ID only for an explicitly confirmed association; record the old
association as historical. Never transfer grants or ON merely because the ID is retained.
For an empty new project without a selector, record unbound identity and stop selector-
dependent actions; no fabricated targets or architecture.

The minimal registry is the set of existing app manifests. Check uniqueness at association
time using only their identity fields; missing, unreadable or conflicting identity makes
the check partial and blocks a uniqueness claim. Do not scan unrelated app behavior.

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
[project memory skeleton](../templates/IOS_PROJECT_MEMORY.template.md). The skeleton is
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
| Profile/toolchain/SDK/policy/library pin change | Relevant compatibility, route/delta and execution receipts. |
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

Display selected identity, adoption, observed library status, current stage, blocking
findings, action permissions and unrun evidence. Unknown mode preserves full KB work
while the second layer remains unperformed. Reject unscoped “all ready” summaries.

The next operational gate is a named-project read-only intake followed by proposed
adoption/deferral and separately authorized apply. Reuse the engine's inventory/dry-run/
apply/post-check/rollback lifecycle where suitable; it does not authorize invocation.
Rollback may remove only unchanged owned additions, never foreign files or central memory.
After selection load only the relevant source/rule routes. App implementation, full audit,
task execution and canary acceptance require their own scope and evidence; the existence
of this workflow and template proves none of them.
