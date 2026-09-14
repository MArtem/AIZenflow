---
name: ioslib-client-code-protection
description: Use before and after any write to a client iOS repository to preserve user dirty work, Git control state, protected project/config files, nested repositories, and external-state isolation.
---

# iOS Client Code Protection

## Mandatory use
Use this skill for every task that may modify a client repository. Repository preservation outranks speed or convenience.

## Before editing
1. Read repository-local instructions and inspect `git status`.
2. Determine the smallest exact write scope before edits.
3. Read `references/INSTALLATION.md` for the runtime CLI.
4. Run protection baseline with exact paths, e.g.:
   `python3 "<runtime>/bin/ios_ai.py" protect begin --repo . --allow Sources/Foo.swift --allow Tests/FooTests.swift --task "..."`
5. If any target path is already dirty, stop unless the user explicitly authorizes modifying that exact dirty path; then use `--allow-dirty`.
6. Protected project/dependency/CI/signing/persistence-schema paths require explicit user authorization and exact `--allow-protected` scope.
7. Nested repo/submodule changes require exact `--allow-nested` authorization.

## During work
- Never broaden scope merely because an unexpected change already happened.
- Do not stage, commit, reset, clean, stash, push, fetch/pull, modify dependencies or run release/upload actions unless separately authorized.
- Linked worktrees share a writer slot because their Git common-dir shares ordinary refs/config. Concurrent writers require independent repositories/clones with different Git common directories and disjoint ownership.

## After work
Run `protect verify --repo .` before final success claims. A failure is a stop condition; preserve evidence and report unexpected mutations rather than reverting them destructively.

Load the full policy from the deep library `50_CLIENT_CODE_PROTECTION/` when needed.
