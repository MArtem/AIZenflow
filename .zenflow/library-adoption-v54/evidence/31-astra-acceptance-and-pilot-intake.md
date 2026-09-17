# Astra acceptance review and pilot intake — 2026-09-15

Verdict: RETURNED / NOT_READY for complete deployment acceptance.
Reviewed task HEAD: fc9ffd798a5bf14339d88911b75edf19646f45b5.
Scope: current delivery instructions, selector update/rollback evidence, readiness claims,
and download-only preparation of the three user-selected repositories. Not an app review.

## Confirmed evidence

- Candidate validator: 1366 files, 60 skills, 51 sections, 288 playbooks, 0 errors.
- All 1366 regular entries of V17 ZIP match candidate bytes.
- V17 SHA256: 746946651ed1d540377a33007d930ec30b60b18b57ff7e157f6ff0f0cff08a22.
- Prior 196/191/0/5 suite is historical author evidence, not rerun here.
- Task commits ebc7ee1fc, 8839d2f19, fc9ffd798 change receipts only. The implementation commit
  is 5a34f4dd616d4f9076800043a367b59974272450. A clean diff did not establish product completion.

## Blocking findings

1. **P2 / F7-03 — standalone manual deployment remains missing.**
   MANUAL_DEPLOYMENT.md operator block (lines 50–65) unconditionally defines a canonical
   repository and passes its exception flags. Provide separate clean-host and current-host
   argument sets; do not require AIZenflowDocumentation on a clean Mac.
2. **P2 / F7-03 — reference-to-full instructions use fresh install.**
   README section 7 uses install_global.py after section 5 installs reference. QUICKSTART also
   presents fresh-full commands without a separate migration sequence. Existing registration
   must use sync_global.py --codex-home <existing> --mode full, first dry-run, then matching
   preflight ID (sync_global.py lines 157–170). Fresh full install remains a separate case.
3. **P2 / release update — legacy rollback claim is unsupported and contradicts old code.**
   README section 11 and QUICKSTART say to run the preserved old release's sync_global.py.
   The .6 source at 9d835401a rejects a source-in-place update from any root different from the
   registered source. Thus after selecting .7, invoking .6 from its preserved directory is
   rejected. test_F14_source_in_place_update_switches_release_root_and_can_return uses the
   current sync implementation in both directions, so it does not prove .6 -> .7 -> .6.
   Define and test a compatible recovery procedure, or explicitly restrict the rollback promise
   and provide a verified recovery path for the already shipped .6 release; preserve state.
4. **P2 / F7-03 evidence — documented manual test is stale behind a skip.**
   test_F14_manual_documented_fresh_reference_and_full replaces the old
   LIB_ROOT=/ABSOLUTE/PATH/TO/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY
   literal, while current manual uses HASH-VERIFIED-RELEASE-INSIDE-AIZENFLOWDOCUMENTATION and
   canonical flags. The replacement does not bind the actual placeholder. Correct the harness
   for the real two profiles; a missing external-to-Git root is not the only test blocker.

These are source/instruction inspection findings; no failed real-host installation was attempted.
Do not publish a new accepted release while these findings remain open.

## Correct acceptance order

1. Close the library deployment findings with targeted behavioral evidence.
2. Inspect the actual host instruction entry within granted path authority; establish common
   baseline delivery and selected library route separately. Existing installed runtime is not
   a reason to reinstall or change CODEX_HOME. Unknown process facts remain unknown.
3. Observe fresh tasks with ordinary prompts and original upstream instructions. Test existing
   and missing root AGENTS cases separately. Do not add our bootstrap before the missing-AGENTS
   observation. Shell environment and model self-report alone do not establish host discovery.
4. Luna performs implementation, read-only review, and cross-domain pilots after user continuation.
   Cross-domain may combine iOS concerns (for example networking and persistence); a separate
   non-iOS control is required for the distinct claim of task-neutral common delivery.

The prior request to make the user install again, find a root outside the known home Git root,
and collect every technical receipt was not an appropriate immediate next step. Agents should
prepare and inspect available evidence; user intervention is limited to unavailable host actions
or a specifically identified external-path authorization. Current host files were not read here.

## Download-only intake

Root: /Users/Artem/.zenflow/library-acceptance-projects

| Folder | Upstream | Pinned HEAD | Suggested later role |
| --- | --- | --- | --- |
| firefox-ios | https://github.com/mozilla-mobile/firefox-ios.git | 0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071 | bounded read-only review in a large app |
| GhibliSwiftUIApp | https://github.com/gahntpo/GhibliSwiftUIApp.git | 524c434882dcc22d95b1c5781f295d8fbfe0ced6 | small implementation after Luna chooses a concrete requirement |
| clean-architecture-swiftui | https://github.com/nalexn/clean-architecture-swiftui.git | 9eca97b8cfff96a14084b564b1fefd949c93d232 | bounded cross-domain scenario after Luna's intake |

All three are depth-1 single-branch clones, no tags/submodules/dependency installation;
LFS smudging and clone-time hooks disabled. Total allocated size approximately 348 MiB.
All three have clean git status. Firefox has upstream root AGENTS.md; the other two have no
tracked AGENTS.md/AGENTS.override.md. These are iOS projects, not three non-iOS controls.
License-name inventory found Firefox LICENSE and clean-architecture-swiftui LICENSE; no matching
license filename in Ghibli. This is not a license audit or authorization for redistribution.

User explicitly deferred all project work to Luna: no app source inspection, modifications,
builds, tests, bootstrap injection, dependency setup, commits, push or new pilot tasks performed.
Adoption/bootstrap intentionally deferred to preserve untouched intake and first-entry evidence;
owner is user/Luna, revisit before actual project modifications. These clones are source fixtures,
not approved runtime installation destinations and not proof of library adoption.

## Next Luna block

Fix the four library findings first, one bounded correction at a time, with real producer/consumer
tests. Then synchronize canonical/candidate and release evidence under existing authority.
Do not repeat receipt-SHA commits: record a reviewed SHA externally or label a fixed historical
implementation SHA. Project pilots remain deferred until the user resumes Luna on that work.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
