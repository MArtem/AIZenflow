# Exact HEAD receipt: Tchop historical onboarding

- Range: `c32675fd69ea8fdaee4b895f0cf763d919600247..f35564d9d7e4ee25d687863458c6890ee5f7b915`; canonical worktree clean.
- Contract: preserve the complete historic onboarding, identify unsafe or stale instructions as historical, avoid app/runtime or full-archive claims.
- Read the complete historical document in sections and reviewed the complete two-file committed diff. Current feed contracts and previously documented trace risk were checked; no findings in this documentation change.
- Checks: vault static check and `git diff --check` passed; no tests, runtime, trace commands or app source changes.
