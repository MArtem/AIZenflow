# Shared profiling results

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

- [x] Select a private, cross-project evidence root inside `/Users/Artem/.zenflow`.
- [x] Centralize retained Battleship raw/secondary artifacts, full report, scenario matrix, proposals, and all metric JSON; record deleted-capture history.
- [x] Centralize the detailed Tchop profiling report and retain the deletion record for its removed raw captures.
- [x] Centralize the runtime-auditor methodology review and its supporting review artifacts under a separate methodology category.
- [x] Inventory the broader `.zenflow` workspace; move the legacy Tchop capture bundle from the retired documentation-vault path, preserve hashes, and classify Countries/Ghibli QA evidence separately from profiler output.
- [x] Keep active task `plan.md`/compact `handoff.md` files in their governed task paths and replace duplicated full results with pointers.
- [x] Update the central README, index and per-task manifests; update canonical profiler storage guidance and exact mirrors.
- [x] Run final documentation/static checks, commit and push the canonical guidance update, verify remote SHA, and record the completion receipt.

## Contract

- Root: `/Users/Artem/.zenflow/profiling-results/`, local-only, directories `0700`, files `0600`.
- Full reports, scenario matrices, proposals and structured metrics live centrally; raw captures and logs live in each task's `artifacts/`.
- Active task plans and compact handoffs remain under `.zenflow/tasks/<TaskId>/` as task state and link to central results. No duplicate full reports or metric exports remain there.
- Exclude source, build products, DerivedData, caches, secrets and unapproved production/user data.
- Cleanup remains selective and recorded, never automatic.
- No application build, tests, Simulator or Instruments are needed or permitted by this task.
