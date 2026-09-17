# L2 blind A/B utility results

Date: 2026-09-13. Frozen packets, threshold, and evaluator keys were not changed after
independent outputs were sealed. The scored set is one fresh A/B pair for each T1, T2, T3 and
holdout task; duplicate T1 exploratory outputs created during orchestration were excluded from
scoring and are not evidence for the verdict.

## Sealed outputs

| Task | A | B | Result identity |
|---|---|---|---|
| T1 cancellation/stale response | `results/T1-A.json` | `results/T1-B.json` | JSON validated |
| T2 auth refresh/logout | `results/T2-A.json` | `results/T2-B.json` | JSON validated |
| T3 SwiftUI ownership/identity | `results/T3-A.json` | `results/T3-B.json` | JSON validated |
| H holdout actor/cancellation | `results/H-A.json` | `results/H-B.json` | JSON validated |

Actual reviewer token counts were unavailable and are recorded as `UNKNOWN` in the individual
outputs. The outputs contain no evaluator key material.

## Evaluator comparison

- T1: both arms identified the stale-response/unowned-task risk. B made cancellation cleanup
  explicit; neither arm separately emitted the frozen key's failure-to-empty issue as a distinct
  finding, although B mentioned the generic failure path in its stale-completion rationale.
- T2: both arms identified unsynchronized token/refresh state, logout ordering, and replay safety.
  B additionally identified the missing cancellation checkpoints around refresh/replay.
- T3: A identified unstable inline model ownership. B preserved that finding and additionally
  identified the missing `.task(id: itemID)` identity key and stale item work risk.
- Holdout: both arms identified unowned/overlapping refresh work, stale completion risk, and the
  failure-to-empty collapse. Neither flagged the actor-isolated repository control.
- Controls: no arm treated the supplied cancellation checkpoint, valid `@ObservedObject` use,
  actor isolation, or the explicitly safe retry control as a defect.
- Dangerous advice/authority expansion: none observed.

## Measured input overhead

The measurement uses the frozen artifacts read by each arm: the canonical engineering standard,
the frozen contract, and that task's packet for A; B adds the exact seven-document payload from
`PROFILE.md`. The standard is 15,851 bytes and the contract is 2,644 bytes.

| Task | A input bytes | B input bytes | B added overhead |
|---|---:|---:|---:|
| T1 | 19,460 | 66,864 | 243.6% |
| T2 | 19,744 | 67,148 | 240.1% |
| T3 | 19,425 | 66,829 | 244.0% |
| H | 20,020 | 67,424 | 236.8% |

Reviewer token counts were unavailable, so no token overhead is inferred. The frozen gate is
already failed by the measured input-byte overhead; the observed wall-time estimates also grow
substantially for T3 and H.

## Gate decision

`NO_DEMONSTRATED_GAIN`.

B demonstrated additional code-anchored coverage while preserving A's substantial recall and
controls, but the frozen ≤50% overhead condition is not met. The seven-document payload remains
available as a manual, explicitly selected reference set; this run does not justify automatic
global routing or a claim of guaranteed quality improvement. A smaller, task-routed payload may
be evaluated later under a new owner-approved frozen experiment; that is a separate change.
