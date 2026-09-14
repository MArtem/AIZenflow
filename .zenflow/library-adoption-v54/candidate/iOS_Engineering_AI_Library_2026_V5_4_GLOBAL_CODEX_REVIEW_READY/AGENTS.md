# iOS Engineering Library — Global Codex Hardened source

This repository is the source of truth for a user-global Codex iOS engineering layer. Client repository preservation is the highest invariant. Do not turn client repositories into library hosts.

When changing this library:
- preserve global installation and safe uninstall/sync;
- preserve external project-state isolation;
- preserve user-global skills and repository-local instruction precedence;
- preserve client-code protection, Git control-plane protection and command preflight;
- never weaken dirty-worktree, protected-path, nested-repo, symlink or cache-privacy safeguards for convenience;
- run `python3 validate_package.py` before publishing.

See `50_CLIENT_CODE_PROTECTION/` for the protection model.
