# Cross-version state receipt — V5.2 to V5.4

Date: 2026-09-11. Executor: GPT-5.6 Luna xhigh.

- Environment: macOS arm64, Python 3.9.6, Git 2.50.1.
- Fixture root: `library-adoption-v54/fixtures/cross-version-macos/`.
- V5.2 runtime created a schema-2 session, then independently ran `verify` and `close`.
- V5.4 used the same external state root and reported the old session as
  `legacy-v5.2-closed-archival` / `ARCHIVAL_CLOSED`.
- Historical audit remained available; V5.4 returned `verification: null`.
- Legacy session JSON SHA-256 before/after: `3524c8eee00d5d36eba3391b01fe1a88f642ed762d5853892664bb0dcba84451`.
- Legacy JSON was byte-for-byte preserved.
- V5.4 began and closed a new writer with `one-writer-per-git-common-dir`.
- A real active V5.2 session caused V5.4 begin to exit 4 with
  `ProtectionError: legacy V5.2 active/verified session requires explicit recovery before upgrade`.
- V5.2 cleanup after the negative case succeeded.

The script was a disposable harness under the evidence directory; it did not use the real Codex
home or real project state.
