---
name: ioslib-safe-command-execution
description: Use before Git, xcodebuild, dependency, filesystem, network, signing, release, or automation commands whose side effects could alter or expose a client repository.
---

# iOS Safe Command Execution

## Rule
A command used for verification is not automatically safe. Classify uncertain commands before running them.

Use:
`python3 "<runtime>/bin/ios_ai.py" guard --command "<command>"`

- `ALLOW_READ_ONLY`: still respect task and repository scope.
- `REVIEW_UNSUPPORTED`: do not treat the command as read-only; inspect the actual task authority and side effects before any execution.

For `xcodebuild` in an unfamiliar repo, first run:
`python3 "<runtime>/bin/ios_ai.py" build-phases --repo .`

Never use destructive Git/filesystem commands to repair an agent mistake. Never commit/push, mutate dependencies, release, sign, upload, or rewrite broad file sets unless the user explicitly requested that class of action.
