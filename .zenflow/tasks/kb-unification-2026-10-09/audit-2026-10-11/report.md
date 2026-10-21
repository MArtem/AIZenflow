# Critical KB audit — evidence checkpoint, 2026-10-19

Status: COMPLETE_STATIC_AUDIT_WITH_LIMITS; KB acceptance NOT_READY. Active KB unchanged. Current user-selected GPT-6.1 Sol / medium (from 2026-10-19; immutable transition boundary recorded), эконом; selector identity user-declared, not independently inspected. No independent agent, runtime, tests, U7 or external freshness verification. Historical acceptance223 was not reused as semantic proof.

## Current coverage checkpoint — 2026-10-19

This section supersedes running counts in the dated continuation notes below. Exact source identities, unit adjudications and qualifications are in coverage.json; thematic receipts retain the detailed evidence.

- 1403/1403 frozen source rows READ, 1288 distinct body hashes and 115 independently verified exact-byte alias reuses; 0 sources unread. Alias-specific maps reviewed separately.
- 4285 unit dispositions adjudicated: 2555 active MIGRATED/ALREADY_COVERED; 1730 archive. Archive dispositions are not active coverage.
- All 289 deep-playbook sources,121 P2 sources,25 root administrative sources,12 repository-native sources,18 V3 roles,40 V3 workflows,18 project-context templates,14 adaptation sources,15 V4 role/workflows,15 orchestration protocols,20 V5 role/workflows,20 V5 prompts,10 V5 templates,6 V5 gates and legacy README are reviewed with recorded limits.
- Catalog1060 and package1086–1095 reviewed; historical catalog/INDEX metadata correspondence resolved. Runtime core, protocols, schemas and project templates through1155 reviewed. Source-skill packets1156–1395 complete; all source bodies read; final audit-artifact synthesis/review recorded in final-review-receipt.md. Earlier1061–1085 and1096–1107 already reviewed separately; no duplicate credit.
- 37 project-copy units remain separately accounted:36 supported with limits; COPY-ROUTER-U10 unverified. A01–A12 remain unresolved; remedies proposed only. Full-ledger acceptance NOT_PROVEN.
- Model transition: immutable709-source pre-switch boundary; subsequent sources GPT-6.1 Sol / medium, repeat pass NOT_REQUESTED_OR_EXECUTED. Technical freshness and actual token telemetry UNKNOWN; U7 NOT_RUN; sealed holdout/oracle EXCLUDED. Active KB unchanged.

All eight final inactive-tool sources1396–1403 reviewed in inactive-tools-semantic-receipt.md. Full source reading and final artifact review completed with explicit limits. See final-review-receipt.md.

## Final assessment - 2026-10-19

The requested static audit and proposed remediation plan are complete. KB acceptance is NOT_READY: A01-A12 remain OPEN (10 P2,2 P3),207 canonical unit qualifications and COPY-ROUTER-U10 remain explicit. A11 is one confirmed mapping defect;207 qualified IDs are overlapping concerns, repeated clauses and citation gaps, not207 independent defects. All1403 sources/4285 canonical units and37 separate copy units were assessed; no unread canonical sources remain.

Priority: authority/forbidden-evidence/verdict/severity conflicts R1; mandatory resolver R2;31 delivery paths R3 with transitive context cost R4; app boundaries R5; exact preservation/citation queue R0; external freshness R6; measured routing reductions R7 and separately authorized outcome evaluation R8/U7. Owner/files, dependencies, acceptance, permitted checks, rollback and qualitative cost/benefit are in remediation-plan.md. Active KB, original ledger/archive and Git unchanged.

READ means complete source text or115 verified byte-identical body reuses with separately inspected maps; REVIEWED means documented static assessment with limits. UNVERIFIED covers unresolved exact claims, external freshness, live loader/fallback, examples/compiler/runtime and quality/token/subscription outcomes. EXCLUDED materials/actions were not opened/executed to force completeness; sealed holdout/oracle excluded, U7/executable negative controls NOT_RUN. iPad/physical/actualVoiceOver OMITTED_BY_USER.

Current assessment supersedes dated checkpoint statements below. Archived instructions remain audit data, never action authority. Model boundary:709 pre-switch sources +694 Sol-medium sources, repeat suffix LIB-0589 inclusive; no second pass performed. Final-review-receipt.md records artifact verification and limitations.

## Current identity

Revalidated worktree HEAD `860ca8b7cc07e654d73339cdf6705319979df3df`; canonical HEAD `063ba79c44c7144e072da06d5f675e7471a59627`. Remote freshness UNVERIFIED; no network/publication performed. Worktree status contains only the untracked audit directory; canonical is clean. Current artifacts are task-local and unpublished.

## Evidence and coverage

READ in full: canonical bootstrap/baseline AGENTS/router/overrides/model rule; current migration plan.md/handoff.md/acceptance223; preflight/change-quality/task-state/context-transfer and documentation governance/boundary/source-of-truth/operations/completion standards; documentation architecture/library guide/summary/index/quality catalog; knowledge scope/registry; all 12 primary iOS deep references plus README; AI router and all 2790 lines of AI master; architecture router/modularity/MVVM/accessibility/localization standards; universal quality and production gates; security/performance/observability/incident standards; concurrency standard; project workflow and memory template; Tchop and Battleship manifests/context, Battleship ledger/card and both nested AGENTS; 28 local skills; full diff of all31 drift paths; resolver/cost/drift/knowledge/router/index/consistency/boundary validator source; archive README and historical212/213/validation receipts. Truncated tool output was supplemented for router, universal quality, production gates and workflow.

REVIEWED: authority and permission conflicts in those documents; full31 drift delta; 18 domain declarations against selected owner guidance; 31 archived CODE_PATTERNS bodies (index +30 patterns) for safety/limitations and relationship to current deep guidance. Examples were not compiled. Their individual dispositions have since been adjudicated in code-pattern-semantic-receipt.md; this does not prove equal instructional effectiveness of removing active examples.

Structural REVIEWED only: all1474 archive members CRC/read, names, bytes, SHA;1403 ledger file hashes;4285 canonical literal fragments;37 copy-unit accounting;68 retained live payload byte parity;16 current consumer fingerprints and all12 cost recipe file fingerprints. See accounting.json and cost-current.json. These operations do NOT establish semantic coverage.

UNVERIFIED: complete semantic equivalence for207 specifically qualified canonical units and COPY-ROUTER-U10; instructional effectiveness of retired examples; architecture cases/package references and transitive documents not explicitly recorded as READ; live technical freshness, actual skill loading, fallback execution, app source behavior, token telemetry, code-quality uplift and subscription savings. Registry18 active/5 complete/4 deferred is a declaration, not an audit verdict.

EXCLUDED: sealed holdout/oracle, previous closed experiment, host/config/secrets, agents/chats/MCP, installs/downloads, handler/mode actions, app source/tests/runtime; iPad/physical/actualVoiceOver verification OMITTED_BY_USER. No old grants restored.

## Confirmed findings

### A01 — P2 / high: strict ownership decision not delivered to skill

`reusable/local-ios-skills/ios-swift-runtime/SKILL.md`, Guardrails: “Treat unsafe and unchecked annotations as audited promises.” Same wording in local skill and distribution baseline. Contradicts canonical baseline AGENTS Implementation Style and primary Swift reference Interoperability, including resolved DEC-001. Scenario: interoperability migration follows the specialist skill and retains a forbidden annotation. Higher authority still prohibits it; no actual app violation is claimed. Minimal fix: align primary skill with strict owner and distribute exact copies; retain archive unchanged.

### A02 — P2 / high: resolver permits missing Level0

`scripts/resolve_docs_route.py`, resolve_routes: required_set contains only required route documents; the loop also visits level0_documents and classifies missing paths absent from required_set as optional_missing. main ignores optional_missing in its failure return. Missing CURRENT_USER_OVERRIDES.md can therefore produce a successful route resolution. Static branch trace, not an executed negative test. Minimal fix: include mandatory static Level0 in required classification; distinguish legitimately absent dynamic task docs by explicit contract. Do not blindly copy local resolver to canonical.

### A03 — P2 / high: distribution skills contradict primary sources

All28 stale skill paths in drift-dispositions.json have local_equals_primary=true. Baseline distribution still contains relative `./docs/` references; five descriptions also contain unquoted colon-space YAML scalars (API contracts, evidence, incident, network, offline). Scenario: new consumer receives stale/invalid skill metadata while current worktree appears functional. YAML loader outcome UNVERIFIED; malformed scalar text and parity divergence are directly observed. Minimal fix: refresh distribution from reviewed primary skills after A01/A04, preserve local improvements. No mass reverse sync.

### A04 — P2 / high: excluded verification is still recommended

Primary/local `ios-performance-profiler/SKILL.md` Workflow3–4 selects/prefers physical devices; identity skill Workflow6 selects physical evidence. `IOS_PERFORMANCE_BUDGETS.md` Measurement Rule recommends physical-device verification; AI master section11 requires physical-device model checks. The primary performance deep reference, Evidence, additionally lists unqualified “Release-build/device evidence for production claims” and representative low/mid devices; Optimization Workflow also lists older-device regressions. These need an explicit permission-aware evidence boundary like the media reference already has; they must not be interpreted as restoring physical checks. The explicitly physical recommendations conflict with CURRENT_USER_OVERRIDES USER.VERIFICATION.SCOPE, which excludes even proposing such checks. Scenario: resumed specialist task recreates a prohibited acceptance gate. Minimal fix: permission-aware evidence selection with OMITTED_BY_USER and unchanged implementation requirements. Preserve historical results.

### A05 — P2 / high: boundary validator misses newly named apps

`scripts/check_documentation_boundaries.py`, EXPECTED_APP_ROOTS and loops: checks only four named app roots. DOCUMENTATION_ARCHITECTURE.md Dynamic App Boundary Discovery explicitly requires every direct non-hidden apps directory. Scenario: a new app lacks MANIFEST or contains copied baseline files and this validator misses it. Minimal fix: discover app directories structurally and inspect each; retain explicit legacy checks separately. No negative fixture executed.

### A06 — P2 / high: ordinary context reporter omits canonical startup

`scripts/report_documentation_context_cost.py`, instruction_envelope: looks for root.parent/GLOBAL_RULES_BOOTSTRAP.md and counts only root/AGENTS. In this worktree the controlling bootstrap and baseline AGENTS are in documentation-vault/reusable. Scenario: use routine reporter to judge startup economy and undercount required authority inputs. Minimal fix: explicit canonical/fallback identity and deduplicated actual physical-path envelope. Historical block223 used a separate full recipe and is NOT invalidated by this defect.

### A07 — P2 / medium: freshness metadata cannot support its claim

IOS_KNOWLEDGE_COVERAGE_REGISTRY.json verification declares last_primary_source_review2026-09-10 while one cited release URL encodes09142026. No per-domain review evidence or source revision links connect the five complete declarations to their coverage-unit requirements. Date mismatch needs provenance adjudication; it is not proof that the URL or release is fictitious. Validator checks only ISO syntax/nonempty toolchain, path existence and minimal fields. Minimal fix: attach domain-scoped source/review evidence or label freshness unknown; never merely advance the date.

### A08 — P3 / high: portable policy mirror differs

Local docs/REUSABLE_BASELINE_POLICY.json omits templates/IOS_PROJECT_MEMORY.template.md from canonical_only_patterns; canonical policy includes it. Exact diff is in drift.diff. Scenario: local-policy consumer treats canonical-only template as missing distributable content and reintroduces the already corrected copy. Minimal fix: align policy and verify fallback still fails closed for unavailable optional template. No fallback activation performed.

## Limits, strengths and hypotheses

Archive SHA remains `9c3e80135ef713a205f6e0481b9c6eecae8836b51df16d9e2ce459d0dfeee76f`. Historical structural accounting for4322 units (4285 canonical +37 copy):222 MIGRATED/2362 ALREADY_COVERED/1468 ARCHIVE_ONLY_INFRASTRUCTURE/270 ARCHIVE_ONLY_NO_INCREMENTAL_VALUE. Canonical-only final reviewed counts are217/2338/1461/269 respectively. These are disposition counts with207 audit qualifications, not207 proven losses or blanket semantic acceptance. Archive dispositions are not active instructional coverage.

Current project entrypoints and administrative headers explicitly retire Library second passes and supersede old grants. Long historical bodies still contain imperative old instructions, but headers establish supersession; actual reactivation was not observed. Splitting current memory from dated evidence is an economy/clarity proposal, not a claim of existing unauthorized execution.

Technical guidance covers many valuable invariants: stale success AND failure, invocation-owned cleanup, bounded cancellation-ignoring producers, logout/session publication, durable replay/tombstones, account-scoped state, migration reopen-before-cleanup, input/resource bounds and honest evidence. Most deep documents are compact operating references, not comprehensive technical tutorials. Five complete domains require individual coverage-unit proof; file existence cannot supply it.

Hypotheses requiring further evidence: AI master section62 caching wording may suggest omitting a repeated prefix that a provider requires for cache matching; coarse API/network/offline routes may cause unnecessary reads; full-file delivery may dilute relevant constraints. None is recorded as demonstrated quality degradation or measured token waste.

## Cost and scenario evidence

Current12 full-file recipes were revalidated on2026-10-19 against actual files, hashes, regex-word and byte counts. Words/bytes are recomputed in cost-current.json: unrelated8673/69397; task-doc14970/116482; localization17922/138972; cancellation18272/142880; build18399/143749. Median17047.5 words. These are text envelopes, not actual consumed tokens. Tool output, retries, reasoning, caching, system context and subscription telemetry are unavailable.

Exact Tchop selection adds nested overlay227 + workflow4341 + manifest407 + context2331 =7306 words to a recipe lacking those files. Battleship adds247+4341+344+1249=6181. Template999, audit ledger1197 and task card998 are conditional additions, not automatic startup. Combined routes must deduplicate paths; identical prose across distinct authority files still costs text. Resume reload costs depend on actual invalidated inputs; no saving percentage promised.

Twelve historical recipes prove frozen route-file envelopes, not natural-language routing or code quality. They omit AI, commerce, identity, background and cross-domain outcome assessment. Required negative controls include synchronous/no-outstanding-work versus genuine stale publication; generic error after cancellation; logout during refresh plus replay; migration success followed by cleanup failure; missing static Level0; required/optional collision; unavailable template; new app boundary; denied hardware checks; stale skill distribution. These are proposed scenarios, NOT created or executed tests and NOT U7 authorization.

## Continuation, 2026-10-12

All registry operating_documents and deep_references have now been read fully, including 20 additional documents; check_bootstrap_contract.py, the full original migration-plan.md and UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md were also read. The interrupted middle of migration-plan output was explicitly reread. See domain-review.md for all18 domain boundaries and nine validator limitations. Source-body coverage is now38/1403, not31;1365 remain semantically unread. These updates supersede the earlier checkpoint counts, without retroactively labelling remaining units reviewed.

### A09 — P2 / high: release receipt exposes legacy labels as final decisions

Canonical `reusable/baseline/docs/IOS_RELEASE_CHECKLIST.md:68`, Release Receipt, lists READY/NEEDS_OWNER_DECISION/BYPASSED directly as final verdicts. `UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`, Authority, Verdict, And Readiness Contract, explicitly limits decisions to PASS/NOT_READY/READY_WITH_ACCEPTED_RISK/BLOCKED/NOT_APPLICABLE and requires legacy transport labels to be mapped. CI_CD_QUALITY_GATES Result Semantics repeats that rule. Scenario: an automated or human release receipt reports BYPASSED without the required approved exception or labels READY despite missing readiness evidence. The checklist's earlier strict evidence clauses still control; no actual release bypass observed. Minimal fix: use canonical decisions in the release template, or show explicit legacy mapping and exception evidence in the same receipt. No permission to release follows.

The original plan's U4 lower-median budget was explicitly superseded by task DEC-002 acceptance of measured full-read growth, as recorded in current plan/handoff/block223. Thus the measured +9.261% is not by itself a newly established unauthorized-budget violation; it is still a cost increase and not token-economy evidence.

Prioritized proposed remediation is in remediation-plan.md. The active KB, archive, original ledger and historical receipts remain unchanged. Full independent migration acceptance remains NOT_PROVEN; these artifacts are an audit checkpoint, not a completed exhaustive audit.

### A10 — P2 / high: final cost recipes omit mandatory transitive inputs

`reusable/baseline/docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md:12` requires the full production-review prompt and then the checklist/gates. `PRODUCTION_CODE_REVIEW_CHECKLIST.md`, Usage Rule, requires README; `docs/agent-prompts/production-review-completeness.md`, Required Inputs, also requires AGENT_RULES. None of these five files is included in the nine `ios-review-audit` scenarios of the final223 recipe. Exact per-file evidence and bounded corrected totals: transitive-cost-gap.json. This is distinct from A06: even the custom223 recipe has incomplete transitive closure, despite exact hash/sum arithmetic. The earlier report statement that223's full recipe was unaffected by A06 remains true only for that particular bootstrap defect; it does not establish full startup completeness.

Scenario: compare unified KB cost using declared route arrays; mandatory downstream inputs consume additional context or are silently skipped. Minimal fix: make the selected-route contract explicit about applicable transitive reads, reconcile the broad checklist/index intake with router authority, and recompute full chains without mechanically opening every link. This is not evidence of actual duplicate reads, token usage or code-quality regression. Do not turn an ordinary hyperlink into a mandatory dependency. The measured delta is a lower bound for these nine recipes; project facts/conditional workflow/actual repeats can add more. DEC-002 accepted the then-reported increase, not proof that omitted inputs cost zero.

A05 defense-in-depth qualification: canonical `scripts/check_documentation_vault.py` does discover app directories dynamically and would catch a missing new-app manifest when that separate checker runs. It does not inspect new-app duplicate baseline bodies. Thus A05 is a specific boundary-check coverage defect, not a claim that the entire validator suite misses every new-app problem. Both canonical manifest/checker sources were read fully; neither executed in this audit.

Additional full reads supporting A10: AGENT_RULES, production-review-completeness prompt, PRODUCTION_REVIEW_COMPLETENESS_GATE, IOS_PRODUCTION_READINESS_STANDARD, DEFINITION_OF_DONE, IOS_PRODUCTION_EXCEPTION_POLICY, IOS_TOOLCHAIN_PROFILE_STANDARD, EVIDENCE_BASED_ENGINEERING_RULES, error/input/configuration/product standards and PRODUCTION_CODE_REVIEW_CHECKLIST. Machine-readable registry/source coverage is coverage.json; the 19 independently adjudicated specific source units do not represent all units in their files.

## Exact primary locators

| Finding | Current file/line |
|---|---|
| A01 | [SKILL.md:32](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/local-ios-skills/ios-swift-runtime/SKILL.md:32) |
| A02 | [resolve_docs_route.py:244](/Users/Artem/.zenflow/worktrees/knowledge-base-next/scripts/resolve_docs_route.py:244) |
| A03 | [SKILL.md:3](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/.codex/skills/ios-api-contracts/SKILL.md:3) |
| A04 | [SKILL.md:12](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/local-ios-skills/ios-performance-profiler/SKILL.md:12) |
| A05 | [check_documentation_boundaries.py:11](/Users/Artem/.zenflow/worktrees/knowledge-base-next/scripts/check_documentation_boundaries.py:11) |
| A06 | [report_documentation_context_cost.py:38](/Users/Artem/.zenflow/worktrees/knowledge-base-next/scripts/report_documentation_context_cost.py:38) |
| A07 | [IOS_KNOWLEDGE_COVERAGE_REGISTRY.json:8](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/IOS_KNOWLEDGE_COVERAGE_REGISTRY.json:8) |
| A08 | [REUSABLE_BASELINE_POLICY.json:51](/Users/Artem/.zenflow/worktrees/knowledge-base-next/docs/REUSABLE_BASELINE_POLICY.json:51) |
| A09 | [IOS_RELEASE_CHECKLIST.md:68](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/IOS_RELEASE_CHECKLIST.md:68) |
| A10 | [PRODUCTION_REVIEW_COMPLETENESS_GATE.md:12](/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md:12) |

A03 all28 affected paths and hashes: drift-dispositions.json. A10 five-file addition is4,922 regex words /38,819 bytes for each of nine review recipes. Bounded corrected twelve-scenario median is21674.0 words; this is not full transitive closure, comparable before/after economy, or token telemetry. Original recipe results remain preserved in cost-current.json.

## Persistence continuation — 2026-10-12

See `persistence-semantic-receipt.md`: all eleven persistence source bodies and 46 units independently assessed; no useful-condition loss found within that bounded set. Aggregate coverage is now 60/1403 bodies READ, 1343 unread, 119 distinct unit dispositions adjudicated. Archive dispositions remain separate from active coverage. This supersedes earlier running coverage counts, not their historical evidence. Full audit remains PARTIAL.

Copy-owner hypothesis (not confirmed finding): COPY-ROUTER-U10 may rely on migration-task-only preservation authority rather than a specific durable reusable deduplication rule. Exact evidence and minimal decision are in project-copy-semantic-receipt.md. Do not infer lost technical content or restore the retired second pass.

## 2026-10-13 governance continuation

Eight compatibility metadata and nine root governance bodies fully read; see compatibility-semantic-receipt.md and root-governance-semantic-receipt.md. Reviewed means adjudicated, not necessarily supported: LIB-0855-U12 remains UNVERIFIED_OWNER_SCOPE alongside COPY-ROUTER-U10; LIB-0863-U01 has an exact mapping gap for nested-boundary/input-envelope clauses. LIB-0006-U01 and LIB-0859-U01 need more precise existing-owner citations. No active KB change. Current totals are authoritative in coverage.json.

Architecture family completed with bounded static preservation support: architecture-semantic-receipt.md. Current coverage counters include nine selected root governance bodies; unresolved subclaims remain listed in coverage.json.

Accessibility/localization family completed: inclusive-ui-semantic-receipt.md. Historical actual VoiceOver prerequisite is archived under explicit current user exclusion; implementation semantics remain active, and static inspection never supplies that omitted runtime proof.

### A11 — P3 / high: AI coverage points to priority-list items instead of the supporting section

Evidence: worktree `.zenflow/tasks/kb-unification-2026-10-09/migration-ledger.json:32879`,
LIB-0181-U04, both destination_heading and coverage_locations.headings. The meaning is
“Deterministic/specialized framework first for actual user need”, but the cited locations
are §0 and numbered priority items “1. системные и developer-инструкции…” and
“3. AGENTS.md…”. The supporting text is actually canonical
`reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md:60` (§1 ОСНОВНАЯ ЦЕЛЬ), especially
lines 81–85. Thus the content is preserved, but the exact evidence pointer is wrong.
A consumer following only the stated anchor cannot substantiate the claim. Confidence
high from direct text comparison; no inference of lost AI guidance or runtime defect.
Minimal fix: replace the unit's evidence headings with the exact stable §1 section and
qualify its source-bound claim; check nearby priority-item citations individually.
Do not add duplicate guidance. No validator failure/catch behavior was executed for this
case, and an existing-heading/text-presence PASS would not establish semantic support.

All remaining thirteen curated route bodies now read/adjudicated: curated-routes-semantic-receipt.md.
Their linked original/deep source bodies remain independently unverified.

Swift language/runtime family completed: swift-runtime-semantic-receipt.md, plus curated LIB-0015 receipt. This preserves normative constraints but does not close A01 or establish current compiler/ABI/performance correctness.

## Review/refactoring continuation — 2026-10-13

Ten full sources LIB-0226–LIB-0235 and 30 dispositions reviewed; see review-refactoring-semantic-receipt.md. Occurrence-likelihood subclaim in LIB-0227-U01 remains UNVERIFIED, distinct from confidence. Current authoritative totals are coverage.json; active KB unchanged.

## Migration/legacy continuation — 2026-10-13

Eight full sources LIB-0236–LIB-0243 and 24 dispositions reviewed; see migration-legacy-semantic-receipt.md. No new confirmed semantic loss in these sources. Historical test/mode commands do not restore authority.

## Navigation continuation — 2026-10-13

Six full bodies LIB-0086–LIB-0091, 18 dispositions; navigation-semantic-receipt.md records actual owners and a deferred-link/account-switch negative-control specification. Nothing executed.

## Protection-policy continuation — 2026-10-13

Eleven historical policy bodies, 22 dispositions compared in protection-semantic-receipt.md. LIB-1102-U01 nested read-universe subclaim remains UNVERIFIED, separate from clearly preserved mutation boundaries. No historical tooling activated.

## A12 — overlapping severity definitions can change the blocking decision

Severity: P2. Confidence: high for textual overlap; medium for operational harm. Status: OPEN, static evidence; no observed wrong PR decision.

Exact current owners:
- `V/reusable/baseline/docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md:189`, Severity Policy: line 192 includes “naming confusion” among P2; line 193 includes “naming consistency” among P3, without a concrete impact criterion separating them.
- `V/reusable/baseline/docs/IOS_PRODUCTION_AUDIT_MATRIX.md:6`, Severity: lines 9–10 place incorrect patterns before affected expansion at P2 and cleanup/consistency/docs/maintainability at P3.
- `V/reusable/baseline/docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md:53`, Authority, Verdict, And Readiness Contract: severity must use audit-matrix definitions. Lines 61–63 prevent unresolved blocking findings from normal PASS.
- `V/reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md:221` blocks commit/push for P0–P2.

Failure scenario: an otherwise correct internal name is inconsistent but does not change runtime behavior or consumers. A checklist reader can classify it P2 “naming confusion,” while the matrix and checklist P3 wording allow P3 consistency. The gate then either blocks publication or permits explicit reporting, based on which overlapping taxonomy is used. A behaviorally misleading name may genuinely warrant P2; the defect is missing impact discrimination and duplicated normative classification, not a claim that naming is always cosmetic.

Minimal fix: keep severity definitions in the audit matrix referenced by QC governance. Replace checklist's independent taxonomy with that reference and bounded examples distinguishing demonstrated correctness/ownership risk from cosmetic consistency. Do not silently relax real P0–P2 findings or promote all maintainability work to blockers. Preserve confidence/applicability/evidence as separate axes.

Permitted validation: read the three owners and affected gate claims; manually adjudicate a cosmetic naming case and a name/contract mismatch with a concrete wrong caller. A future executable fixture requires explicit test scope. No build/runtime required. This inconsistency does not establish an observed unsafe merge.

## Source-meta continuation — 2026-10-13

Fourteen full bodies and 28 dispositions inspected; source-meta-semantic-receipt.md retains qualifications for generated-output policy and style-only findings. New confirmed active severity overlap is A12, distinct from source-preservation hypotheses.

## Source-meta completed reading — 2026-10-14

All 23 source-meta bodies fully read; 46 dispositions inspected with explicit qualifications. Historical technical catalogs remain unverified as current advice and not active coverage. See source-meta-semantic-receipt.md.

## Prompt packs — 2026-10-14

All 32 legacy prompts fully read, 98 dispositions compared in prompt-pack-semantic-receipt.md. Their generic implement/test imperative is retired delivery, not permission restored by a review request. Existing findings remain open.

## Two owner qualifications resolved — 2026-10-14

LIB-0227-U01 likelihood is supported by Production Quality Gates Severity Classification; LIB-1063-U01 generator-only correction is explicit in Xcode Build Targets And Build Phases. Both require citation precision rather than new KB content. Earlier uncertainty notes are superseded; exact owners are in coverage.json resolved_unit_qualifications. A12 remains: Quality Gates also directs ordinary cleanup to P3.

Navigation deep continuation: LIB-0439–0444, six full bodies / 24 units (18 active + 6 archive), recorded in navigation-deep-semantic-receipt.md. AI trigger qualifications retained for 0440-U02/0442-U02. Navigation block complete; networking continuation below.

Networking deep continuation: LIB-0445,0447–0454, nine full bodies / 36 units (27 active + 9 archive), in networking-deep-semantic-receipt.md. 0445-U02 AI trigger and 0448-U02 prefetch citation qualified. Networking block complete; persistence continuation below.

Persistence deep subset: LIB-0455–0458, four full bodies / 16 units (12 active + 4 archive), in persistence-deep-semantic-receipt.md. AI trigger (0455/0457-U02), cache citation and conditional schema-to-domain seam (all four U03) qualified. Continuation LIB-0460–0464 complete (20 units); LIB-0459 already recorded. Testing continuation LIB-0465–0478 recorded in testing-deep-semantic-receipt.md (56 units), including AI-trigger/prefetch qualifications. Performance deep LIB-0479–0490 recorded in performance-deep-semantic-receipt.md (48 units). Security deep LIB-0491–0502 recorded in security-deep-semantic-receipt.md (48 units). Accessibility deep LIB-0503–0510 recorded in accessibility-deep-semantic-receipt.md (32 units). Platform deep LIB-0511–0524 recorded in platform-deep-semantic-receipt.md (56 units). Next unread deep source LIB-0525.
