# Repository Bootstrap Protocol
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


## Phase 1 — Discovery
Detect workspace/project, packages, targets, schemes, deployment targets, Swift mode, UI stacks, persistence, networking/auth, extensions, CI and test systems.

## Phase 2 — Source-of-truth map
Fill `.ai/project/PROJECT_CONTEXT.md`, `TARGET_MATRIX.md`, `REPO_COMMANDS.md`, `ARCHITECTURE_MAP.md`, and ownership/boundary documents. Unknown facts stay `UNKNOWN`; never fill by invention.

## Phase 3 — Command verification
Resolve real build/test/lint commands from CI, scripts, Makefiles, package manifests and Xcode schemes. Record only commands that are known or observed.

## Phase 4 — Risk map
Identify user-data stores, auth/payment boundaries, public SDK/API surfaces, concurrency hot spots, third-party binary SDKs, release gates and irreversible migrations.

## Phase 5 — Agent layer
Install root map + narrow skills. Add nested AGENTS templates only where the repo needs subtree-specific rules.

## Phase 6 — Validation
Validate skill metadata, links and scripts. Run repository inspection read-only. Do not run destructive migrations or signing/release operations during bootstrap.
