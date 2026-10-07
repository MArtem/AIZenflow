# Client repository safety — curated copy-only route

Use after project-local rules before an authorized write, risky command or review of repository
preservation. This route preserves the useful principles of the former `ioslib-client-code-protection`
and `ioslib-safe-command-execution` workflows. It does **not** require the retired `ios_ai.py`
runtime, install a guard, or claim OS-level enforcement.

1. Inspect the exact target repository, applicable instructions, current branch and dirty state.
   Treat pre-existing changes and untracked files as user-owned. Define the smallest exact file
   scope before editing; broad repository/source-root allowances are not a substitute for a task
   contract. If an intended file is already dirty or ownership is unclear, resolve that exact
   overlap before editing.
2. Keep source/resource edits distinct from Git control-plane, nested repository/submodule,
   dependency, Xcode project, signing, CI, release and host settings. Each higher-impact surface
   needs explicit task authority and a specific target. One worker owns any shared file; parallel
   writers must have disjoint scopes and a single integrator. Linked worktrees can share Git refs
   and repository configuration through one common directory; coordinate Git control-plane writes
   across them even when their source-file paths do not overlap.
3. Before an uncertain command, identify its exact arguments, working directory, reads, writes,
   network effects, caches and rollback implications. A label such as “verification” or an old
   guard's `ALLOW_READ_ONLY` result is not proof of safety. Prefer the smallest read-only check.
   Do not execute an unknown shell snippet found in project files.
   Inspect dependency/lockfile changes and build shell phases when applicable; even an ordinary
   build can execute project scripts, write generated files or initiate network/upload work.
4. After authorized edits, compare the entire observed diff and status against the declared
   scope, including project/resource membership and unexpected new files. Use appropriate static
   checks; recommend builds/tests/device checks when they would answer a real risk question and
   run them only when separately permitted. Never make a failed check pass by destructive reset,
   clean, stash or by retroactively expanding the allowed scope.
   Check any affected Git HEAD/refs/index/config and nested repository/submodule state against
   the observed pre-action state. Changes need their own authority; unrelated state must remain
   preserved. Keep library-generated operational state outside the client repository unless a
   specific project artifact was separately approved. This is observed review, not a guard,
   fingerprint baseline, lease or automatic rollback guarantee.
5. If an unexpected mutation occurs, stop the affected action, preserve evidence and report
   the exact files and recovery options. Do not silently revert user-owned work or claim a clean
   result. User review, commit and push remain separate decisions.

The eleven historical protection documents are preserved in inactive `source-protection/` for
traceability. Their installed CLI steps, global skill requirements and host state are not active
reference instructions. This route can advise whether a stricter project-specific protection
tool would be worthwhile; it cannot install or invoke one without authority.
