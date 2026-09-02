# Worktree Verification Instructions

## Purpose

This file defines only the current worktree-level verification boundary. App-specific commands,
fixtures, devices, and acceptance matrices belong in the selected app's canonical documentation.

## Default Rule

- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to
  fix a specific failing test.
- Do not run builds, tests, Simulator UI, Instruments, archive, signing, or downloads unless the
  user explicitly authorizes the current block.
- Use targeted static inspection first and the smallest runtime evidence that proves the actual
  risk when runtime verification is authorized.
- Keep DerivedData, caches, logs, traces, and temporary project artifacts inside
  `/Users/Artem/.zenflow`.
- Never download a Simulator runtime without explicit permission. The current approved working
  runtime is iOS 26.5.

## App Routing

- AI Fieldbook: load `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook/MANIFEST.md`
  and its selected plan/acceptance document.
- Tchop: load `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/Tchop/MANIFEST.md` only
  when Tchop or its extensions are in scope.
- Other apps use only their own matching canonical boundary.

Do not reuse another app's scheme, simulator, API trace, build level, or test matrix.

## Current Documentation Audit

No build, tests, Simulator, source verification, or runtime artifact is required. Allowed checks
are documentation indexes, route/boundary/manifest validators, baseline drift, context-cost
measurement, and `git diff --check`.

## Reporting

When verification is authorized and run, report the exact command, scope, source revision/input,
result, omitted evidence, and remaining risk. A static PASS must not be presented as runtime proof.
