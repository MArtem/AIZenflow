# Scoped proposed correction — PILOT-FIX01

Status: READY_FOR_USER_REVIEW of the proposed diff under the explicit task contract. Evidence E1 only; source remains untouched. This is not a production, SDK, compiler, or runtime safety claim.

## Exact boundary and provenance

Read only own task instructions/input, canonical bootstrap/baseline instructions and approved normative documents, own frozen payload, and the two named exact Firefox Git blobs at `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071`. Both blob SHA-1 identities, SHA-256 hashes and byte counts match input.json. Every approved normative and payload hash also matches. Hash-only payload reads were integrity validation, not thematic coverage.

Actual project mode was neither inspected nor changed. Task-only explicit Library ON selection governs the supplied payload. Canonical availability is observed; canonical Git revision, host/configuration, selector verification and usage remain UNKNOWN because those inspections are outside the envelope. The declared executor route is GPT-6.1 Sol/medium, эконом.

## Contract and source-first trace

The task supplies one start per object and serialized, nonreentrant start/stop/callback ordering. It supplies the adversarial generic-error-after-stop scenario. These are authoritative local assumptions, not claims established for WebKit or the SDK.

Observed before specialist module consultation:

- ReaderModeSchemeHandler lines 90–114 creates and stores an owned Task; defer clears its dictionary entry (94).
- Lines 117–120 cancel that Task and remove its entry on stop.
- Lines 99–100 await route and check cancellation on the successful return path.
- Lines 103–106 suppress callbacks and debug-log CancellationError.
- Lines 107–111 unconditionally map and publish a generic error, then warning-log it.
- Lines 124–130 validate the reply then emit response, body and finish synchronously.
- PageRoute lines 35 and 38–42 validate the article URL, await extraction/rendering, and convert many errors into an error-page reply; lines 124–137 can throw while building that reply. This does not establish TinyRouter's implementation or downstream screen behavior.

P2 within the task-defined behavior contract: if route suspends, stop cancels the stored Task, and route later throws a generic error, the post-await check is bypassed and the original generic catch publishes didFailWithError after stop. The severity denotes a proven violation of this supplied callback contract; crash/visual impact in an actual browser is UNKNOWN.

## Proposed minimal correction

One guard at the generic catch boundary uses the executing Task's cancellation flag. A canceled generic completion reuses the existing cancellation debug message and returns. A live genuine error retains the exact existing mapping, callback and warning logger. The cancellation log is retained rather than introducing a silent canceled branch. No API, actor/isolation, state container, route or identity change is proposed.

The only changed artifact is a six-line insertion in ReaderModeSchemeHandler.swift, carried in proposal.patch; the original file is not changed.

## Before/after contract review

| Scenario | Proposed behavior and evidence |
| --- | --- |
| stop while route suspended; later generic error | stop sets cancellation on this Task; generic guard observes it; debug log then return; no terminal callback. Static reasoning under supplied ordering. |
| genuine current generic error | cancellation false; same mapped didFailWithError and warning log as original. |
| current validate/send failure | same generic catch with false cancellation; same mapping/logging. |
| success before stop | existing post-await cancellation check and synchronous response/body/finish remain byte-identical. |
| success returned after stop | existing check throws CancellationError; existing catch remains byte-identical. |
| CancellationError | existing debug log, no callback, and defer unchanged. |
| canceled generic early return | defer still removes dictionary entry. |

No await occurs between the new guard and existing callback. The serialized nonreentrant contract prevents stop from interleaving in that interval. One-start excludes task replacement and an old defer removing a newer task; no demonstrated identity requirement exists here. Removing either assumption invalidates this proof and requires separately scoped ownership/order analysis.

## Reference check and final adjudication

Docs route: canonical Level 0 + preflight/change contract + bounded iOS review/concurrency + completion. Own payload router was consulted after named source facts were inspected, before the decision. ON baseline, evidence/facts/inspection/risk/review guides and precisely two specialist routes (code review and concurrency) were semantically read. The concurrency route reinforced the distinction between cancellation and thrown error type and the need to gate generic failure publication. The review route confirmed reachability against the explicit supplied scenario. Zero new independent findings; the local P2 was confirmed and addressed in the candidate. Advice requiring unavailable SDK/profile, callers, tests or runtime evidence remains UNKNOWN, not PASS. Excluded deeper canonical Library, linked task evidence and unapproved normative references were not followed.

Full candidate diff reviewed once against behavior, authority, producer/consumer, state/time, input/resource and failure rows: six added lines only; current failure observability retained; cancellation reporting preserved; success and CancellationError paths unchanged; no false success introduced. No unresolved P0–P2 is known within this supplied contract. Production-wide coverage is not claimed.

## Verification and limits

Checks run: exact named source SHA-1/SHA-256/size validation, all supplied payload/normative SHA-256 validation, exact single-anchor check, full proposed-diff review and static trace of all named branches. No patch application or Git mutation occurred. Build, tests, typecheck, runtime, network, MCP, independent reviewer and broader call-site/SDK inspection were prohibited and not run. iPad, physical-device and actual VoiceOver checks are OMITTED_BY_USER. UI/render/identity/persistence/migration/security/release broad gates are outside this diff; browser-facing consequences and toolchain isolation remain UNVERIFIED. Static reasoning does not prove general race freedom.

No durable rules or source documents were changed. Only review.md, ledger.json and proposal.patch are output. Plan/handoff edits and exact-HEAD/remote receipts are outside authority. No new local exception is created; the task-defined ordering assumptions and explicit read/write/runtime limits are the scoped override. Context health: контекст обновлять не нужно. Token/subscription usage UNKNOWN.

Handoff: перечитать весь актуальный набор документации и правил для этого worktree и task-контекста.
