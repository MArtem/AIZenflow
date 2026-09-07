# 23 — Git, Commits, and Pull Requests

## Branch safety

Do not commit directly to protected/integration branches unless the repository/user explicitly requires it.

Do not reset/revert pre-existing user changes.

## Commit

A commit MUST:

- be coherent;
- contain only intentional files;
- have required gates passing;
- avoid secrets/build artifacts/local environment files;
- use project commit-message convention if one exists.

Recommended generic subject:

```text
<type>: <behavioral intent>
```

Examples:

```text
fix: prevent stale search results replacing newer query
feat: add retryable offline state to feed
refactor: isolate token refresh coordination
```

## PR description

Must state:

- problem/intent;
- implementation summary;
- risk level/triggers;
- tests and commands actually run;
- screenshots/visual evidence when relevant;
- migration/security/privacy/dependency implications;
- known limitations/unverified scenarios;
- rollback or compatibility note for high-risk changes.

## No false green

If a required test could not run because simulator/tool/service is unavailable, PR must say that. Do not replace evidence with “should work.”
