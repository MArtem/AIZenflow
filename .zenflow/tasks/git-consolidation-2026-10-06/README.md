# AIZenflow Git preservation — 2026-10-06

Task-local recovery evidence. Current canonical rules and the completed new-task-be0b plan remain authoritative. This archive does not activate older instructions, installers, host settings or Library modes.

The user asked to save 40 uncommitted files and consolidate all AIZenflow branch information into development and main. The exact 40-file snapshot is commit `99563476ab68485c94e84bfd36a68b55fbd7aa80`; `old-dirty-manifest.json` records its SHA-256 file hashes. `retained-history.json` identifies every initial ref/head and the merge resolutions. All selected branch/worktree histories are retained as ancestors, including older conflicting versions. Current source, project files, policies and completed task state remain byte-identical to `937d8120c971f9fb3d3ee42720a16fa7b766f3d6`.

To recover any old file without changing the checkout: `git show 99563476ab68485c94e84bfd36a68b55fbd7aa80:<path>`. Other original branches use the recorded SHA in `initial-refs.txt`. Retired Library installation history is retained in Git only; it is not restored to the active tree. No histories or branches were deleted or rewritten.

Scope includes AIZenflow origin branches, its local release refs and detached worktrees. The separately named AIZenflowRelease remote is excluded pending explicit inclusion; it was neither fetched nor changed. No new agents/MCP or runtime operations were used. New builds/tests are unnecessary because the existing runtime source tree did not change. Prior evidence retains its stated limitations; iPad/physical-device checks remain excluded by the user.

Final exact-SHA review and remote confirmations are kept outside tracked files under `/Users/Artem/.zenflow/task-artifacts/new-task-be0b/git-consolidation-2026-10-06/` to avoid a self-invalidating receipt commit. Canonical recovery copy: `documentation-vault/tasks/git-consolidation-2026-10-06/`.
