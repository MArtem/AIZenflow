# Manual installation descriptor template

This file is explanatory documentation for the manual deployment described in
`MANUAL_DEPLOYMENT.md`. It is not the active configuration. The active configuration is the
machine-readable `INSTALLATION.json`, generated only after the read-only manual preflight passes.
Extraction alone does not activate the library.

- Runtime shim: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py`
- Deployment descriptor: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/INSTALLATION.json`
- Knowledge root: `/absolute/path/to/the/unpacked/versioned/release`
- External state root: `${CODEX_HOME:-$HOME/.codex}/ios-engineering-state`

The JSON descriptor records exact absolute paths, release/protection identities and package hash.
The shim validates it before launch; missing, malformed, symlinked or out-of-release targets are
refused. Safety contract: repository-local rules remain authoritative for project conventions.
Library knowledge is advisory and never grants build/test/network/Git/release permission. This
manual descriptor is not an installer ownership registry and does not provide automatic rollback.
