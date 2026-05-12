# Share Extension Runtime Validation Report

## Date
2026-05-13

## Scope
Manual runtime validation checklist from `./docs/SHARE_EXTENSION_VALIDATION.md`.

## Execution Status
- Environment in this pass: CLI-only (no interactive simulator/device session attached).
- Result: manual runtime scenarios are **not executed yet** in this pass.

## Scenarios To Execute Manually
- [ ] share text only from a real source app
- [ ] share one image
- [ ] share multiple images
- [ ] share one video
- [ ] share one audio file
- [ ] share one pdf
- [ ] share text plus image
- [ ] share text plus video
- [ ] delete imported primary media and verify card kind recalculates correctly
- [ ] publish from extension, re-enter app, verify sync into the correct channel
- [ ] publish from extension, then pull-to-refresh, verify sync still works
- [ ] unauthenticated path and `Open app` behavior on device/simulator

## Notes
- Product rules remain unchanged:
  - incompatible imports => explicit failure
  - unsupported/unknown file types => explicit failure
  - no silent type guessing
