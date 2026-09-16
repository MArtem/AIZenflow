# Countries — bounded read-only network / persistence / UI pilot

Date: 2026-09-16. Reviewer: Astra. Scope: complete the runbook's scenario analysis, not fix the upstream app.
Repository: `/Users/Artem/.zenflow/library-acceptance-projects/clean-architecture-swiftui`.
Pin: `9eca97b8cfff96a14084b564b1fefd949c93d232`. Working tree checked clean.
All paths below are relative to `CountriesSwiftUI/` in that repository.

## Scenario table

| Trigger | Calls / ordering | UI result and retained data | Source evidence |
| --- | --- | --- | --- |
| First entry, cached details present | non-forced DB lookup returns details; no network or write | loading → loaded cached value | `Interactors/CountriesInteractor.swift:27–30`; `UI/CountryDetails/CountryDetailsView.swift:72–75` |
| First entry, cache absent | DB miss → network details → DB store → DB reread | loaded only after successful reread; raw network DTO is not returned directly | interactor `27–36` |
| Forced refresh / Retry | skip initial cache lookup → network → store → reread | loading hides previous contents; successful result becomes loaded | interactor `27–36`; view `88–91`; `Utilities/Loadable.swift:38–39,116–124` |
| Initial DB lookup throws | `try?` collapses error to miss and falls back to network | may recover through network; original DB-read cause not surfaced | interactor `27–31` |
| Network fails (including offline cache miss) | throw before store/reread | `.failed(error)` with Retry; `Loadable` discards its last value on failure; this path makes no DB write | interactor `31`; Loadable `121–123`; view `88–91` |
| DB store fails after network success | error propagates; final reread not reached | `.failed(error)`; UI has no retained last value in failed state. Transaction persistence behavior is not runtime-verified here | interactor `32`; Loadable `123` |
| Store succeeds but final DB read returns nil or throws | both cases become `ValueIsMissingError` | failed UI even though store completed; no compensating deletion in this interactor; original read error is lost | interactor `33–34` |
| Cancel with no previous value | `cancelLoading` calls bag.cancel, sets user-cancelled error | immediately failed/Retry, but operation continues and can overwrite it later | Loadable `42–53`; `Utilities/CancelBag.swift:19–20,35`; view `82–84` |
| Cancel with previous value | same bag path; sets `.loaded(last)` | immediate restoration only; late completion can overwrite restored value | Loadable `44–47,119–123` |
| Retry after Cancel; old operation completes late | new Task is launched, old Task remains active; neither completion checks generation/ownership | an older completion can overwrite newer loading/result/error state; DB write may also finish after Cancel | Loadable `116–126`; interactor `31–32` |

## Confirmed P2 — cancellation does not cancel the stored Task

`CancelBag.cancel()` only removes references from `[any Cancellable]`. `Task` conforms directly
to `Cancellable` here, without an `AnyCancellable` deinit cancellation wrapper. No stored
task's `cancel()` is invoked. `LoadableSubject.load` publishes both success and failure
unconditionally, so an old task can overwrite the state set by Cancel or a later Retry.
The trace is visible in the source; no runtime reproduction, app test or build is claimed.

A future authorized fix would require both actual task cancellation and ownership/generation
checks before publication: cooperative cancellation alone cannot establish latest-request-wins.
That fix and its tests are outside this read-only pilot and were not performed.

## Interpretation and acceptance

The DB `try?` behavior is an observable diagnostic tradeoff, not a newly invented product
requirement or an independently confirmed extra defect. Cache/offline outcomes above describe
actual control flow; they do not promise durable transaction atomicity, schema migration safety,
or automatic stale-data preservation.

Pilot deliverable: COMPLETE (static read-only analysis with a reported P2).
App release readiness: NOT assessed / NOT approved. The app finding is not a P2 in the library
patch and does not require modifying the upstream repository to accept this review deliverable.
Fresh-host route selection and the separate non-iOS control remain NOT_RUN; this iOS project's
cross-layer analysis is not a substitute for the non-iOS control.
