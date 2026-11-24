# Exact HEAD receipt: iOS test strategy scope

- Range: `e14f7f76d012d4a6f9ab244ccbed262247a25f9c..dccba8d52c2aa418cae680a9ffe54caa1f7decbd`; canonical worktree clean.
- Contract: user-excluded checks stay out of plans/gates and remain `OMITTED_BY_USER`, confidence gaps remain explicit, tests/runtime require authorization.
- Reviewed complete two-file committed diff against current user overrides; canonical/baseline and both local mirrors match. No findings in this bounded change.
- Checks: vault documentation check, scoped `git diff --check`, both baseline drift checks and four-copy comparison passed. No tests, build or runtime.
