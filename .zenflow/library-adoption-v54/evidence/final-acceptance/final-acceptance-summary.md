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
- Final archive: `dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_LUNA_FOLLOWUP_20260916.zip`.
- Archive SHA-256: `5882c0da341ea9f8b123eed4b8840b7a008903ccdff2287e0cabfdcfbf221c95`.
- `unzip -t`: PASS; extracted archive validator: PASS with the same `1366/60/51/288/0` counts.
- Canonical follow-up commit: `35d303212c8c2b06450d3551aa8416346e2919cb`.
- Task follow-up commit: `49df1cae6e6f9cadb64fd29b622b5b4b19b21236`.

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

The Astra follow-up fixed the manual lifecycle test's block selection: it now locates the
bootstrap, optional-skill, and receipt blocks by their markers instead of assuming positional
indices. The historical archive test now accepts `IOSLIB_LEGACY_ARCHIVE`, while retaining the
pinned SHA check. Both affected tests still stop honestly at the environment boundary on this
host; their structural assertions execute before the skip.

## Host delivery and selected runtime

Read-only inspection of the permitted installed descriptor found:

- installed runtime release: `5.4-review-ready.7`;
- protection version: `5.4-review-ready.5`;
- installed descriptor source tree hash: `c8790bd29cd98a35cdac4b25945d96bc57948d50b3a99f56fa524b3780653b66`;
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

Disposable fixtures were prepared locally at `fixtures/entry-empty-git`, `fixtures/entry-linked`, and `fixtures/entry-non-ios`. No upstream AGENTS file, portable snapshot, launcher, workflow, dependency, or test was added. The saved-project catalog exposes only `new-task-be0b` and `mvvmexample-3c80`; it does not expose the three downloaded pilot roots, so exact project fresh-entry tasks could not be created. Fresh-entry observations remain `NOT_RUN`. The Ghibli source mutation therefore occurred before a verified fresh-entry observation, which is a process gap in the pilot evidence.

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

Result: `RETURNED` for the requested scenario analysis; no source changes.

The flow is explicit: non-forced load reads SwiftData first; a missing or failed read falls through to network; network details are stored; a read-after-write verifies presence; UI maps loading/loaded/failed states and offers a force-reload retry. Cancellation preserves the last value only while the `Loadable` state remains `.isLoading`.

Confirmed P2: `Loadable.cancelLoading()` removes the `Task` from `CancelBag`, but `CancelBag.cancel()` only clears the collection and never calls `Task.cancel()`. The in-flight operation can therefore finish after the user presses Cancel and overwrite the state that the UI just set to cancelled or restored. This requires a bounded source fix plus cancellation verification before acceptance. A separate contract risk remains: `try?` in `CountriesInteractor.loadCountryDetails` collapses a database read failure into a cache miss, potentially hiding persistence health. The upstream repository stayed clean.

## Non-iOS control and final verdict

The non-iOS fixture is present, but no fresh host task observed it. Its acceptance status is `NOT_RUN`; no iOS route adoption is claimed.

Overall package status: `RETURNED / NOT_READY_FOR_ACCEPTED_RELEASE`. Package integrity and the corrected static harness pass. The Countries cancellation P2, host delivery, fresh Desktop entry, positive external lifecycle, and app runtime/build evidence remain unresolved or `UNKNOWN/NOT_RUN`.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
