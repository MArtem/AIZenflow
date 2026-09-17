# Stage 4 receipt — synthetic installer/update/uninstall/rollback

Date: 2026-09-11
Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`
All targets: synthetic homes under `.zenflow/library-adoption-v54/fixtures/install-lifecycle-macos`.

## Public-entrypoint evidence

`run_install_lifecycle_macos.py` executed the installer and validator as subprocess entrypoints
with explicit `--codex-home`, `--runtime-root`, `--skills-root`, and `--agents-file` paths.

- Reference mode: dry-run had no mutation; apply and `validate_global_install.py` passed; no
  skills were installed; repeat sync preserved user text; dry-run uninstall had no mutation;
  uninstall removed managed content and AGENTS managed block while preserving user content and
  an external session-history file.
- Full mode: dry-run enumerated exactly 60 `ioslib-*` skills; a pre-existing user-owned skill
  collision returned exit 2 and left the synthetic home unchanged; reference→full sync passed
  with the matching preflight id and validator passed.
- V5.2→V5.4: V5.2 reference installer created the synthetic installation, current V5.4 sync
  updated it, validator passed, repeated sync passed, and uninstall preserved the V5.2 history
  fixture and user-owned AGENTS bytes.

## Reused shipped regression evidence

The candidate's installer suite remains part of the full 134-test run and covers late collision,
permission/write failure, mid-install failure, transactional rollback, concurrent registry/tree
edits, modified managed files, symlink targets, unknown managed-tree files, reference/full mode,
and exact AGENTS preservation cases.

## Result

Lifecycle gate: **PASS** for the declared synthetic home and installer envelope.
This does not authorize or evidence a real global Codex-home installation.
