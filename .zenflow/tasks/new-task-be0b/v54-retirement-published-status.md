# V5.4 retirement — published status (2026-09-26)

This is a separate task record. It does not replace this branch's active `plan.md` or
`handoff.md`. The goal is to retire the Codex-installed V5.4 mode while preserving useful
iOS engineering knowledge for a future copy-only reference library. Historical Git commits
remain intact.

## Published current tree

- Documentation-vault `main` commit `3e2c7c5dfc0bd04051760ac97c520e0f719d7df7`
  removes all 1,367 tracked files under
  `reusable/ios-engineering-library/v5.4/` and five obsolete installer-oriented task
  delivery documents from the **current tree**. The remote `main` SHA was verified after push.
- The useful source was preserved under inactive
  `reusable/ios-engineering-library/reference-copy-only/`: thematic documentation,
  former `ioslib-*` skills, runtime/orchestration documentation, and four potentially
  useful audit scripts in `source-tools/`. Source snapshots are not an active payload;
  old installer instructions in them require curation before use.
- The pre-removal coverage receipt reported 823 byte-identical copies, 514
  user-approved permission-conditional transformations, zero missing mapped useful
  files and five intentionally excluded deployment/test artifacts. The generated
  manifests were updated. Manifest, documentation-boundary, Markdown-link and
  final-diff static checks passed. This establishes source preservation, **not**
  behavioral parity or release readiness of the copy-only candidate.
- The documentation-vault repository has a remote `main` but no remote
  `development` branch. No new documentation branch was created.

## Codex host boundary

- The exact V5.4 global AGENTS entry was backed up and removed; the canonical
  bootstrap auto-route was removed earlier in documentation-vault commit `8cf5803`.
  A fresh chat after a full Codex restart saw ordinary project/global baseline
  rules and no automatic route to V5.4.
- The exact ignored eight-file installed runtime subtree was moved to a recovery
  location inside `/Users/Artem/.zenflow` after that restart. Its former active
  path is absent. A fresh-chat check **after** this move has not been observed.
- A targeted `config.toml` marker check found no V5.4 route. The file was not
  reset. Auth, Keychain, pre-existing user settings, chats and plugins were not
  inspected or changed. No broad factory-reset claim is made.

## Remaining work, deliberately separate

The copy-only candidate is inactive and not ready to copy into projects. It needs
curated routing/allowlisting, removal of installer-dependent advice from active
content, per-Xcode-project ON/OFF with visible status, local-rules-first AUTO and
ADVISORY behavior, capability checks, and offline evaluation before activation.
The four retained audit scripts are source only: do not execute or ship them until
their side effects and dependencies are reviewed. A post-runtime-move fresh-chat
instruction check remains useful evidence; it must not trigger host mutation.

Do not reinstall V5.4, merge the old task branch wholesale, rewrite Git history,
or touch Codex auth/Keychain to finish this publication.
