# Library Map — V5 Global Codex Hardened

- **60** user-global Codex skills.
- **51** numbered knowledge sections.
- **288** Deep Playbooks.
- **1267** indexed Markdown assets.

## Operational layers
1. `GLOBAL_CODEX/AGENTS.global.block.md` — global activation + mandatory safety rules.
2. `GLOBAL_CODEX/skills/` — global workflows, including `ioslib-client-code-protection` and `ioslib-safe-command-execution`.
3. `GLOBAL_CODEX/runtime/bin/ios_ai.py` — global runtime CLI.
4. `GLOBAL_CODEX/runtime/protection/protection.py` — Git/worktree/nested-repo/command protection engine.
5. `GLOBAL_CODEX/runtime/vendor/adapt_project.py` — metadata-only, read-only project adaptation.
6. `50_CLIENT_CODE_PROTECTION/` — full threat model and safety protocols.
7. `00_META`–`49_V5_AUDIT_GATES` — engineering knowledge, deep playbooks, prompts, workflows, roles, templates and gates.

Client repositories are consumers, not hosts, of this library.
