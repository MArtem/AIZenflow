# Git / PR Policy

Before editing: inspect `git status`, current diff and relevant history when behavior is unclear. Never overwrite unrelated user changes.

Before finalizing: run `git diff --check`, inspect the final diff, identify generated/lockfile changes, and report unverified areas. PR review findings must name a concrete failure scenario and a minimal correction; style-only noise is not a finding unless the repository explicitly gates it.

High-risk PRs should state: invariants, migration/compatibility, rollout/feature flag, observability, rollback, and evidence.
