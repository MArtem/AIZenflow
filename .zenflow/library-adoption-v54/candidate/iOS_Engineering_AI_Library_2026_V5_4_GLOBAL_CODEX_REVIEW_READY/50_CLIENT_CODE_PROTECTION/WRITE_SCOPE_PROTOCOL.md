# Predeclared Write Scope Protocol

Write scope is declared before editing so verification cannot be retroactively widened to whatever the agent happened to change.

- Prefer exact file paths.
- A directory ending in `/` is allowed only when the task genuinely requires multiple/new files under that directory.
- Wildcards are rejected by the protection CLI.
- Do not use repository root or broad source roots when a narrower scope is known.
- Scope expansion after work begins requires a deliberate re-plan. If the expansion touches user-dirty, protected, nested-repo, dependency, signing, CI, release or Git-control-plane state, obtain explicit user authorization first.
- Parallel agents must have disjoint declared write scopes; shared files belong to one integrator.
