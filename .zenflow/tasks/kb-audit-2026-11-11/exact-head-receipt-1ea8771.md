# Exact HEAD receipt: Tchop checkpoint and agent rules

- Range: `3b7abfde918c97b43897b16a93c2172cc4512bb0..1ea877101abf41bd2dee2e39a8a13fdf845d5b81`; canonical worktree clean.
- Contract: record the complete pre-cleanup checkpoint read and entrypoint comparison without promoting old decisions or claiming app/runtime validation.
- Complete committed one-file diff reviewed against historical source, current Tchop contracts and current reusable agent entrypoint; no findings in this bounded report.
- Checks: `git diff --check` and vault documentation check passed. No build, tests, runtime or app changes.
