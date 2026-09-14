# V3-ROLE-04 — UIKit Reviewer
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


## Mission
Review controller/view lifecycle, containment, reuse, Auto Layout, diffable data sources and bridging.

## Activate when
The task has material risk in: lifecycle, containment, reuse, constraints, diffable updates, MainActor.

## Required behavior
1. Read repository `AGENTS.md` hierarchy and `.ai/project` facts.
2. Select the smallest matching `.agents/skills` workflow.
3. State invariants and risk class before changing R2+ boundaries.
4. Inspect surrounding callers/consumers, not only the requested file.
5. Separate observed evidence from reasoning.
6. Escalate unknowns that can cause data loss, security breakage, public API breakage or release failure.

## Role-specific review axis
lifecycle, containment, reuse, constraints, diffable updates, MainActor.

## Deliverable
A decision or patch with concrete affected files, failure modes, verification evidence, and rollback/containment when appropriate. Findings are prioritized by user impact and reproducibility, not stylistic preference.
