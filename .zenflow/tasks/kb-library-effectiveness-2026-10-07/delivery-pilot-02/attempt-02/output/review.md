# PILOT-FIX01 — proposed diff only

Status: READY_FOR_USER_REVIEW for the bounded E1 proposal; original source is unchanged. No SDK/runtime safety or PR/production-readiness claim.

## Scope and authority

Exact Firefox commit `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071`: inspected only ReaderModeSchemeHandler.swift and PageRoute.swift named by input.json. All two blob IDs, SHA-256 values and byte counts match. All 12 normative KB hashes and all 35 frozen payload hashes match. Hash-only reads of unselected payloads did not activate those routes.

Human/task contract is the sole product override: one start per scheme-task object; serialized, nonreentrant start/stop/callbacks; stop cancels the stored Task during suspended routing; the router can later throw a generic error. No repeated/replacement start or interleaving callback is assumed. Actual project Library mode was neither inspected nor modified; task-only frozen payload ON selection applies here.

## Source facts before reference selection

ReaderModeSchemeHandler stores an unstructured Task by ObjectIdentifier. stop cancels the handle then removes it. Task closure retains self and urlSchemeTask across awaited router.route; defer removes that invocation's entry. Successful route return is followed by Task.checkCancellation before synchronous send(response/body/finish). CancellationError logs debug and publishes no WebKit callback. Generic catch currently maps and publishes the error and logs warning unconditionally.

PageRoute.handle catches errors in acquisition/rendering and may build an error reply; extractArticleURL is before that catch, and error-reply construction can itself throw. TinyRouter implementation is excluded, so its concrete error transport and producer lifetime remain UNKNOWN. The input contract explicitly supplies the adversarial generic throw regardless of PageRoute reachability. No current-screen crash or specific UI effect is inferred.

Source facts were traced before KNOWLEDGE_ROUTER and CXL-01 selection. Docs route: canonical Level 0 + preflight/engineering contract + bounded review/concurrency + completion; payload router + quality/evidence/facts/inspection/risk/review + review and concurrency supporting routes. CXL-01 full example was read because the task requests a proposed implementation, but its replacement identity example was not copied.

## Change contract and proposal

Behavior: stop revokes terminal publication; current genuine errors preserve existing mapping, failure callback, and warning logging; success and CancellationError remain equivalent. Authority: only input task contract; no upstream comment authorizes wider work. Producer/consumer: route may ignore cancellation; WebKit terminal callback must be guarded by Task cancellation state. State/time: no suspension or reentrancy between guard and callback under the explicit contract. Input: success, CancellationError, generic errors. Resource: 600-second executor envelope; no resource architecture change. Failure: cancellation remains silent to WebKit; genuine error remains observable. Affected surface: generic catch in one private implementation; no API, target, asset, schema or isolation change.

proposal.patch inserts only `guard !Task.isCancelled else { return }` before didFailWithError in generic catch. This selects cancellation state as the existing authoritative revocation signal. No generation/token is needed because the contract excludes a replacement start for the same object; existing defer cannot clear a replacement handle in that envelope.

## Before/after contract traces

| Scenario | Before | Proposed outcome |
| --- | --- | --- |
| start → route suspends → stop cancels/removes → route throws generic error | failure callback and warning despite stop | guard returns; defer cleanup; no terminal callback |
| start → current genuine generic error without stop | mapped callback and warning | identical mapped callback and warning |
| current route success | cancellation check then response/body/finish | unchanged |
| stop → route returns successfully | cancellation check throws; debug log, no send | unchanged |
| route throws CancellationError | debug log, no terminal callback | unchanged |
| stop before Task starts running | existing initial cancellation check after validation; generic validation error previously could publish | generic catch now also rejects cancelled publication |

The guard does not throw inside catch (which could change Task<Void, Never> compatibility). It returns through defer. It does not claim to stop producer work or undo effects. A generic error after cancellation is not misreported as a current genuine failure. The contract does not require logging such obsolete generic errors; the existing CancellationError logger remains unchanged.

## Final complete-diff review and evidence

E1 static reasoning reviewed the whole one-line proposal against all contract rows after generation. Patch generation used the exact hashed blob, checked unique replacement location, one added line only and no added trailing whitespace. No patch application was performed. Findings: one supported P2 contract violation in the original generic catch, addressed by the proposal under the explicit envelope. No additional blocking finding in this proposal under that envelope. Original repository remains unfixed until separately authorized application.

CXL-01 reference check agrees that cancellation must guard generic-error publication and that proven serialized intake can avoid new identity machinery. Its lifetime/resource caveat remains: cancellation-ignoring routing may retain the task, handler and scheme task indefinitely; producer cooperation/resource bounds are UNKNOWN, outside this fix. No isolation guarantees are inferred from source comments describing SDK annotations.

Review domains: concurrency/cancellation/error mapping/cleanup CHECKED within the contract. UI rendering/state invalidation/data identity/persistence/network transport/security/accessibility/localization/navigation/build graph/release NOT_APPLICABLE to the one-line change; their full app behavior is not reviewed. Observability CHECKED only for preserved current-error and CancellationError logs.

Builds, tests, typecheck, runtime, Simulator, diagnostics, network, MCP, independent agents, Git mutations, original-source changes and actual project mode actions were not performed and are prohibited by this task. iPad/physical-device/actual VoiceOver verification is OMITTED_BY_USER, never PASS. Compile/SDK callback behavior and real serialization/nonreentrancy are UNVERIFIED. Smallest later evidence, only under separate authorization: actual-handler controlled suspension with stop then generic throw, plus current generic-error, success and CancellationError scenarios and declared toolchain compilation. No such checks are requested or executed in this pilot.

Only own output review.md, ledger.json and proposal.patch were written. Durable docs, original plan and source were not changed; exact-SHA/commit/push receipt is NOT_APPLICABLE. Canonical instructions were available; canonical Git revision and host/CODEX_HOME facts were not read under the narrow envelope and remain UNKNOWN. Model: GPT-6.1 Sol / medium, эконом. Context health: контекст обновлять не нужно. Usage: UNKNOWN.

Handoff rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста** within the next authorized envelope.
