# Share Extension Runtime Validation Report

## Date
2026-05-13

## Scope
Manual runtime validation checklist from `./docs/SHARE_EXTENSION_VALIDATION.md`.

## Execution Status
- Environment in this pass: CLI-only (no interactive simulator/device session attached).
- Result: scenarios prepared and normalized for execution; runtime checks pending manual run.

## Manual Execution Protocol
Use one source app at a time (Photos/Files/Notes/Safari). For each scenario:
1. Prepare source content.
2. Open system Share Sheet -> choose Tchop share extension.
3. Verify imported draft in composer.
4. Publish when scenario requires publish.
5. Re-open main app and verify feed/channel sync behavior.

## Scenario Matrix
| ID | Scenario | Expected Result | Status | Notes |
|---|---|---|---|---|
| S1 | share text only | text merged into card `text` field | Pending | |
| S2 | share one image | one photo item created | Pending | |
| S3 | share multiple images | multiple photo items created | Pending | |
| S4 | share one video | file media imported, `video` card kind | Pending | |
| S5 | share one audio file | file media imported, `audio` card kind | Pending | |
| S6 | share one pdf | file media imported, `pdf` card kind | Pending | |
| S7 | share text + image | image is primary, text merged into `text` | Pending | |
| S8 | share text + video | video is primary, text merged into `text` | Pending | |
| S9 | delete imported primary media | card kind recalculates correctly | Pending | |
| S10 | publish from extension -> re-enter app | sync to correct channel after activation | Pending | |
| S11 | publish -> pull-to-refresh | sync still works on refresh | Pending | |
| S12 | unauthenticated extension state | reason text + `Open app` shown | Pending | |

## Negative/Rejected Behavior (must stay explicit failures)
| ID | Scenario | Expected Result | Status | Notes |
|---|---|---|---|---|
| N1 | mixed media (`image + video`) | explicit failure | Pending | |
| N2 | multiple files (`video + pdf`) | explicit failure | Pending | |
| N3 | incompatible media vs existing draft media | explicit failure | Pending | |
| N4 | unsupported provider type | explicit failure (no empty composer) | Pending | |
| N5 | unknown generic file type | explicit failure (no pdf guessing) | Pending | |

## Product Rules Snapshot
- incompatible imports => explicit failures
- unsupported/unknown file types => explicit failures
- no silent type guessing
