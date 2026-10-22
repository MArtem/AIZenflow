# KB practical pilots — final scoped acceptance, 2026-10-22

**Runtime and semantic verdict: ACCEPTED_SCOPED_WITH_USER_EXCLUSION.** Six approved project scenarios have evidence on iPhone Simulator iOS18.2 and27.0. Firefox is BLOCKED_BY_USER_TOOL_INSTALLATION_DECISION / NOT_RUN, never PASS. This accepts the finite KB pilot work, not every app, release, hardware scenario, API freshness claim or a controlled model comparison. Original KB document-core acceptance remains historical and scoped.

Model GPT-6.1 Sol/medium; persistent эконом. Docs route: current canonical bootstrap/Level0 + selected testing/debugging, concurrency/error handling, project overlays, engineering change contract and task/document governance. No new agent, installer, runtime/SDK upgrade, GitHub CI or Library mode operation.

## Final verification matrix

| Pilot | Each iOS18.2 /27.0 | Principal evidence |
|---|---|---|
| P01 Battleship | Existing UI1/1; native model12/12macOS retained separately | P01-ios-results.json, P01-native-result.json |
| P02 AIFieldbook | Local5/5 + real UI1/1 | P02-final-unit18/27-result.json; P02-ui18-fixed-result.json, P02-ui27-result.json |
| P03 MVVMExample | Selected7/7 | P03-ios18/27-result.json |
| P04 Countries | Selected9functions + real UI1/1;18.2 unit selection split3+6 | P04-db18-result.json, P04-failure18-result.json, P04-selected27-result.json, P04-ui18/27-result.json |
| P05 Ghibli | Catalog/storage4/4 + true process-relaunch UI1/1 | P05-storage18/27-result.json, P05-ui18/27-result.json |
| P06 Firefox | NOT_RUN on both, by user decision | prerequisite-blockers.json |
| P07 Tchop | Renderer3functions/8parameter runs + owner1/1 + real UI2/2 | P07-ios18/27-result.json, P07-composer18/27-result.json, P07-ui18/27-result.json |

Selected final cases have0skips and exit0; functions and parameter runs are distinct. This table reuses unchanged scoped evidence rather than inflating counts by reruns. All initial compilation, permission and UI failures remain in their original receipts/ledger. `*-attempt*.json` records diagnostic failures, not erased flaky retries.

## Changes and checked contracts

- AIFieldbook: narrow Sendable search provider implemented by the real SwiftData actor; controlled failure→retry retains query/workspace; cancelled generic errors cannot overwrite successful same-criteria replacement. The late-failure test explicitly awaits both captured completion snapshots. Snapshots expose completion only, not task cancellation/mutation. Empty/filter and100-result-envelope cases use real isolated SwiftData. Actual UI covers query replacement, tab leave/return, clear and failure/retry.
- Confirmed P2 `P02-UI27-SEARCH`: iOS27 UI lacked any search field under automatic placement. Explicit navigationBarDrawer(always) restores it. Prior failures, actual accessibility trees and corrected UI PASS on both runtimes are retained. No known unresolved P0–P2 in the owned final patch after self-review.
- Ghibli: injectable UserDefaults retains the standard default/key/encoding. Unit storage checks use a UUID suite. UI uses an offline Debug catalog and a separate validated UUID suite: favorite→terminate/relaunch→visible favorite→remove→terminate/relaunch→empty favorites. Final cleanup launch removes only that owned suite. Debug deployment floor18.0 enables this test matrix; Release26.0 remains unchanged.
- Countries: original dependencies only, pinned EnvironmentOverrides0.0.4 and ViewInspector0.10.5. Real interactor, controlled DB write failure, real in-memory transaction and actual list UI exercise error→Retry→visible country. Read-failure/cancellation propagation remains covered by the selected existing tests. Debug fixture forwards native active/inactive events and enables SwiftUI accessibility exposure inherited by EnvironmentOverrides. Activity forwarding alone did not fix automation; enabling exposure did. This is not VoiceOver or normal lifecycle certification; ordinary/Release composition is unchanged.
- Tchop: Debug opt-in seeds file-row video draft metadata for the first composer only. Actual UI enters text, observes video metadata, cancels, verifies no publication and reopens an empty draft; normal text-publication control also passes. The actual inline video UI is file metadata, not an asynchronous thumbnail task. Existing real video-renderer geometry/fallback tests and old-owner mutation isolation remain separate evidence. No new speculative video loader. Share follow-up remains PAUSED; the fixture shell class is excluded from APP_EXTENSION.
- MVVMExample: two test-only repairs align actor cache callers and lock-owned URLProtocol state with actual Swift6 APIs. Existing selected refresh/pagination/retry/network cases and the unchanged0.5s cache budget pass. Production source unchanged.

UI fixtures require explicit Debug launch keys; normal startup defaults are preserved. AIFieldbook never opens the user's persistent store in fixture mode and bypasses real file/Spotlight maintenance. Countries uses only in-memory data and offline dependencies. All UI target additions are non-archiving; static graph checks confirm existing app-target configuration/membership remains unchanged in AIFieldbook/Countries. Ghibli's two Debug-floor changes are the explicit exception above.

## Cleanup and preservation

All newly downloaded dependency sources/repository caches were contained in two exact owned .zenflow roots, then removed. [Cleanup ledger](download-cleanup-ledger.json) verifies both roots absent:9,875,043logical bytes across the two rounds. Earlier sandbox temporary-product cleanup is separately retained in cleanup-2026-10-22.json. Own empty failed-attempt workspace state and the newly generated ignored resolution file were removed; exact pins remain in P04-resolution-metadata.json. No existing package/source/resource was deleted. Native DerivedData/build caches/logs remain in the standard system paths explicitly authorized by the user.

[Application preservation](application-git-preservation.json) binds clean local app commits to their trusted task bases and exact reviewed patches under preservation/. No original OSS upstream was mutated. Shared KB source/evidence and canonical recovery publication are the final Git phase; exact post-commit HEAD/remote/clean results belong to the external receipt `/Users/Artem/.zenflow/reports/kb-pilots-2026-10-22-final-publication.json`, written after the frozen commits. This avoids a tracked self-invalidating SHA receipt.

## Review, omissions and observations

Complete owned final diffs were self-reviewed for authority, default behavior, producer/consumer parity, task ownership/order/cancellation, data/fixture isolation, error-vs-empty semantics, cleanup, target/scheme/archive membership and false-success routes. Source consumers were checked. [Static evidence](final-static-review.json) checks graph parity, final runtime summaries, clean external app commits/patch hashes, exact override mirror and absence of downloads. Independent review of this new app patch was not authorized/executed; the earlier independent KB document audit is not reused as app certification.

Existing warnings remain recorded: Countries Swift6/legacy ViewInspector diagnostics; Ghibli unused decode/transient command-exit0 diagnostics; Tchop FoundationModels deprecation and earlier renderer QoS warning. No warning-clean, Swift6 migration, performance improvement, crash/power-loss durability, whole-app or release-ready claim. iPad/physical/actual VoiceOver OMITTED_BY_USER. Real network, Share follow-up, archive/signing/release, Instruments and all nonselected suites remain outside this finite pilot contract.

Observed process improvements: obtaining execution and writing permission separately; validating actual target/scheme/deployment prerequisites; differentiating model, renderer and full UI evidence; testing cancellation with controlled ordering; preserving failures; correcting real-source scope assumptions. Existing KB owners already cover these failure classes, so no duplicate blanket rule is added. One actual UI compatibility defect was found/fixed. No causal KB/model advantage or token/subscription saving is established.

Context health: контекст обновлять не нужно for closure of this frozen scoped candidate. Any new app/phase uses fresh routing and current authority. **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
