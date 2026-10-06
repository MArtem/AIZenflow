# Factual first-read order — ordered-startup-check

All listed shell invocations used `login:false` and completed before the next invocation. No parallel reads. Multiple `cat` operands were consumed in the displayed order. Logical invocation labels are receipt labels; chunk IDs below were actually returned by the terminal tool. Outer function-call IDs were not exposed, so none are invented.

| Invocation | Returned terminal chunk ID | Actual action |
|---|---|---|
| 01 | c2e445 | canonical bootstrap |
| 02 | 54f93e | canonical baseline AGENTS |
| 03 | 7b1380 | full canonical task router |
| 04 | 0242f4 | current root AGENTS and scoped overrides; task-path inventory only |
| 05 | 5d8645 | Level0 CURRENT_USER_OVERRIDES then MODEL_ROUTING_RULE (sequential cat) |
| 06 | a98907 | current canonical plan then handoff |
| 07 | ed2756 | main plan line count only |
| 08 | 8a510b | main plan full range 1-220 /804 |
| 09 | eaecce | main plan full range 221-440 /804 |
| 10 | 26edb2 | main plan full range 441-650 /804 |
| 11 | 31f45e | main plan full range 651-804 /804 |
| 12 | a684cd | actual HEAD/status and selected machine route/optional overlay |
| 13 | 2425f8 | full ios-project-work-system route |
| 14 | 85207f | preflight then complete context-transfer standard |
| 15 | 961275 | evidence then completion then engineering quality standards |
| 16 | 980a46 | source-of-truth and document-boundary standards for local factual receipt |
| 17 | 3c337f | complete own Tchop MANIFEST then PROJECT_CONTEXT |
| 18 | 3a532b | complete own BG MANIFEST then PROJECT_CONTEXT for allowed separation check |
| 19 | 9bebb3 | FIRST nested Tchop AGENTS after entire first layer |
| 20 | f27ebd | FIRST Tchop Library STARTUP_RULE after own AGENTS |
| 21 | 4a3147 | FIRST own BG nested AGENTS after first layer |
| 22 | a270c0 | FIRST own BG STARTUP_RULE after BG AGENTS |
| 23 | 1b3063 | exact source-pin CONTENT_MANIFEST encoding and 34-file identities |
| 24 | 0422d5 | own mode contract TC then BG, before handler execution |
| 25 | 9fbd1e | pre-status source-pin/hashes/regular-file/own record fingerprints snapshot |
| 26 | fd3df6 | own TC exact-selector live read-only status |
| 27 | 57cff6 | own BG exact-selector live read-only status (no inheritance) |
| 28 | 4a21da | TC ON/AUTO bounded startup evidence/safety challenge after provisional KB; identical BG copies eligible for reuse by own hashes |
| 29 | e4af38 | required ON quality contract and claim-risk guidance; own BG same-hash reuse |
| 30 | 8dc78e | receipt-path applicable overrides and new-directory ownership check |
| 31 | 7fe683 | post-status 105 protected hashes and complete tracked diff/HEAD/status comparison |

Main plan: all 804 lines visible in four non-overlapping complete ranges. All output budgets exceeded the corresponding returned token counts; no truncated read was treated as complete.

Entire first layer completed after invocation18 and before first nested read19. Neither prior receipts nor app source bodies were opened before this boundary. The provided root AGENTS context is distinguished from current on-disk root read04. Payload/source hashes after the boundary are fingerprints, not semantic source review.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
