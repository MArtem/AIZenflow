# Bounded source review — H-bb4fd3190170

Model: GPT-6.1 Sol / medium. Mode: эконом. Evidence: E1, inspected exact pinned source. Review complete for the requested contract; persistence decision NOT_READY. No implementation or runtime verification performed.

## Scope and contract

Reviewed exactly commit `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071` in `/Users/Artem/.zenflow/library-acceptance-projects/firefox-ios`, limited to `BrowserKit/Sources/TabDataStore/{TabDataStore.swift,WindowData.swift,TabFileManager.swift}`. All three Git blob IDs, SHA256 digests and byte counts matched the assigned case.

The task explicitly allows one shared store to receive different WindowData IDs during a throttle interval. Every written payload must have the ID encoded in its destination filename. This task contract supplies reachability of the two-ID input; actual Firefox callers, deployment settings, frequency and production exposure remain UNKNOWN. No current worktree source, status, diff, unlisted caller or evaluator material was inspected.

Docs route: current canonical Level 0 + non-trivial review + concurrency + relevant persistence standards; assigned reference entry/quality/evidence/review guide, review/concurrency routes, then data route. Current canonical concurrency addressed sections were read. CXL-01 was not needed: exact source already resolves identity disagreement without an unresolved cancellation mechanism question. No Library activation was performed.

## Finding F1 — P0: throttling writes another window's payload to the first window's path

**Location:** `TabDataStore.swift:155`, `208–223`, `227–235`; path identity at `272–275`. Confidence: high. Applicability: applicable under the explicit two-ID contract. Evidence: fresh E1. Severity describes the reachable data corruption/overwrite consequence under the task contract; current production likelihood is UNKNOWN.

The actor owns one global pending `windowDataToSave` and one global scheduled flag (`41–42`). The scheduled task captures the first call's `path`, but obtains the payload from the mutable global pending value when it eventually writes. The second call replaces that value before the scheduled guard rejects scheduling. Actor serialization protects memory access, but does not keep the captured key and later payload identity together.

**Source-based two-call trace:**

1. Let A and B be distinct UUIDs and construct valid `WindowData(id: A, activeTabId: ..., tabData: [])` and corresponding B using the public initializer (`WindowData.swift:19–24`). Assume a resolvable writable directory, successful JSON encoding/write and a finite positive throttle interval. No simultaneous host threads are required.
2. `await store.saveWindowData(window: AData, forced: false)` computes `window-A` (`146–147`, `272–275`), sets pending=AData (`155`), sets scheduled=true (`210–213`) and creates a task capturing path A (`216`). The task suspends in `Task.sleep` (`218`); the public call returns without waiting for the timer's write.
3. During that sleep, `await store.saveWindowData(window: BData, forced: false)` computes `window-B`, replaces pending with BData (`155`), and reaches the throttle helper. Its guard sees scheduled=true and returns (`210`). No task capturing B's path is scheduled.
4. The first task resumes, clears the flag (`219`) and calls `writeWindowDataToFile(path: window-A)` (`223`). That helper reads pending=BData (`229`) and passes BData plus destination A to the file manager (`235`). `DefaultTabFileManager.writeWindowData` encodes the supplied BData and atomically writes it to the supplied URL without an ID/path check (`TabFileManager.swift:163–165`). Thus destination `window-A` contains JSON with `id == B`. Atomic replacement does not repair wrong identity. If A already existed, its main payload is overwritten; if it did not, the resulting new file still violates the invariant. This trace never writes the new BData to its intended main `window-B` destination.

The same mismatch can affect backup identity in this trace: if `window-A` exists, the backup source is captured A (`220–221`), while the backup destination is derived from pending B (`172–180`, `198`). This is another consequence of the same lost key/payload agreement, not a separate finding. Fetching A also does not reject a decoded B ID (`95–102`), so the inspected reader supplies no identity guard.

**Target state / smallest correction direction:** retain the destination key and payload together across the throttle boundary, with pending/scheduled ownership compatible with the explicit shared multi-ID store contract. Coalescing must not discard a different key or combine one key's path with another key's value. This is a bounded remediation requirement, not an implemented patch or a broader architecture proposal.

**Verification needed if separately authorized:** a deterministic two-ID throttle scenario should inspect writer arguments and assert that every destination filename ID equals its payload ID, with existing-file backup identity included. No fixture, test, runtime filesystem write or timing experiment was created or executed here. The finding is already established by the source trace; actual runtime behavior remains unobserved.

## Coverage and limits

| Area | Result |
| --- | --- |
| Task-defined correctness, identity, state/time ordering | FINDING F1; complete source trace across public producer, pending state, destination and writer |
| Persistence/backup/reader agreement | CHECKED for F1; default writer and reader do not enforce path/payload identity |
| Isolation/task ownership | CHECKED for this trace; actor data-race freedom does not establish key agreement |
| Failure semantics | CHECKED for successful write route; logging/throw catches do not prevent a successful wrong-key write |
| UI/rendering/navigation/accessibility/localization/network | NOT_APPLICABLE to this bounded saving contract; no such source inspected |
| Broader migration, retention, privacy, memory/performance/release | Outside requested scope; no whole-project safety claims |
| Runtime/build/tests/typecheck | NOT_RUN, explicitly prohibited |
| Actual callers/toolchain/deployment/production frequency | UNKNOWN, unlisted sources prohibited |

No clean-control outcome is claimed: this assigned contract has a reachable violation. No additional finding is inferred from absent runtime evidence or hypothetical consumers.

## Completion receipt

Only own `report.md`, `ledger.json`, and `plan.md` changed. Source and Git state were not mutated. Durable reusable/app documentation changes were not requested. Applied QC.CHANGE.CONTRACT, QC.EVIDENCE.FRESHNESS, QC.VERDICT.READINESS and exception constraints; no accepted-risk exception was created or used. Static checks: exact Git blob/SHA256/byte identity and selected current/reference hash comparisons. No build, test, runtime, typecheck, network, MCP, child agent, source status/diff or Git mutation. No release, merge, production readiness, safety or full recall claim. Context health: контекст обновлять не нужно.
