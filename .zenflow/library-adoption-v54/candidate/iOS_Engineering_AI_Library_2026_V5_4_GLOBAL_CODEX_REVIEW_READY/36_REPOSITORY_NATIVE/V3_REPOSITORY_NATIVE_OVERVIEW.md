# V3 Repository-Native Edition
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


V3 превращает библиотеку V2 в слой инженерного управления, который можно установить непосредственно в iOS-репозиторий.

## Цель
Не заставлять coding agent помнить сотни страниц. Корневой `AGENTS.md` работает как карта, `.agents/skills` — как маршрутизируемые operational skills, `.ai/project` — как project-specific source of truth, а полная V2/V3 library загружается только по необходимости.

## Слои
1. **Repository map** — короткий `AGENTS.md`.
2. **Project truth** — `.ai/project/*.md`.
3. **Executable skills** — `.agents/skills/<skill>/SKILL.md`.
4. **Deterministic helpers** — `scripts/ai/*`.
5. **Deep knowledge** — optional `.ai/ios-library` (full profile).
6. **Evidence contract** — build/test/diagnostic claims only from observed output.

## Инварианты V3
- repository facts beat generic best practices;
- nested `AGENTS.md` may narrow rules for their subtree;
- context is progressively disclosed;
- skills are narrow enough to trigger predictably;
- scripts automate deterministic inspection, not engineering judgment;
- no destructive write is performed by bootstrap tools unless explicitly requested;
- project commands are discovered and recorded rather than guessed;
- high-risk changes require rollout/rollback and evidence proportional to risk.
