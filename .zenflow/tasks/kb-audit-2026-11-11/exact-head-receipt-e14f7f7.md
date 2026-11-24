# Exact HEAD receipt: lifecycle and profiling task boundaries

- Range: `8802ca2d441ef76bc7acbce0304149e917a1fdd6..e14f7f76d012d4a6f9ab244ccbed262247a25f9c`; canonical worktree clean.
- Contract: apply user-excluded verification and stricter current task/sandbox boundaries over reusable profiling path exceptions; preserve general exception when applicable, no implied execution authority.
- Reviewed committed lifecycle and profiling changes, user override, task boundary, related profiling guidance and byte-identical canonical/baseline/worktree mirrors; no finding in this bounded change.
- Checks: vault documentation check, scoped `git diff --check`, two baseline drift checks and mirror comparisons passed. No builds, tests, profiles, device or external-path work.
