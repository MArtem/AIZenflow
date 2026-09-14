# Safe Command Execution Policy

Use `ios_ai.py guard --command "..."` before any nontrivial command whose side effects are uncertain.

Classifications:
- `ALLOW_READ_ONLY`: the parsed argv matches a narrow explicit local read-only allowlist; repository instructions still apply.
- `REVIEW_UNSUPPORTED`: unknown, malformed, shell-composed, mutating, network/dependency/build/release, interpreter, or otherwise unsupported argv form. It is **not** permission to execute.

The guard is advisory classification only. A caller that ignores its result can still execute an OS process; this policy is not a kernel/process sandbox.

Ordinary source editing does not authorize commit/push, dependency resolution, package-manager mutation, release/upload, signing changes or destructive cleanup.
