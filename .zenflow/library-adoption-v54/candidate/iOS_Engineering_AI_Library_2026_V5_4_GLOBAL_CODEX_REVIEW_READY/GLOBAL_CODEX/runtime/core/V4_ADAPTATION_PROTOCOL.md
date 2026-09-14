# Project Adaptation Protocol
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


## Phase A — Repository identity
Establish repository root, Git state, project/workspace/package topology and instruction files. Never assume the first `.xcodeproj` is the product entry point.

## Phase B — Target and toolchain inventory
Inspect `project.pbxproj`, shared schemes, test plans, xcconfig files, Package manifests, CI, Fastlane/Make/scripts and optional read-only `xcodebuild -list -json` / `-showBuildSettings` evidence.

## Phase C — Source topology
Measure Swift/ObjC source distribution, test directories, extensions and framework imports. Look for state, navigation, persistence, network, auth, concurrency and observation mechanisms.

## Phase D — Model
Every model datum has a status:
- **observed** — directly present in a repository/config/tool output.
- **derived** — deterministic transformation of observed facts.
- **heuristic** — pattern-based interpretation that can be wrong.
- **unknown** — materially relevant but not established.

## Phase E — Generate
Render project docs and active skill recommendations. Preserve existing hand-maintained `.ai/project/*`; generated files live separately unless a human deliberately promotes facts.

## Phase F — Scoped instructions
Propose nested `AGENTS.md` only where a directory has a coherent responsibility and evidence for local rules. Never blanket-generate one per folder.

## Phase G — Validate
Check JSON schema version, evidence paths, stale source fingerprints, referenced skills and candidate scope collisions. Report gaps rather than fabricating values.
