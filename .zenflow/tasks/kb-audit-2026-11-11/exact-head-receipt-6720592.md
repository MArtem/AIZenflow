# Exact HEAD receipt: historic product assumptions and plans

- Range: `f35564d9d7e4ee25d687863458c6890ee5f7b915..6720592536c4f9119e032dfc8ee2d310770e4ec2`; canonical worktree clean.
- Contract: preserve historical requirements and plans, distinguish superseded demo assumptions and permissions from the current app boundary, without changing product behavior.
- Complete two-file committed diff reviewed against the fully read requirements and plans and active MVVMExample rules; no findings in this bounded change.
- Checks: vault static check, `git diff --check`; no builds, tests, runtime, traces or app source changes.
