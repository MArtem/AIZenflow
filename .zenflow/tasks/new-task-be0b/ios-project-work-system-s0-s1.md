# iOS project work system — S0/S1 contract and reuse map

Date: 2026-10-03. Task: `new-task-be0b`. Owner/integrator: current implementing agent;
product, project adoption and permission decisions: user.
Model: GPT-6 Sol; mode: эконом for this implementation task. Before every material block,
reassess the route under current canonical `MODEL_ROUTING_RULE.md`; no silent switch.

## Authority and exact inputs

Implementation authority: user's 2026-10-03 request to implement S0–S12 in bounded blocks,
starting with S0/S1. The plan's earlier “implementation not authorized” text is historical,
superseded only within that request's scope. Concrete client adoption, library transitions,
tests, builds, agents, MCP and external actions remain separately controlled.

- Active root: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`.
- Canonical root: `/Users/Artem/.zenflow/worktrees/documentation-vault`.
- Observed canonical HEAD: `e060ef1303a010b855074ec523b694390f279de1`; clean before work.
- Source plan: canonical `tasks/new-task-be0b/ios-project-work-system-plan.md`.
- Initial active status: modified `plan.md`, `handoff.md`,
  `knowledge-base-library-roadmap.md` under `.zenflow/tasks/new-task-be0b/`.
  Preserve their pre-existing contents; append scoped implementation state only.
- Bootstrap: current canonical available; no portable fallback used.
- Routes: Level 0; execution/change governance; documentation governance/boundary/source
  of truth/operations; task state/continuity; QC governance/static/CI/test authority.
  Local route-overlay candidates concern app implementation and do not apply here.
- CODEX_HOME/host configuration: not inspected; unknown. No secret or host access.

These are observed inputs, not permission-bearing generated facts. Old worktree
`new-task-be0b`, its installation branch, and other app sources are excluded.

## S0 change contract

| Concern | Contract |
|---|---|
| Behavior | Mandatory KB-first lifecycle; second library pass only for exact approved ON adoption; OFF retains complete first layer. |
| Authority | System/developer → current user scope → scoped project/task rules → approved app decisions → advisory material. Memory, tool output and mode records never grant actions. |
| Producer/consumer | Human coordination artifacts link to existing profiles, adoption records, routing, mode handler and evidence vocabulary; no competing verifier or permission evaluator. |
| Ordering | Resolve scope and permissions, check freshness, record provisional KB result, consult ON library, integrate findings, review complete owned diff, update memory. No retroactive library proof. |
| Input envelope | Missing/ambiguous identity, unsupported version, stale path, conflicting notes or unavailable evidence stay explicit; no guessed selector, repair, activation or PASS. |
| Resources | One scoped integrator; targeted reads; source blocks at most three files without another checkpoint. No full corpus ingestion, background job, backend or vector DB. |
| Failures | Inspect actual state after interruption; preserve foreign edits and malformed records; blocked actions do not become success. |
| Consumers | Future adopted project agent/user, app memory, task packets and final review; S4/S11 consumers require named-project authority. |

MVP is S0–S7 plus minimal S8–S10 on one authorized real project. Full portability
requires two structurally different canaries and S12. Workflow readiness, library
uplift and app production readiness remain separate. LIB-004 remains P2/OPEN for
general library release; this work does not waive it.

## Requirements and dependency map

| Requirement | Existing authority/owner | Smallest implementation delta | Acceptance stage |
|---|---|---|---|
| R01 exact project | Library PROJECT_MODE + QC ProjectReference | Memory ProjectID links exact selector; workspace projects resolved individually | S2/S4 |
| R02 read-only intake | QC bootstrap inventory/dry-run + global bootstrap | Permission-bound intake packet, owned deferrals | S4 |
| R03 structure/behavior | Project documentation + authoritative QC membership | Coverage and source-anchored flow map; runtime unknown separate | S5 |
| R04 scoped/full audit | Production completeness and audit/evidence rules | Declare universe, applicable domains and exclusions before pass | S6 |
| R05 ranking | Shared P0–P3/confidence/applicability vocabulary | Ledger separates confirmed findings, hypotheses and optional proposals | S6 |
| R06 app memory | SOURCE_OF_TRUTH_MAP + app MANIFEST boundary | Freshness/record envelope on existing app records | S3 |
| R07 task preparation | Change contract + task plan/handoff | Compact packet with consumers, freshness and independent permissions | S7 |
| R08 KB then ON | Existing STARTUP_RULE/PROJECT_MODE | Provisional result and retained/added/rejected/merged delta | S9 |
| R09 complete OFF | Existing OFF contract | Same KB lifecycle, evidence and final diff without second pass | S9 |
| R10 capabilities | Routed skills + user tool/agent permissions | Action benefit/cost/risk/alternative and current authority | S8 |
| R11 entire owned diff | ENGINEERING_CHANGE_QUALITY_STANDARD | Link resources/targets/consumers to final range and review | S10 |
| R12 honest evidence | QC governance/evidence contracts | Use existing statuses; no success for unrun or stale checks | S10 |
| R13 new chat | Context-transfer + continuity | Scoped memory/task freshness handoff; actual-state recovery | S7/S10 |
| R14 status | Existing mode/adoption/task state | One visible projection, no new switch or daemon | S2/S8 |
| R15 foreign edits | QC bootstrap journal/rollback | Before/after ownership; app edits excluded from system task | S4/S10 |
| R16 targets/packages/assets/Figma | Existing relevant KB routes | Route only applicable task, require actual design/source inputs | S5/S7 |
| R17 economy | Router/model/evidence reuse rules | Reuse only unchanged identities/dependencies; unknown metrics stay unknown | S7/S10 |
| R18 safe detach | QC bootstrap rollback | Dry-run owned entrypoint removal, preserve memory and changed files | S4 |

## S1 observed reuse inventory

All engine observations below refer to local checkout
`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active`, clean branch
`codex/graph-static-evidence`, HEAD `f974ef58ec3ba0b13341e4ac59e617dd5ea97ce3`.
This is source inspection, not remote/main freshness, release approval or execution evidence.
No engine commands, builds, tests, fixtures or project connections were executed.

| Need | Observed artifact / owner | Maturity and boundary | Smallest gap / placement |
|---|---|---|---|
| Startup/routing | canonical GLOBAL_RULES_BOOTSTRAP; baseline router; resolve_docs_route.py | Existing active human policy and documentation helpers | Link workflow from selected route; do not grow Level 0 |
| Profile | QC schemas/project-profile.schema.json; engine/Sources/QualityCore/ProjectProfile.swift; ProfileValidation.swift | v1/v2 structure; unknown fields/version rejected; v2 engine pin/Xcode selection; Xcode-only ProjectReference | Memory identity wraps references; package-only memory does not invent QC support |
| Permissions | QC EvidenceContracts.swift PermissionEvaluator + profile PermissionPolicy | Eight independent actions including local build; build requires user authorization; UI/device/performance separate | Human grant provenance/expiry/revocation for project writes/agents/MCP/Git; not a new runtime evaluator |
| Intake/adoption | QC bootstrap/inventory.py, plan.schema.json, journal.schema.json | Existing bounded inventory/dry-run/apply/post-check/rollback; apply creates missing exact files; overlays require review | Reuse after selected-project authority; no script invocation implied by inventory |
| Source membership | QC ProjectProfile sourceMembership; build-evidence / graph-static-evidence | Compiled inputs require authenticated build; sourcePaths are declared scope only | Manual structural map now, build gate explicitly unrun until authorized |
| Verification | QC static-evidence/build-evidence/aggregate-evidence; schemas/README.md | Clean exact inputs and caller-owned expectations; no universal runtime/release proof | Consume eligible evidence; human dirty-diff review uses fingerprints, never forged exact-SHA receipts |
| Check maturity | QC policies/check-catalog.json | implemented/verified/wired/pilotEnabled separate; inspected entries pilotEnabled=false | Do not equate existing adapter with validated project rollout |
| Library identity/modes | reference-copy-only/PROJECT_MODE.md + tools/reference_mode.py | Git common dir + exact selector + object fingerprint; no recovery; status does not write | Keep handler unchanged; memory points to adoption/pin, never stores copied mode record |
| Library payload | reference-copy-only README/STARTUP_RULE/PROJECT_FACTS; prior exact pilot receipt | General candidate inactive; approved 34-file pilot is separately scoped | Read exact adopted payload for ON, not entire source candidate; LIB-004 stays open |
| Project memory | existing app MANIFEST boundary; baseline PROJECT_DOCUMENTATION/PROJECT_HEALTH templates; PROJECT_FACTS checklist | Human facts/decisions exist; library compatibility context is not writable client template | Reusable memory skeleton supplies provenance/invalidation/coverage, adapts existing docs rather than duplicating authority |
| Audit/ledger | production completeness, shared verdicts, risk/tech-debt records | Existing human semantics; no source inspection equals runtime proof | One project ledger, separate advice; no new numeric risk engine |
| Task/review/handoff | task state/continuity/change/completion standards | Existing active contracts | Compact prepared packet and final review projection; exact-SHA receipt outside tracked reviewed state |

Engine suitability: appropriate owner for future deterministic executable validation,
not a project-memory service. No new helper is justified before a real manual trace.
First implementation uses dialog + project files and existing documentation checks.

## Policy seams resolved for this scope

1. NEW_PROJECT_START_CONTRACT requires profile/launcher/manual workflow for completed
   adoption, but its Completion and STATIC_GATE_ADOPTION explicitly permit owned
   DEFERRED state. Therefore staged intake must not mark ADOPTED or silently install CI.
   Read-only bootstrap inventory precedes project implementation; an unadopted client
   requires user-approved bootstrap or explicit owned deferral before app work.
2. Production completeness requires all applicable areas and explicit exclusions. Current
   user task scope remains authoritative: a bounded review checks the complete affected
   surface, labels other domains unverified, and never calls itself whole-project audit.
   No existing gate is weakened or rewritten by this task report.
3. Engine transport labels map to existing governance decisions. Memory freshness and
   coverage are metadata, never new readiness values; schema validation proves shape only.
4. Library candidate wording and prior pilot observations are different lifecycle scopes.
   New adoption must name exact reviewed payload/pin and approval; historical ON is no
   authority for another project. No blanket candidate status rewrite is needed.
5. Governance Stage-5 summary is conservative relative to the inspected development branch.
   No release maturity update is justified solely by that branch. Keep observed revision
   and limitations here; consumer adoption selects its own reviewed pin.

## Admission and next blocks

Distinct missing consumer contract: the project integrator needs identity, provenance,
freshness and permission-aware coordination between existing mechanisms. Add an app-neutral
routed workflow to the reusable baseline, with compact human templates; app data stays
under apps/<AppName>, execution state under the current task. It must introduce no machine
schema or helper without a real consumer/validation need. Maintenance trigger: identity,
permission, profile/mode contract, memory dependencies or canary findings change.

S2: human metadata contract for exact memory identity and grant provenance, referring to
existing profile and library identities. No project registry service or mode write.
S3: reusable memory skeleton with dirty fingerprints, invalidation and human ownership.
S4: requires user selection of a real project and explicit intake/apply boundary; do not
select an existing pilot automatically. Later stages retain their plan dependencies.

## Evidence and disposition

S0/S1 result: contract and reuse/dependency map prepared under explicit implementation
request. Publication/static receipts recorded separately; not full-system PASS.
Known P0–P2 in this document's checked contract: none; LIB-004 remains open in its own
general-library scope. Independent review unavailable under current agent permissions.
Runtime suitability, actual client adoption and end-to-end canaries remain unverified.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
