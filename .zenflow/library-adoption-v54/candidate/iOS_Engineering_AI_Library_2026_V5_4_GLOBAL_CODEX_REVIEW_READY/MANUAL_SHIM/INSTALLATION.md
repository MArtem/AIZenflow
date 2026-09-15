# Manual installation descriptor template

This file is explanatory documentation for the manual deployment described in
`MANUAL_DEPLOYMENT.md`. It is not the active configuration. The active configuration is the
machine-readable `INSTALLATION.json`, generated only after the read-only manual preflight passes.
Extraction alone does not activate the library.

- Runtime shim: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py`
- Deployment descriptor: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/INSTALLATION.json`
- Manual ownership receipt: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/.ioslib-managed.json`
- Knowledge root: `/absolute/path/to/the/unpacked/versioned/release`
- External state root: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-state`

The JSON descriptor records exact absolute paths, release/protection identities and package hash.
The shim recomputes the selected package identity before launch and refuses a stale or mismatched
descriptor; missing, malformed, symlinked or out-of-release targets are refused. The manual receipt is a small operator-published record of managed paths, hashes and modes;
the read-only preflight rechecks it before updates and refuses changed or unknown files. Safety
contract: repository-local rules remain authoritative for project conventions. Library knowledge is
advisory and never grants build/test/network/Git/release permission. Neither the descriptor nor the
manual receipt is an installer ownership registry with automatic rollback.
