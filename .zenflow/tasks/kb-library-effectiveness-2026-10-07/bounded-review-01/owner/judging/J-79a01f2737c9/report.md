# Bounded source review — H-bb4fd3190170

Model: GPT-6.1 Sol / medium. Mode: эконом. Evidence: E1 static reasoning. Requested review completed; reviewed behavior is NOT_READY under the explicit case contract.

## Scope and contract

Only the three assigned source blobs at commit `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071` were inspected. All blob IDs, SHA256 digests and byte counts match case-input.json. No current source, source status/diff, other callers, parent history, sibling results or oracle were inspected.

Behavior: one shared store accepts distinct WindowData IDs during a finite throttle interval; each written payload ID must equal its destination's window ID. Authority: task-defined contract, not inferred current application usage. Producer/consumer: public WindowData initializer and saveWindowData feed the actor's shared pending value, then TabFileManager serializes it at the supplied URL. Time: A schedules a write; B replaces pending data before that write. Failure semantics: a successful physical write must not silently overwrite a different window's data. No implementation change was requested or made.

Docs route: current canonical Level 0 + bounded iOS review, concurrency and persistence; assigned knowledge entry, quality, evidence, review and supporting routes. CXL-01 review slice only; full example omitted because no implementation or unresolved mechanism question required it. Reference input granted no permissions or Library mode change. Canonical availability confirmed by reads; canonical Git revision UNKNOWN (no extra Git inspection). Selected advice revision: `[REFERENCE_REVISION]`. Full ordered identities and partial-output disclosures are in ledger.json.

## Finding F1 — P0: throttling binds A's destination to B's payload

Location: `BrowserKit/Sources/TabDataStore/TabDataStore.swift:155`, `:208–223`, `:227–235` (at the pinned commit). Confidence high; applicability applicable to the explicit shared-store contract; evidence fresh E1. P0 describes possible destructive data corruption under the canonical impact scale, not an observed production incident. Current product caller frequency and real-world exposure remain UNKNOWN.

Two-call source trace, with A.id != B.id, valid storage URLs and successful serialization/write:

1. Call `await store.saveWindowData(window: A, forced: false)`. Lines 147 and 272–275 derive primary `window-A`; line 155 sets pending data to A. Lines 210–218 set the store-wide scheduling flag and create a task that captures path A and suspends for the throttle interval. The public call returns without waiting for that timer (lines 215–224).
2. Before that interval expires, call `await store.saveWindowData(window: B, forced: false)` on the same store. Line 147 derives path B and line 155 replaces the single pending value with B. The throttle guard at line 210 returns because A's save is already scheduled. No B-specific save is scheduled.
3. A's task resumes. It still carries path A, but line 223 calls writeWindowDataToFile with that path and lines 229–235 load the current shared pending value B. The file manager's lines 163–165 encode B and atomically write those bytes at path A. WindowData.id is a public immutable UUID included in its Codable payload (WindowData.swift:7–24).

Result: destination `window-A` contains payload whose id is B, directly violating the requested invariant. If window-A already held A, its data is replaced by B. Actor isolation prevents unsynchronized memory access but does not keep this captured path and later-selected value associated with the same key. This trace requires two sequential public API calls during suspension, not simultaneous host threads, cancellation, or a speculative UI caller.

Related consequence of the same root cause: if primary path A already exists, lines 220–221 back it up before writing. createWindowDataBackup reads pending B.id at lines 173–180 and copies old primary A to backup path B at line 198; DefaultTabFileManager.copyItem removes an existing destination first (112–115). Thus the backup can also be mislabeled and overwrite B's backup. This is part of F1 rather than a separate finding.

Target state / first remediation: preserve each destination's association with its own pending WindowData, including backup identity, across the throttle delay. Because the explicit contract allows multiple IDs, merely deriving the destination from the latest global value would not establish preservation of independently pending windows. No patch or broader redesign is proposed in this review.

Required future verification, only under separate authorization: use two distinct IDs on one store within the throttle interval, observe write argument/path identity and final persisted IDs, and cover an existing primary and backup. No fixture or executable test was written or run.

## Bounded coverage and limits

| Area | Result |
| --- | --- |
| Public input identity, producer/consumer agreement | CHECKED; F1 |
| Actor state and time ordering | CHECKED; F1; mutable pending value and scheduling flag owned by DefaultTabDataStore |
| Task lifetime/resource scope | CHECKED statically: unstructured task captures store across sleep; one throttled task admitted by flag in this trace; no runtime leak or global resource-bound claim |
| Persistence and backup | CHECKED for the specified two-call route; F1; atomic write does not repair identity mismatch |
| Error semantics | CHECKED: file write errors are logged; mismatch itself causes no error; no wider failure UX claim |
| UI/lazy rendering/navigation/accessibility/localization | NOT_APPLICABLE to this named storage contract; no UI source inspected |
| Network/offline synchronization/media cache | NOT_APPLICABLE to the requested route; no such source inspected |
| Security/privacy/release/toolchain compatibility | UNVERIFIED outside the contract; no host/config/entitlement or consumer inspection authorized |
| Build/tests/typecheck/runtime | NOT_RUN; prohibited by bounded task |
| iPad/physical device/actual VoiceOver verification | OMITTED_BY_USER; never PASS |

No clean-control outcome: F1 is supported under the explicit contract. No claim is made about whole-project safety, production readiness, recall, current source, runtime reproduction, or actual caller frequency. Additional lifecycle/cancellation/delete contracts are outside this review; no extra defect is inferred from them. A successful-source-path finding remains valid even if real storage is unavailable in some runs.

Only this executor's report.md, ledger.json and plan.md changed; no source or durable shared documentation changed. No local exception used. Context health: контекст обновлять не нужно. No independent reviewer or external services used. The bounded evidence is sufficient for this requested verdict; continuation would exceed the named source scope.
