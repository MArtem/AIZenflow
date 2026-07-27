# Document Change Governance Standard

## Purpose
Define the admission, placement, routing, maintenance, verification, and retirement rules for documentation-system artifacts.

This standard applies to rules, standards, contracts, guides, runbooks, checklists, templates, prompts, skills, package documentation, manifests, registries, machine-readable policies, and documentation validators.

## Authority And Maintenance
This is the active reusable Level 1 governance standard for documentation-system changes. Its canonical source is the reusable baseline in `MArtem/AIZenflowDocumentation`; project copies are governed mirrors or approved overlays.

Load it when adding, materially restructuring, splitting, merging, superseding, archiving, or removing any covered artifact. The reusable baseline governance boundary owns maintenance. Review it when artifact types, repository boundaries, routing contracts, registry schemas, bootstrap requirements, or documentation validators change.

This standard does not decide product behavior, replace task-state documentation, or replace the boundary, source-of-truth, and repository-operations standards it invokes.

## Core Rule
Update the existing canonical source when it already owns the concern. Create a new artifact only when a distinct purpose, audience, trigger, authority, lifecycle, or machine-readable contract makes a separate source necessary.

Temporary task history, a convenient summary, or a preference for another file layout is not sufficient justification for a new durable artifact.

## Mandatory Admission Gate
Before adding or materially restructuring an artifact, record or establish all of the following:

1. **Problem:** the concrete ambiguity, failure mode, decision, or repeated workflow the change resolves.
2. **Existing source search:** the current canonical rule, route, index, app boundary, task state, prompt, skill, package doc, or validator that may already own the concern.
3. **Action choice:** update, split, merge, create, supersede, archive, or remove.
4. **Boundary:** reusable, app-specific, package-specific, or task-local, as defined by `./docs/DOCUMENT_BOUNDARY_STANDARD.md` and `./docs/SOURCE_OF_TRUTH_MAP.md`.
5. **Authority:** the source of truth, precedence relative to existing rules, and any conflict or migration impact.
6. **Consumers and trigger:** who or what loads the artifact and under which task condition.
7. **Context cost:** whether the artifact increases Level 0 or routed context and why that cost is justified.
8. **Verification:** the indexes, registries, validators, examples, consumers, and task-state records that must change together.

Do not create the artifact while its boundary, authority, or intended consumer is unclear. Ask for direction when resolving that ambiguity would change product behavior, weaken an existing rule, or promote local knowledge into the reusable baseline.

## Choose The Smallest Correct Artifact

| Need | Correct default |
|---|---|
| Existing canonical source already owns the concern | Update that source and its affected consumers |
| Durable app behavior or app exception | Store under the matching `apps/<AppName>/` boundary |
| Temporary execution state, evidence, or next steps | Store in the current task plan, handoff, report, or archive |
| Explicit local deviation from a reusable rule | Use `LOCAL_EXCEPTION_ADR_TEMPLATE.md`; do not weaken the reusable rule |
| Repeated app-neutral requirement approved for promotion | Add or update the reusable baseline after boundary and conflict review |
| Stable machine-consumed relationship | Use a versioned registry/policy plus a validator or resolver |
| Explanation that does not introduce a new contract | Add a short section or link to the existing canonical source |

Reject a proposed artifact when it merely duplicates another source, combines unrelated concerns, copies another app's decisions, preserves transient discussion as permanent policy, or has no discoverable consumer and maintenance path.

## Required Shape
Every durable artifact must make these facts discoverable in proportion to its size:

- purpose and intended audience;
- scope and material non-goals;
- authority or source-of-truth relationship;
- loading or usage trigger;
- maintenance owner by boundary and the event that requires review;
- lifecycle state when it is draft, transitional, superseded, or archived.

These facts may be expressed in normal sections; mandatory front matter or decorative boilerplate is not required. Short artifacts should remain short.

Normative requirements must use unambiguous language. Examples and rationale must not silently broaden authority. Keep one canonical rule and use short links from secondary surfaces instead of copying long instructions.

## Boundary And Promotion Rules
- Reusable artifacts must be app-neutral and must not encode app names, feature policy, current task state, local paths, or temporary acceptance decisions.
- App-specific and task-specific knowledge stays in its matching boundary until the user explicitly approves promotion.
- Active app docs link to reusable policy rather than copying it. Mixed historical imports are allowed only in a clearly named non-authoritative `legacy-reference/`, `history/`, or `archive/` area with a provenance README and no normal routing/bootstrapping role.
- Promotion requires a new app-neutral formulation, conflict review against the reusable baseline, and updates to all affected consumers. Copying an app document into reusable storage is not promotion.
- Rules that affect repository authority, security/privacy, persistence/data loss, public APIs, package ownership, or completion evidence require high-risk review before adoption.
- A new rule must not weaken an existing higher-authority rule. Any approved exception remains explicit, scoped, owned, and reviewable.

## Routing, Indexing, And Machine Contracts
Before completion:

- every new active top-level document is listed in `./docs/README.md`, assigned exactly one primary level in `./docs/DOCUMENT_ROUTING_REGISTRY.json`, and reachable through `./docs/TASK_DOCUMENT_ROUTES.json`;
- prompts, skills, package docs, architecture cases, and archives use the established path-pattern and trigger-based routes unless a distinct route is justified;
- reusable baseline additions are classified by `./docs/REUSABLE_BASELINE_POLICY.json` as exact mirrors, allowed overlays, canonical-only files, or local-only files;
- reusable files are listed in the relevant manifest, and bootstrap-critical files are required by the bootstrap and vault validators;
- human-readable routing and machine-readable routing remain consistent;
- new registries declare a schema version, stable identifiers, ordering semantics when order matters, and a validator or consumer that fails clearly on malformed or stale data.

Level 0 is reserved for authority, routing, current task state, and rules required for every task. A useful document does not belong in Level 0 merely because it is important. Measure route cost before and after routing changes and prefer task-specific Level 1/2 routes.

## Change And Migration Rules
For a material update, identify affected consumers, links, templates, validators, examples, and active task state. Preserve compatibility or document the migration when identifiers, paths, schemas, precedence, or required behavior change.

For a split or merge:

- designate one canonical destination for each rule;
- replace duplicated normative text with links;
- update routes and consumers in the same change;
- preserve a redirect or supersession note when old references may remain.

For supersession, archival, or removal:

- state the replacement or the reason no replacement exists;
- update indexes, registries, routes, manifests, validators, and incoming links;
- retain required historical evidence in the correct archive or Git history;
- never silently delete an active rule or leave two sources claiming the same authority.

## Verification Matrix
Run only the checks relevant to the change, but do not omit an applicable gate:

- active documents and routes: docs index, router, route resolver, and consistency checks;
- boundary or promotion changes: documentation-boundary checks and manual neutrality review;
- reusable baseline changes: bootstrap contract, baseline drift, manifest, and vault checks;
- JSON, registries, scripts, or validators: syntax/parse checks plus representative success and failure cases;
- routing changes: context-cost report, Level 0 budget, reachability, and duplicate/overlap review;
- all documentation changes: secret scan when available and `git diff --check`;
- canonical repository publication: clean/synced status and remote-state verification after push.

Application builds, tests, simulator runs, or Instruments are required only when the documentation change also changes or claims runtime behavior and the user has approved those checks.

## Completion Checklist
- [ ] The admission gate is satisfied and the smallest correct action was chosen.
- [ ] Boundary, authority, precedence, owner, and update trigger are clear.
- [ ] No duplicate or conflicting canonical rule remains.
- [ ] Index, primary level, task route, manifest, baseline policy, and validators are updated where applicable.
- [ ] Context cost is measured and no unjustified Level 0 growth was introduced.
- [ ] Migration, supersession, archive, or recovery paths are documented where applicable.
- [ ] Relevant static checks pass or every failure is classified with evidence.
- [ ] Task plan/handoff records the durable result and remaining risk.

## Context Transfer Rule
When handing this work to another agent or chat, include:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
