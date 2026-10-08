# Countries applied candidate: QA01

**APPLIED_LOCAL; QA BLOCKED_BEFORE_COMPILATION.** Human approved application, two-file source/test block, targeted tests and necessary builds on iPhone Simulator18.2/27. No new agents/MCP.

Countries branch `codex/countries-db-error-contract`, commit `3bfd869fcd11fa4ca04e065750ebfeff9d8f33ba`, pinned base `9eca97b8cfff96a14084b564b1fefd949c93d232`. Clean after commit. Full zero-context [applied patch](applied.patch) (replay with `git apply --unidiff-zero`) preserved here and in canonical task; upstream is not a user-owned publication target and was not pushed.

Two source substitutions preserve database read failures instead of treating them as nil. Updated initial/post-store error tests each cover generic NSError and CancellationError; added genuine post-store nil regression. Existing cache-hit, force, cache-miss, web/store failure tests retained. New behavior is a deliberate local contract change: two upstream tests previously required the opposite behavior.

Final two-file semantic diff review and diff-check PASS; direct CountryDetails UI consumer passes thrown errors into its existing Loadable/error view, retry remains force=true. No new UI or rollback guarantee. Generic error checks compare NSError value; cancellation checks preserve its type, not a task scheduling/stop guarantee.

Xcode27.0 build27A266a; installed iPhone16Pro/iOS18.2 and iPhone18Pro/iOS27.0 destinations available. SDK requested iphonesimulator; actual compile SDK/profile unconfirmed because dependency preflight stopped first. Existing project declares Swift5, app target18.0/project18.1 and UnitTests18.1; no settings changed.

18.2 targeted `test` invocation failed exit74 before compilation: Package.resolved absent and automatic resolution disabled. Project requires EnvironmentOverrides minimum0.0.4 and ViewInspector minimum0.10.0, both upToNextMajorVersion. No package network resolution/update was authorized in this bounded attempt. iOS27 execution NOT_RUN_SHARED_BLOCKER, same missing lock/package graph; no repeated equivalent attempt. Test execution0, build PASS none. No new failure result against the Swift source is inferred.

Raw build/cache/result bundles stay in ignored task-artifacts. Compact invocation/log/result retained here. Permissions for approved targeted source/test QA remain available after prerequisite decision; no installations, unrelated suites, UI/performance work or new agents. iPad/physical/actual VoiceOver OMITTED_BY_USER; holdout NOT_READ. No production or causal KB/Library benefit claim.

Next decision: permit first resolution/download of these declared GitHub packages and their necessary transitive dependencies within .zenflow, retaining a reviewed Package.resolved; then resume the approved targeted suites on18.2/27. Recommended over arbitrary manual pinning or a substitute standalone model test. Resolution may choose newer versions within existing ranges; record exact revisions and review dependency diff before using results. Unexpected dependency/compatibility changes require a checkpoint, not project modernization.
