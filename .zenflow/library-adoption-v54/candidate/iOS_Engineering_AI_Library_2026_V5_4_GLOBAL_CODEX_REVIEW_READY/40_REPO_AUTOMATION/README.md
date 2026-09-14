# Repository Automation Helpers
> **GLOBAL CODEX EDITION — PATH MAPPING**  
> This document originated in the repository-local evolution of the library. In this global edition, any repository-local infrastructure path below is a **logical legacy alias**, not an instruction to create that path in a client repository. Map it as follows:
> - `.ai/project` / `.ai/adaptive` → the external per-repository state returned by `python3 "${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/bin/ios_ai.py" path --repo .` (adaptive/generated data lives under that state directory).
> - `.ai/ios-library` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/library`.
> - `.ai/ios-core` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/core`.
> - `.ai/orchestration` → `${CODEX_HOME:-$HOME/.codex}/ios-engineering-shim/orchestration` plus the external per-repository orchestration state.
> - `scripts/ai/...` → use the global `ios_ai.py` CLI above (or the exact command in an installed skill's `references/INSTALLATION.md`).
> - repository `.agents/skills` / `.codex/skills` → the **user-global skill root chosen by `install_global.py`**.
> - `REPOSITORY_KIT/repo-root` → historical packaging reference only; it is not installed into client repositories in this edition.
> **Never create/copy library `.ai`, `.agents`, `.codex`, or `scripts/ai` infrastructure inside a client repository unless the user explicitly asks for a repository-local export. Repository-local `AGENTS.md` and repository facts remain more specific than this global guidance.**


These helpers are deliberately read-only or diff-only. They discover facts and produce review leads; they do not replace Xcode build/test, Instruments, security review or engineering judgment. The installable copies live in `REPOSITORY_KIT/repo-root/scripts/ai/`.

- `repo_intake.py` — JSON inventory of projects/workspaces/schemes/settings/CI and heuristic technology signals.
- `discover_xcode.sh` — list shared schemes and project/workspace candidates.
- `swift_risk_scan.py` — scan changed Swift lines for high-risk constructs; output is leads, not defects.
- `verify_diff.sh` — status + `git diff --check` + changed files + risk leads.
- `validate_ai_layer.py` — validate installed skill metadata.
