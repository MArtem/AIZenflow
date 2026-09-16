# Luna final acceptance receipt

Date: 2026-09-16
Task: `new-task-be0b`
Executor: Luna Xhigh, mode `эконом`
Scope: library R1–R4, host diagnosis, fresh-entry preparation, and the three bounded pilots from `luna-final-acceptance-runbook.md`.

## Package and library evidence

- Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.
- Candidate release identity: `5.4-review-ready.7`; package release id: `..._V14`.
- `validate_package.py`: PASS — `files=1366 skills=60 sections=51 playbooks=288 errors=0`.
- Final serial library suite: PASS — `198 total / 192 pass / 0 fail / 6 skip`, exit `0`.
- The suite used an explicit temporary root under `.zenflow`. The host-level Git boundary encloses the approved sandbox, so the six positive external-deployment cases were not bypassed.
- Final archive: `dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_FINAL_ACCEPTANCE_20260916.zip`.
- Archive SHA-256: `06f6f988027a35d7d1413d1652897174de7296b8daf9167ddbd8d210d02a45d5`.
- `unzip -t`: PASS; extracted archive validator: PASS with the same `1366/60/51/288/0` counts.

The six skips are all environment-bounded and have no failure hidden behind them:

1. `test_F14_dry_run_no_mutation` — no permitted fixture root outside every detected Git repository.
2. `test_F14_portable_area_profile_is_explicit_and_local` — same boundary; portable external fixture unavailable.
3. `test_F14_manual_documented_fresh_reference_and_full` — documented manual deployment requires an authorized external-to-Git root.
4. `test_F14_manual_preflight_accepts_verified_transitional_shim_for_descriptor` — same boundary.
5. `test_F14_manual_preflight_clean_is_read_only_and_emits_selector` — same boundary.
6. `test_F14_real_v6_round_trip_uses_fixed_coordinator` — real `.6 → current → .6` acceptance requires an authorized external-to-Git fixture root.

These are `BLOCKED_ENVIRONMENT`/`NOT_RUN`, not PASS claims. The candidate's negative CLI, mocked lifecycle, bounds, and source-in-place selector coverage passed.

## R1–R3 status

- R1: PASS at the documentation/static-test level. Clean-host manual profile and current-host canonical profile are separated; stale placeholders were removed from the harness. The real external manual lifecycle remains covered by the six skips above.
- R2: PASS at the contract/static-test level. Fresh full installation is distinct from existing reference→full migration, and the matching preflight identity is documented. The command path is explicit and does not pretend that a fresh install is a migration.
- R3: `BLOCKED_ENVIRONMENT`. The candidate fixed release can coordinate an incoming historical `.6` payload, and the legacy `.6` refusal path is covered. A real positive round trip could not run without creating a forbidden Git-boundary bypass.

## Host delivery and selected runtime

Read-only inspection of the permitted installed descriptor found:

- installed runtime release: `5.4-review-ready.7`;
- protection version: `5.4-review-ready.5`;
- installed descriptor source tree hash: `806b7251517c1606c38bef09558c38e0ebd828adaa758ae7eb4582ea852b1976`;
- installed profile: `reference`.

After the candidate was stabilized, its `1366`-file tree was synchronized into S with no
deletions, then the standard reference `sync_global.py` dry-run/apply pair updated R using the
matching preflight id. `validate_global_install.py` now returns `ok=true` with `errors=[]`.

The active Desktop `CODEX_HOME`, managed global instruction block as delivered to the active host process, and the exact package selected by that process are not exposed by the available product context. Therefore:

- common delivery: `UNKNOWN`;
- corrected-package selection by active host: `UNKNOWN`;
- relevant-route application by a fresh host: `UNKNOWN`.

No host patch, restart, global-home mutation, or rewrite of unknown assets was performed.

## Fresh-entry control

The three pinned upstream repositories were inspected before project mutation:

- GhibliSwiftUIApp: `524c434882dcc22d95b1c5781f295d8fbfe0ced6`;
- firefox-ios: `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071`;
- clean-architecture-swiftui: `9eca97b8cfff96a14084b564b1fefd949c93d232`.

Disposable fixtures were prepared locally at `fixtures/entry-empty-git`, `fixtures/entry-linked`, and `fixtures/entry-non-ios`. No upstream AGENTS file, portable snapshot, launcher, workflow, dependency, or test was added. A fresh Codex Desktop task was not created because the available product operation was not authorized by the current request to create a new user-owned task; consequently fresh-entry observations are `NOT_RUN`, not inferred from shell fixtures.

## Pilot 1 — implementation: GhibliSwiftUIApp

Result: `PASS` for the bounded static implementation scope.

Changed exactly one upstream source file:
`GhibliSwiftUIApp/Views/FilmsScreen.swift:29-38`.

The error state preserves the existing error message and adds a native `Button("Retry")` that starts the existing asynchronous `filmsViewModel.fetch()`. The existing view-state switch removes the action when loading begins, and the ViewModel's existing loading guard prevents repeated in-flight fetches. No test file, dependency, project setting, build artifact, or commit/push was changed. `git diff --check` passed. App build/UI verification was intentionally not run under the runbook.

## Pilot 2 — code review: firefox-ios

Result: `PASS` for read-only review; no confirmed P0–P2 finding in the bounded scenario.

Reviewed `SearchViewModel.swift`, `SearchViewController.swift`, and the construction call site in `BrowserViewController.swift`.

Observed protections include cancellation before a new suggest request, query equality guards before publishing asynchronous results, private/normal tab separation, URL filtering, and notification-specific reload paths. The setter orders `querySuggestClient()` before `setupSuggestClient(with:)`, which would be unsafe if the manager were reassigned during an active non-empty query. The current call graph assigns it during controller creation before user input; `SearchSettingsChanged` reloads UI/trending data and does not reassign the manager. This remains a follow-up review note, not a confirmed runtime defect. The upstream repository stayed clean.

## Pilot 3 — cross-domain: clean-architecture-swiftui / Countries

Result: `PASS` for the requested scenario analysis; no source changes.

The flow is explicit: non-forced load reads SwiftData first; a missing or failed read falls through to network; network details are stored; a read-after-write verifies presence; UI maps loading/loaded/failed states and offers a force-reload retry. Cancellation preserves the last value only while the `Loadable` state remains `.isLoading`.

Review note: `try?` in `CountriesInteractor.loadCountryDetails` intentionally collapses a database read failure into a cache miss, which can add a network/write cycle and hide persistence health. `store(countryDetails:)` also constructs new models for fields marked unique, so force-reload persistence semantics deserve a runtime test before production reliance. These are contract risks, not promoted findings without the prohibited app runtime verification. The upstream repository stayed clean.

## Non-iOS control and final verdict

The non-iOS fixture is present, but no fresh host task observed it. Its acceptance status is `NOT_RUN`; no iOS route adoption is claimed.

Overall package status: `SELF_VERIFIED / NOT_READY_FOR_ACCEPTED_RELEASE`. Package integrity and static pilot scope pass. Host delivery, fresh Desktop entry, positive external lifecycle, and app runtime/build evidence remain `UNKNOWN` or `NOT_RUN`. This receipt deliberately does not convert those limits into a general “ready” claim.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
