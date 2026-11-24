# Exact HEAD receipt — 3920997

- Base: 87c89fb9661ed8531e2a3ab6a6ac2933be31b70e; HEAD: 3920997cb97d0e223b9ef0a6d62c9ffb406dc760; canonical worktree clean.
- Contract: replace stale fixed V1-to-V2 acceptance wording with an applicable earlier-to-current migration, requiring revalidation, while preserving historical scoped V1/V2-to-V3 evidence and open acceptance. Align ADR-004 with current user-excluded physical verification without authorizing device-only work or closing a gate.
- Full two-file diff reviewed, no confirmed P0–P3 in this change. Static vault check and git diff --check passed. Existing historical T2 report is cited, not independently rerun or proof of the current schema. Builds, tests, runtime and physical checks omitted under current user instruction.
- Remote before push: 87c89fb9661ed8531e2a3ab6a6ac2933be31b70e; recheck HEAD, push, confirm remote.
