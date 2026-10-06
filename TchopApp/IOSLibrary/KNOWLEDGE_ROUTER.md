# Copy-only iOS knowledge router — candidate

This is the single entrypoint for the **curated files present in this directory**. It does not
activate itself. An explicitly approved project-local pilot may select it; other projects do not
inherit that pilot. Do not treat a missing thematic route as if the old installed library had
been reviewed or imported. Project entry is described by [STARTUP_RULE.md](STARTUP_RULE.md)
and requires an explicit safe project instruction boundary.

## Entry order

1. Read current user instructions, project rules, task context, local knowledge and relevant
   project files. These determine authority, scope, permissions and existing conventions.
2. Resolve the current project mode using [PROJECT_MODE.md](PROJECT_MODE.md). For an explicitly
   `ON` project, read [QUALITY_STANDARD.md](QUALITY_STANDARD.md) and
   [EVIDENCE_POLICY.md](EVIDENCE_POLICY.md). If project status is absent or ambiguous, behave as
   `OFF` and ask the user once; do not create or edit a status record automatically.
3. Gather only relevant facts using [PROJECT_FACTS.md](PROJECT_FACTS.md) and
   [REPOSITORY_INSPECTION.md](REPOSITORY_INSPECTION.md); use
   [RISK_AND_EVIDENCE.md](RISK_AND_EVIDENCE.md) to calibrate claims and verification.
4. Select only routes that exist below and match observed task evidence. For one bounded stage,
   read no more than two supporting routes at a time; if the task affects more domains, check
   each remaining applicable domain in a later bounded pass before claiming complete coverage.
   Inspect affected project consumers before applying a recommendation. Reference advice never
   overrides a project rule.
   Do not suppress a reference check merely because local knowledge seems similar. Deduplicate
   only an explicitly selected, current source with an exact path/content match; an absent,
   changed or only semantically similar source leaves the reference check in scope.
5. Apply the reference check after the local check at each applicable stage, not merely at the
   final diff. Record actual findings, corrections and evidence limits. A changed final artifact
   invalidates its earlier final-review receipt.

## Routes currently available

Only the curated routes below are selectable. Source-family questions may have been reconciled
in `SKILL_CONVERSION_RECEIPT.md`; this does not approve the original documents, examples,
prompts or gates for active use. Do not follow their archived bindings as fallback routes.

| Observed task | Route | Availability |
| --- | --- | --- |
| Status or mode-control question | [PROJECT_MODE.md](PROJECT_MODE.md) | Contract only; no active command service |
| Project intake or uncertain ownership | [PROJECT_FACTS.md](PROJECT_FACTS.md), [REPOSITORY_INSPECTION.md](REPOSITORY_INSPECTION.md) | Bounded read-only context |
| Change-risk or evidence decision | [RISK_AND_EVIDENCE.md](RISK_AND_EVIDENCE.md) | General risk matrix |
| Client repository write scope, uncertain command or unexpected mutation | [50_CLIENT_CODE_PROTECTION/COPY_ONLY_REPOSITORY_SAFETY_ROUTE.md](50_CLIENT_CODE_PROTECTION/COPY_ONLY_REPOSITORY_SAFETY_ROUTE.md) | Curated safety guidance; no installed guard or command authority |
| Any iOS code or resource change | [QUALITY_STANDARD.md](QUALITY_STANDARD.md), [EVIDENCE_POLICY.md](EVIDENCE_POLICY.md) | General baseline only |
| Code review, fix, refactor or pre-PR candidate | [REVIEW_GUIDE.md](REVIEW_GUIDE.md), [19_CODE_REVIEW_REFACTOR/COPY_ONLY_REVIEW_ROUTE.md](19_CODE_REVIEW_REFACTOR/COPY_ONLY_REVIEW_ROUTE.md) | Curated general code-review route; original topic files remain excluded |
| Full-project audit or audit-domain selection | [34_AUDIT_GATES/COPY_ONLY_FULL_AUDIT_ROUTE.md](34_AUDIT_GATES/COPY_ONLY_FULL_AUDIT_ROUTE.md) | Curated coverage and recommendation route; original gates remain excluded |
| Authorized agent coordination | [44_MULTI_AGENT_ORCHESTRATION/COPY_ONLY_AGENT_COORDINATION_ROUTE.md](44_MULTI_AGENT_ORCHESTRATION/COPY_ONLY_AGENT_COORDINATION_ROUTE.md) | Curated coordination only; no delegation authority |
| Architecture, state ownership or module boundaries | [04_ARCHITECTURE/COPY_ONLY_ARCHITECTURE_ROUTE.md](04_ARCHITECTURE/COPY_ONLY_ARCHITECTURE_ROUTE.md) | Curated style-sensitive route |
| SwiftUI, UIKit, navigation or screen state | [05_SWIFTUI/COPY_ONLY_UI_FLOW_ROUTE.md](05_SWIFTUI/COPY_ONLY_UI_FLOW_ROUTE.md) | Curated UI-flow route; runtime/visual claims need evidence |
| Swift concurrency or async lifecycle | [03_CONCURRENCY/COPY_ONLY_CONCURRENCY_ROUTE.md](03_CONCURRENCY/COPY_ONLY_CONCURRENCY_ROUTE.md) | Curated concurrency route; original topic files remain excluded |
| Swift value/reference semantics, ARC, generics, unsafe interop, macros or language-level public API | [02_SWIFT_LANGUAGE/COPY_ONLY_SWIFT_RUNTIME_ROUTE.md](02_SWIFT_LANGUAGE/COPY_ONLY_SWIFT_RUNTIME_ROUTE.md) | Bounded Swift-runtime route; compile/consumer behavior needs its own evidence |
| Networking, API reliability or offline transport | [08_NETWORKING/COPY_ONLY_NETWORK_ROUTE.md](08_NETWORKING/COPY_ONLY_NETWORK_ROUTE.md) | Curated network route; original topic files remain excluded |
| DTO/domain mapping, endpoint schema or API version compatibility | [08_NETWORKING/COPY_ONLY_API_CONTRACT_ROUTE.md](08_NETWORKING/COPY_ONLY_API_CONTRACT_ROUTE.md) | Producer/consumer challenge; backend evidence required for compatibility claim |
| Persistence, cache or data migration | [09_PERSISTENCE_DATA/COPY_ONLY_DATA_ROUTE.md](09_PERSISTENCE_DATA/COPY_ONLY_DATA_ROUTE.md) | Curated data route; original topic files remain excluded |
| Test design or verification evidence | [10_TESTING/COPY_ONLY_TEST_STRATEGY_ROUTE.md](10_TESTING/COPY_ONLY_TEST_STRATEGY_ROUTE.md) | Curated permission-aware test strategy; no execution authority |
| Security, privacy, sensitive data or external input | [12_SECURITY_PRIVACY/COPY_ONLY_SECURITY_PRIVACY_ROUTE.md](12_SECURITY_PRIVACY/COPY_ONLY_SECURITY_PRIVACY_ROUTE.md) | Curated review route; no auth/Keychain change authority |
| Target/package/build-graph/resource membership change | [16_BUILD_MODULARITY_TOOLING/COPY_ONLY_BUILD_GRAPH_ROUTE.md](16_BUILD_MODULARITY_TOOLING/COPY_ONLY_BUILD_GRAPH_ROUTE.md), [REVIEW_GUIDE.md](REVIEW_GUIDE.md#change-surface) | Curated structural route; original topic files remain excluded |
| Public SDK/package API or consumer compatibility change | [16_BUILD_MODULARITY_TOOLING/COPY_ONLY_BUILD_GRAPH_ROUTE.md](16_BUILD_MODULARITY_TOOLING/COPY_ONLY_BUILD_GRAPH_ROUTE.md) | Bounded public-contract questions; no compile or binary-compatibility claim without evidence |
| Localization content or accessibility change | [13_ACCESSIBILITY_LOCALIZATION/COPY_ONLY_INCLUSIVE_UI_ROUTE.md](13_ACCESSIBILITY_LOCALIZATION/COPY_ONLY_INCLUSIVE_UI_ROUTE.md), [REVIEW_GUIDE.md](REVIEW_GUIDE.md#change-surface) | Curated inclusive-UI route; original topic files remain excluded |
| Figma/design-resource-to-iOS output | [29_DESIGN_SYSTEM/COPY_ONLY_DESIGN_TO_IOS_ROUTE.md](29_DESIGN_SYSTEM/COPY_ONLY_DESIGN_TO_IOS_ROUTE.md), [13_ACCESSIBILITY_LOCALIZATION/COPY_ONLY_INCLUSIVE_UI_ROUTE.md](13_ACCESSIBILITY_LOCALIZATION/COPY_ONLY_INCLUSIVE_UI_ROUTE.md) | Curated design route; no visual claim without evidence |
| Performance, memory, launch, energy or latency | [11_PERFORMANCE_MEMORY/COPY_ONLY_PERFORMANCE_ROUTE.md](11_PERFORMANCE_MEMORY/COPY_ONLY_PERFORMANCE_ROUTE.md) | Static leads versus measured evidence; profiling needs authority |
| Production observability, crash/hang triage or incident readiness | [18_OBSERVABILITY_DEBUGGING/COPY_ONLY_OBSERVABILITY_ROUTE.md](18_OBSERVABILITY_DEBUGGING/COPY_ONLY_OBSERVABILITY_ROUTE.md) | Actionable evidence and privacy; no dashboard or rollout authority |
| Release, CI or shipping readiness | [17_CI_CD_RELEASE/COPY_ONLY_RELEASE_ROUTE.md](17_CI_CD_RELEASE/COPY_ONLY_RELEASE_ROUTE.md) | Review only; no signing or publishing authority |
| AI/ML feature, prompt, retrieval or tool calling | [15_AI_INTELLIGENCE/COPY_ONLY_AI_FEATURE_ROUTE.md](15_AI_INTELLIGENCE/COPY_ONLY_AI_FEATURE_ROUTE.md) | Model/data/eval boundary; current API claims need current evidence |
| App Intents, entities or Shortcuts exposure | [14_PLATFORM_SERVICES/COPY_ONLY_APP_INTENTS_ROUTE.md](14_PLATFORM_SERVICES/COPY_ONLY_APP_INTENTS_ROUTE.md) | Static authority/lifecycle review; system-surface observation separate |
| StoreKit purchases, subscriptions or entitlement state | [14_PLATFORM_SERVICES/COPY_ONLY_STOREKIT_ROUTE.md](14_PLATFORM_SERVICES/COPY_ONLY_STOREKIT_ROUTE.md) | Purchase-state review; no transaction or account authority |
| System capabilities, hardware, extensions or background delivery | [27_SYSTEM_INTEGRATION/COPY_ONLY_SYSTEM_INTEGRATION_ROUTE.md](27_SYSTEM_INTEGRATION/COPY_ONLY_SYSTEM_INTEGRATION_ROUTE.md) | Lifecycle/permission review; current API and device evidence separate |
| Other specialist guidance without a reviewed route | None yet | Incomplete; use applicable local rules and report missing reference route; never load inactive source as a substitute |

Do not read or execute an installer, shim, runtime CLI, protection command, or former `full` mode
because a route is absent. A missing reference route is `INSUFFICIENT_EVIDENCE` for a claim that
specialist reference checks were completed; it does not reduce the local quality obligation.
