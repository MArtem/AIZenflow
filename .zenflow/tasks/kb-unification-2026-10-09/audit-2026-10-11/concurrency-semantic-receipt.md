# Concurrency source-to-owner review

2026-10-12. All 16 source bodies LIB-0030–LIB-0045 fully read; all current units independently compared with full current owner documents. This extends the earlier CXL/task-lifetime/cancellation review without double-counting it. No app source, compilation, runtime or old execution protocol was activated.

Primary technical owner: `reusable/knowledge-global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md`. Common workflow owner: `reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md`, sections 1–4; permission and actual toolchain remain controlled by the current baseline.

| Source | Useful contract and current anchors |
|---|---|
| LIB-0030 | Task/actor/callback/stream/bridge and evidence boundaries throughout current reference; old separate payload selection archived. |
| LIB-0031 | Invocation Publication Practical Slice, Contract And Mechanism, Illustrative Owner Example, Falsification Traces And Evidence Limits preserve positive/negative trigger, invocation identity, both completion paths, cross-consumer guard, cleanup ownership and actual evidence limits. |
| LIB-0032 | Swift 6.x Discipline + Isolation Design prohibit suppressing ownership defects; A01 remains a separate conflicting skill delivery path. |
| LIB-0033/0034 | Isolation Design, Task Ownership and Swift 6.x Discipline plus Swift language owner Ownership And Memory / Type And API Decisions cover mutable owner, transfer, captures, references, generics and delegates. |
| LIB-0035 | Core Model denies async=background; example explicitly requires expensive work off the UI actor via actual API; Testing And Evidence calls for occupancy/latency evidence rather than gratuitous hops. |
| LIB-0036 | Core Model and Task Ownership retain structured parent lifetime/result/error/cancellation versus deliberate unstructured ownership. |
| LIB-0037/0038 | Task Ownership, Cancellation and Contract And Mechanism retain independent dependency capture, strong-before-await trap, cooperative cancellation, stale generic failure, concurrent cancellation-handler synchronization and retry cancellation exit. |
| LIB-0039/0040 | Streams defines bounded buffering/overflow/fan-out/backpressure and termination; Continuations And Callbacks defines exactly-once including synchronous registration, cancellation/isolation and lifetime. |
| LIB-0041 | Ordering And Stale Results + Isolation Design retain reentrancy and pre/post-suspension invariant revalidation. |
| LIB-0042/0043 | Streams bounds fan-out/backpressure; Core Model conditions priority/executor choices on actual bottleneck; Testing And Evidence requires occupancy/task-growth evidence. A custom executor is not a default fix. |
| LIB-0044 | Reactive And Queue Bridges requires one explicit synchronization model and semantic parity, avoiding duplicate queue/actor synchronization; Swift 6.x Discipline supports bounded incremental migration. |
| LIB-0045 | Combined sections retain race/sendability/actor escape/cancellation/continuation/main-actor review; common change contract retains relevant call-site and failure-path inspection. |

## Disposition and limits

All useful operating requirements in these source bodies have an identified current owner. No additional lost condition found. The mandatory two-alternative numeric quota is separately archived: material alternatives remain conditional under the engineering/architecture contract. Historical V2 modes and mandatory separate playbook loading are not active coverage and restore no authority. Linked deep playbooks have not been read merely because their links appeared here.

Current-source preservation is not sufficient delivery proof: A01 shows that a conflicting specialist skill can still weaken the effective advice even though the canonical deep owner is correct. No universal concurrency correctness is claimed. Static examples remain uncompiled; actual compiler versions, actor-default behavior, producer resource bounds, owner release and cancellation latency require distinct evidence.

Selected negative controls: synchronous work without an outstanding operation; proven serialized single-operation intake; existing correct guard; current genuine error. Positive adversarial cases: cancellation-ignoring success and generic failure; A→B→A; old cleanup while new work remains; cross-actor publication; already committed side effect. The source examples distinguish these cases rather than requiring a generation counter everywhere. These descriptions are not created/executed tests.
