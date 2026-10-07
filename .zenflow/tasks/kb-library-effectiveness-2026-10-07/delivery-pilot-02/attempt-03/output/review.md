# PILOT-SUCCESS01 scoped review

Decision: **NO_FINDING_IN_SCOPED_SUCCESS_PUBLICATION**. A stopped request cannot reach `send` under the supplied ordering and nonreentrancy assumptions. No patch is required because the guard already exists. This is an E1 static conclusion, not runtime verification or production readiness.

## Exact scope and provenance

Reviewed only `firefox-ios/Client/Frontend/Reader/SchemeHandler/ReaderModeSchemeHandler.swift` from commit `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071` using `git show commit:path`. Source: 6,419 bytes, Git blob `8fab2c542d171c9617f91cc2676a0d3d77dfc4f1`, SHA-256 `8ef21596b5fe87c01381df7e46d867ca41ecf21cd343f655760b99e6c08765cc`; all match the envelope. No current checkout source was read.

Contract: one start, one optional stop cancelling during the route await, a successful valid HTTP reply, cancellation before the post-await check, and nonreentrant callbacks. Normal current success must publish response, body and finish. Generic error publication and callback reentrancy are excluded.

## Source facts and reasoning

- The request task is retained in `requestTasks` at lines 93–114.
- `stop` cancels that task and clears the stored handle at lines 117–120. Clearing the handle does not reset the task's cancellation state.
- Successful `router.route(url)` awaits at line 99; line 100 immediately performs `try Task.checkCancellation()`.
- If cancellation occurred during the await, that check throws `CancellationError`. The dedicated catch at lines 103–106 logs and performs no scheme-task callback. Consequently line 102 is not reached.
- If the request remains current and uncancelled, line 102 synchronously calls `send`. There is no suspension between the check and publication. Under the stipulated nonreentrant callbacks, no stop interleaves with response/body/finish at lines 128–130. A valid HTTP reply yields those three callbacks in order.

The cancellation flag, rather than mere dictionary removal or a request ID, is the relevant enforcement. Cooperative cancellation alone would not prove publication suppression; the existing post-await check supplies it for this success path.

## Local-first reference result

Source facts were recorded before loading the frozen knowledge router and before the final decision. The task explicitly selects supplied Library ON only; actual project mode was neither looked up nor changed. Applied frozen `KNOWLEDGE_ROUTER.md`, common mode/quality/evidence/facts/inspection/risk/review documents, then exactly two specialist routes: code review and concurrency. Every selected payload hash matches input.json.

The second layer challenged cancellation ownership, suspension ordering, stale publication and reachability. It confirmed the present post-await guard. New findings: 0. Rejected candidate: a missing success cancellation guard is contradicted by line 100. Request replacement/operation-identity cases are outside the one-start envelope and were not elevated into findings.

## Coverage and limits

| Area | Result |
| --- | --- |
| Success publication, owner/cancellation and ordering | CHECKED, E1, under explicit contract |
| Response/body/finish and cancellation logging | CHECKED in exact file |
| Generic route failures, reentrant callbacks, replacement starts | EXCLUDED_BY_SCOPE; no conclusion |
| UI layout/render/state, persistence, broader networking, privacy, localization, release | NOT_APPLICABLE to this bounded publication question; broader app coverage not claimed |
| Toolchain, target membership, actual SDK isolation, router internals, screen consequences | UNKNOWN; not inspected |
| Build/tests/typecheck/runtime | NOT_RUN_BY_SCOPE; no E2–E5 claim |
| iPad/physical device/actual VoiceOver | OMITTED_BY_USER |

Canonical bootstrap and Level0 were available; selected canonical normative hashes match the frozen expected identities. Linked deep references and broad production prompts/checklists absent from the approved KB list were not followed. Their coverage remains unknown rather than silently passed. Canonical revision and host/config facts are UNKNOWN because those inspections were outside scope. No parent task, oracle, curator, other attempt, original Library, installed handler, network or MCP was read or invoked.

Only this attempt's `output/review.md` and `output/ledger.json` were written. Source/payload, tests, plans and Git state were not mutated. No durable shared documentation change or exact-HEAD/push receipt is applicable. Model: GPT-6.1 Sol/medium, эконом. Context health: контекст обновлять не нужно. Usage: UNKNOWN. Static scope completed; broader production readiness remains unverified.
