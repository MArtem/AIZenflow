# Context Hygiene Policy
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


1. Start with root `AGENTS.md` and project context index.
2. Load the smallest matching skill.
3. Load only the referenced project/domain files needed for the current task.
4. Do not bulk-load all 288 deep playbooks.
5. Prefer repository facts, generated maps and exact call sites over generic prose.
6. Summarize large files before loading adjacent references.
7. Keep assumptions explicit and discard them when contradicted by evidence.
8. Do not re-read static documents repeatedly in one task unless they changed.
9. For cross-cutting work, compose 2–4 skills; avoid activating the whole library.
10. After the task, record durable project knowledge in `.ai/project`, not in an ever-growing root prompt.
