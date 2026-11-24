# Exact HEAD receipt: embedded skill and bootstrap boundary

- Range: `408d2a13c8d3f571855209145754016021d5f7b4..257ba779f017fd09f8cd8e05d24467de2531bf76`; canonical worktree clean.
- Contract: direct catalog exposure of nested user-provided source is not authority or a permission grant; preserve source unchanged and require wrapper/current scope; make manual workflow trigger explicit without activating quality-control or workflow execution.
- Reviewed complete five-file committed diff, observed session catalog entries, user/sandbox precedence, both portable mirrors and pre-existing local template changes. No findings in this bounded change. Discovery remains visible and client load order remains unverified.
- Checks: bootstrap contract in both worktrees initially failed on missing `workflow_dispatch`, then passed after focused documentation fix; vault check, baseline drift, scoped diff checks and portable snapshot equality passed. No workflow, build, tests or source skill was executed.
