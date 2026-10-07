# IOS Library — draft copy-only quick start

This is the no-install successor to the useful part of V5.4 `QUICKSTART.md` and
`PROJECT_REFERENCE_OPT_IN.md`. The candidate is **not ready for general adoption**: its
allowlist, semantic coverage and comparison evidence are still under review. An explicitly
approved, scoped project pilot is not a general release or an installed Codex feature.

1. Start with the current user request, project `AGENTS.md`, task context and local knowledge.
   They define authority and project conventions. A reference file never supersedes them.
2. Resolve the exact Xcode project's external ON/OFF status using [PROJECT_MODE.md](PROJECT_MODE.md).
   A missing/invalid status is `UNSET`: display it, ask once, and continue the complete local
   quality workflow as OFF until the user chooses. No Codex global setting or host file is read
   or changed merely to consult reference.
   The proposed [mode handler](tools/reference_mode.py) is not automatically invoked. Once an
   explicit project-local entrypoint is approved, it can invoke
   `python3 <copied-library>/tools/reference_mode.py status --root <repo-root> --project <relative-Project.xcodeproj>`
   read-only. `on`, `off`, `auto`, `advisory`
   require the user's explicit request for that one project. `recover` is disabled and preserves
   the record unchanged, even with an explicit mode choice. A failed
   command is `UNKNOWN`, never evidence that a mode transition succeeded; re-read status.
3. For OFF, do all task-appropriate local inspection, implementation, verification decisions
   and complete final review. For ON, do the same local work **first**, then use
   [KNOWLEDGE_ROUTER.md](KNOWLEDGE_ROUTER.md) at each applicable stage. `AUTO` applies permitted
   in-session checks; `ADVISORY` explains recommended checks without claiming they ran.
4. For builds, tests, Simulator, agents, Git, network, dependency, signing, release and other
   consequential steps, consult [RISK_AND_EVIDENCE.md](RISK_AND_EVIDENCE.md): say whether the
   step is worthwhile, what it will prove, its minimal scope/cost and permission status. ON
   grants no new command or file authority.
5. Present observed results, findings and unknowns. A code/resource/project diff changed after
   final review needs another complete final check before a ready-for-user-review claim.

Future adoption means copying **only the reviewed files in an exact release allowlist** for an
explicit project task. Do not copy this entire migration directory, place former `ioslib-*`
skills in Codex global skill roots, run V5.4 scripts, add hidden `.ai/` infrastructure, change
`config.toml`, edit auth/Keychain or replace global `AGENTS.md`. **IOS Library** is the chosen
name, not a readiness or activation claim. The project-local activation boundary still requires
review and explicit approval. The dormant
[project-local entrypoint template](STARTUP_RULE.md#future-project-local-entrypoint-not-installed)
describes the additional explicit `AGENTS.md` reference needed for fresh chats; it is not active
merely because the payload was copied.
