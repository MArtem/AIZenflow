# Share Extension Runtime Validation Report

## Date
2026-05-13

## Pass Type
Single uninterrupted pass (automation + static runtime contract verification).

## Verified In This Pass
1. Build/runtime preflight:
   - `./scripts/verify.sh low` => `BUILD SUCCEEDED`.
2. Import/runtime contract consistency reviewed in code:
   - `./Packages/TchopInfrastructure/Sources/TchopShareSupport/ShareItemImporter.swift`
   - `./TchopApp/Models/NewsFeedModels.swift`
3. Confirmed by code paths:
   - supported import kinds: `image`, `video`, `audio`, `pdf`, `text`
   - mixed media (`image + non-image`) => explicit failure
   - multiple non-image files => explicit failure
   - incompatible import into existing media draft => explicit failure
   - unknown/unsupported providers => explicit failure
   - text merge behavior into `.text` field exists
   - card kind recalculation path goes through `effectiveKind` / `media` mutations

## Scenario Status Matrix
### Runtime scenarios (interactive)
| ID | Scenario | Status |
|---|---|---|
| S1 | share text only from a real source app | Pending interactive run |
| S2 | share one image | Pending interactive run |
| S3 | share multiple images | Pending interactive run |
| S4 | share one video | Pending interactive run |
| S5 | share one audio file | Pending interactive run |
| S6 | share one pdf | Pending interactive run |
| S7 | share text plus image | Pending interactive run |
| S8 | share text plus video | Pending interactive run |
| S9 | delete imported primary media and verify card kind recalculates correctly | Pending interactive run |
| S10 | publish from extension, re-enter app, verify sync into correct channel | Pending interactive run |
| S11 | publish from extension, pull-to-refresh, verify sync still works | Pending interactive run |
| S12 | unauthenticated path and `Open app` behavior | Pending interactive run |

### Negative scenarios (interactive)
| ID | Scenario | Status |
|---|---|---|
| N1 | mixed media (`image + video`) | Pending interactive run (code contract matches expected failure) |
| N2 | multiple file attachments (`video + pdf`) | Pending interactive run (code contract matches expected failure) |
| N3 | incompatible imported media against existing draft media | Pending interactive run (code contract matches expected failure) |
| N4 | unsupported provider types | Pending interactive run (code contract matches expected failure) |
| N5 | unknown file types | Pending interactive run (code contract matches expected failure) |

## Final Assessment Of This Pass
- Automated and static verification: **PASS**.
- Interactive runtime verification: **NOT EXECUTED in CLI-only environment**.
- Product rule alignment (explicit failures, no silent guessing): **PASS by current code contract**.
