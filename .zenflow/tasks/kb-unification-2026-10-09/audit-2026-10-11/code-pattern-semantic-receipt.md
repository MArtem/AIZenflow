# Code-pattern disposition review

2026-10-12. All 31 source bodies (index plus 30 patterns) were read in full. Current owner documents were read in full in the domain/startup review. This receipt assesses preservation of constraints and the rationale for archived examples; it does not establish equal instructional effectiveness after removing executable-looking examples from active delivery. No snippet was compiled or run.

| Source | Units | Current owner / anchors | Independent result |
|---|---|---|---|
| LIB-0776 / CODE_PATTERN_INDEX | U01, U02 | `reusable/baseline/docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` — Invariants Before Style; How To Use | Constraints retained; see qualifications below. |
| LIB-0777 / CP-01_ACTOR_OWNED_STATE | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Core Model; Isolation Design | Constraints retained; see qualifications below. |
| LIB-0778 / CP-02_ACTOR_REENTRANCY_STATE_MACHINE | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Isolation Design; Ordering And Stale Results | Constraints retained; see qualifications below. |
| LIB-0779 / CP-03_TASK_LIFETIME | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Task Ownership; Cancellation; Ordering And Stale Results | Constraints retained; see qualifications below. |
| LIB-0780 / CP-04_CANCELLATION_PROPAGATION | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Cancellation | Constraints retained; see qualifications below. |
| LIB-0781 / CP-05_SINGLE_FLIGHT_REFRESH | U01, U02 | `reusable/knowledge-global/ios/IDENTITY_AUTHENTICATION_AND_APP_SECURITY.md` — Session Lifecycle | Constraints retained; see qualifications below. |
| LIB-0782 / CP-06_CONTINUATION_BRIDGE | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Continuations And Callbacks; Task Ownership; Cancellation | Constraints retained; see qualifications below. |
| LIB-0783 / CP-07_ASYNCSTREAM_TERMINATION | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Streams; Continuations And Callbacks; Task Ownership; Cancellation | Constraints retained; see qualifications below. |
| LIB-0784 / CP-08_OBSERVATION_OWNERSHIP | U01, U02 | `reusable/knowledge-global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md` — UI Runtime Model; State Placement; Invalidation And Preview Evidence | Constraints retained; see qualifications below. |
| LIB-0785 / CP-09_DERIVED_STATE | U01, U02 | `reusable/baseline/docs/IOS_UI_STATE_RENDERING_STANDARD.md` — Required Rules | Constraints retained; see qualifications below. |
| LIB-0786 / CP-10_TYPED_PRESENTATION_STATE | U01, U02 | `reusable/knowledge-global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md` — Navigation And Presentation; Identity And Collections | Constraints retained; see qualifications below. |
| LIB-0787 / CP-11_STALE_RESULT_PROTECTION | U01, U02 | `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md` — Cancellation; Ordering And Stale Results; Task Ownership | Constraints retained; see qualifications below. |
| LIB-0788 / CP-12_TYPED_ENDPOINT | U01, U02 | `reusable/knowledge-global/ios/NETWORKING_WEB_AND_REALTIME_SYSTEMS.md` — Boundary Model; Request Contract; Reliability | Constraints retained; see qualifications below. |
| LIB-0789 / CP-13_IDEMPOTENT_RETRY | U01 | `reusable/knowledge-global/ios/NETWORKING_WEB_AND_REALTIME_SYSTEMS.md` — Reliability | Constraints retained; see qualifications below. |
| LIB-0790 / CP-14_DEEPLINK_PARSER | U01, U02 | `reusable/knowledge-global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md` — Navigation And Presentation | Constraints retained; see qualifications below. |
| LIB-0791 / CP-15_INITIALIZER_DI | U01, U02 | `reusable/baseline/docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` — Invariants Before Style; Architecture Detection And Review Gates | Constraints retained; see qualifications below. |
| LIB-0792 / CP-16_TYPED_FEATURE_FLAG | U01, U02 | `reusable/baseline/docs/FEATURE_FLAGS_AND_ROLLOUTS.md` — Required Checks; Forbidden By Default; Release Evidence | Constraints retained; see qualifications below. |
| LIB-0793 / CP-17_SWIFT_TESTING_PARAMETERIZED | U01, U02 | `reusable/knowledge-global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md` — Swift Testing And XCTest; Determinism; Evidence Completion | Constraints retained; see qualifications below. |
| LIB-0794 / CP-18_TEST_ERROR_PATH | U01, U02 | `reusable/knowledge-global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md` — Evidence Model; Test Portfolio; Test Doubles; Evidence Completion | Constraints retained; see qualifications below. |
| LIB-0795 / CP-19_WEAK_DELEGATE | U01, U02 | `reusable/knowledge-global/ios/SWIFT_LANGUAGE_RUNTIME_AND_API_DESIGN.md` — Ownership And Memory; Interoperability | Constraints retained; see qualifications below. |
| LIB-0796 / CP-20_UIKIT_REUSE_TASK | U01, U02 | `reusable/knowledge-global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md` — UIKit Lifecycle And Reuse Review; Identity And Collections | Constraints retained; see qualifications below. |
| LIB-0797 / CP-21_OSLOG_PRIVACY | U01, U02 | `reusable/knowledge-global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` — Observability | Constraints retained; see qualifications below. |
| LIB-0798 / CP-22_SIGNPOST_INTERVAL | U01, U02 | `reusable/knowledge-global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` — Measure From User Impact; Optimization Workflow; Observability; Metric Design; Evidence | Constraints retained; see qualifications below. |
| LIB-0799 / CP-23_STATE_MACHINE | U01, U02 | `reusable/baseline/docs/IOS_UI_STATE_RENDERING_STANDARD.md` — Stateful Screen State Contract; Required Rules | Constraints retained; see qualifications below. |
| LIB-0800 / CP-24_ERROR_MAPPING | U01, U02 | `reusable/baseline/docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md` — Required Rules; Review Checklist | Constraints retained; see qualifications below. |
| LIB-0801 / CP-25_BOUNDED_CACHE | U01 | `reusable/knowledge-global/ios/PERSISTENCE_DATA_AND_CLOUDKIT.md` — Preferences And Derived Caches | Constraints retained; see qualifications below. |
| LIB-0802 / CP-26_STORE_MIGRATION_INVARIANT | U01 | `reusable/knowledge-global/ios/PERSISTENCE_DATA_AND_CLOUDKIT.md` — Migration; Evidence | Constraints retained; see qualifications below. |
| LIB-0803 / CP-27_PRIVACY_MANIFEST_REVIEW | U01, U02 | `reusable/knowledge-global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md` — Privacy Manifest And Required-Reason APIs; Privacy Labels And Data Lifecycle; SDK And Supply-Chain Review; Release Evidence; Living Requirements | Constraints retained; see qualifications below. |
| LIB-0804 / CP-28_MODEL_OUTPUT_VALIDATION | U01 | `reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md` — 37. STRUCTURED OUTPUT; 35. TOOL CALLING; 44. SECURITY; 53. ERROR MODEL; 55. FALLBACK | Constraints retained; see qualifications below. |
| LIB-0805 / CP-29_TOOL_CALL_AUTHORIZATION | U01 | `reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md` — 35. TOOL CALLING; 41. PRIVACY; 44. SECURITY; 89. USER CONFIRMATION | Constraints retained; see qualifications below. |
| LIB-0806 / CP-30_MINIMAL_REFACTOR | U01, U02 | `reusable/baseline/docs/ARCHITECTURE_DECISION_GOVERNANCE.md` — Bounded Investigation And Migration | Constraints retained; see qualifications below. |

## Qualifications

- The 30 examples do not establish 30 independently compiled implementations. Undefined project types and minimal snippets remain illustrative. Current architecture selection, dependency ownership, deployment profile and permission boundaries still apply.
- CP-03 preserves the distinctive independent dependency capture across suspension, owner retention caveat, post-await cancellation and stale generic-error guard. Cancellation and generation are separate conditions; deinit cancellation cannot rescue a task that retains its owner.
- CP-05 is not a complete authentication session: logout versus refresh, waiter cancellation, persistence and replay are explicitly required outside the snippet. Current Session Lifecycle retains these conditions. The archive actor sketch must not become a production-readiness oracle.
- CP-06 only works under the explicitly proven exactly-once/all-terminal callback contract; checked continuation alone does not implement cancellation or repair duplicate/missing completion. CP-07 is not a proof of safe registration/termination races or bounded buffering. Current continuation/stream guidance retains these limitations.
- CP-20 illustrates reuse-bound cancellation but leaves loader/UI isolation to actual types and does not establish all failure/loading presentation semantics. Current UIKit lifecycle/reuse and concurrency guidance must govern adaptation.
- CP-13/25/26/28/29 are constraints rather than complete implementations; their active mappings retain retry semantics, bounded cache ownership, migration invariants, untrusted output and current tool authorization. No tool invocation or test phase follows from the text.
- Numeric/source catalog preservation and historical labels are provenance only. The CP-03 index title variation is not a distinct missing contract.
- ARCHIVE_ONLY_NO_INCREMENTAL_VALUE is supported here only in the sense of no additional operating requirement beyond mapped constraints. Whether showing a corrected example improves resulting code or reduces task tokens is UNVERIFIED. The migration receipts do not measure pedagogical equivalence. This is a quality-evaluation hypothesis, not demonstrated semantic loss.
- Historical fixed verification sequences in CP-27/30 are archived; permitted evidence requirements remain active. Archive disposition is not active reviewed coverage and restores no execution permission.

## Proposed bounded quality comparison

If separately authorized, compare constraint-only delivery with the same constraints plus one corrected, explicitly bounded example on fresh non-sealed tasks. Include a synchronous negative control where task/generation machinery is unnecessary, a cancellation-ignoring dependency that returns success, generic error after cancellation, and logout during refresh. Grade ownership, terminal paths, publication authority, unnecessary mechanisms and explanation of omitted evidence independently of code size. Record actual input/output/cache/reasoning tokens where available. Do not reuse U7, the closed experiment or sealed oracle, and do not infer superiority before observation.
