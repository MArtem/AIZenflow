# Unexpected Mutation / Incident Recovery

When protection verification fails:

1. Stop further writes and automation.
2. Do not run reset/clean/restore/stash to hide the problem.
3. Report exactly what changed and whether it touches user-dirty/protected/Git/nested state.
4. Preserve `git diff`, status and protection evidence.
5. If the unexpected change is generated/build output and safe to remove, still require deliberate confirmation when removal is destructive or ambiguous.
6. Repair only the agent-owned unintended changes; never overwrite user-owned work.
7. Re-baseline only after the repository is understood and stable.
