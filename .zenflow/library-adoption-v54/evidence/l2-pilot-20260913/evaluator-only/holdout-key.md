# L2 evaluator key — holdout

Frozen 2026-09-13 before any independent output. Do not expose before holdout A/B outputs are
sealed.

## Expected finding

`MessageViewModel.refresh()` creates an unowned/unreplaced task and converts retry failure into
an empty successful-looking result. A later refresh can race with an earlier retrying call and
publish stale messages; cancellation/generation gating and an explicit failure state are absent.
The actor isolation of `MessageRepository` itself is not the defect.

## Control

`OwnedMessageViewModel` cancels its prior task before replacement, keeps task ownership, checks
cancellation after the async boundary and cancels at teardown. Do not flag that lifecycle pattern
as a missing-cancellation defect.
