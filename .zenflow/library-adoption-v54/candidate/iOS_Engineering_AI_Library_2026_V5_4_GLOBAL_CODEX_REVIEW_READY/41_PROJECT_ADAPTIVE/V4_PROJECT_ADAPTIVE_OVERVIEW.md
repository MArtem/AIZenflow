# V4 Project-Adaptive Edition
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


V4 turns the repository-native V3 layer into a project-specific engineering model. It does not guess a canonical architecture or build command. It inventories evidence, records confidence, generates machine-readable facts, renders human-readable project maps, selects relevant skills, and proposes local instruction scopes.

## Outputs
A V4 adaptation run can create under `.ai/adaptive/`:

- `PROJECT_MODEL.json` — machine-readable repository model with evidence and confidence.
- `ADAPTATION_REPORT.md` — observed/derived/heuristic/unknown summary.
- `generated/PROJECT_CONTEXT.generated.md`
- `generated/TARGET_MATRIX.generated.md`
- `generated/ARCHITECTURE_MAP.generated.md`
- `generated/REPO_COMMANDS.generated.md`
- `generated/RISK_MAP.generated.md`
- `generated/ACTIVE_SKILLS.generated.md`
- `generated/DEPENDENCY_MAP.generated.md`
- `nested-agents/manifest.json` and candidate scoped instruction files.

No product source is modified. Candidate nested `AGENTS.md` files are staged under `.ai/adaptive/nested-agents/` and require explicit human placement.

## Adaptation loop
1. Inventory repository facts.
2. Build the project model.
3. Separate observed evidence from derived and heuristic interpretation.
4. Render project-specific documentation.
5. Select active skills from detected technologies and risk boundaries.
6. Propose scoped agent instructions.
7. Validate model completeness and stale/drift conditions.
8. Re-run after target, CI, dependency, persistence, auth, or architecture changes.

## Non-goals
V4 is not a semantic compiler for arbitrary Xcode projects and does not claim infallible architecture inference. Heuristics remain labelled. `xcodebuild` execution is opt-in because it may be slow and environment-dependent.
