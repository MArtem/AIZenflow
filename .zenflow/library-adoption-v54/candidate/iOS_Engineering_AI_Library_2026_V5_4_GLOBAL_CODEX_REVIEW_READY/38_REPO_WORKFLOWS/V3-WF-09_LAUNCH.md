# V3-WF-09 — Launch performance
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


## Outcome
Audit pre-main, app initialization, synchronous I/O and first-frame work.

## Entry
1. Read applicable `AGENTS.md` files.
2. Load `.ai/project/PROJECT_CONTEXT.md`, `TARGET_MATRIX.md`, and `REPO_COMMANDS.md` if present.
3. Select the primary `.agents/skills` skill plus at most 1–3 cross-cutting skills.

## Execution
- capture observed symptom/acceptance criteria;
- classify R0–R4 and state invariants;
- inspect owners, call sites and target/extension blast radius;
- compare alternatives for R2+;
- make the smallest coherent patch or produce prioritized findings;
- verify the highest-risk negative path, not only the happy path;
- review final diff and evidence ledger.

## Domain objective
Audit pre-main, app initialization, synchronous I/O and first-frame work.

## Completion
Report changed files/findings, observed commands/results, inferred conclusions, unknowns, compatibility/rollout and rollback/containment for R2+.
