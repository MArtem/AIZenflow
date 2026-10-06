# Candidate startup rule for copy-only reference

This rule is **dormant by default**, not an installed hook. It takes effect in a new chat only
when a separately approved project-local instruction explicitly selects this copy-only library.
That selection is scoped to the named project; it does not enable another project or a global
Codex feature. Merely copying this file does not activate it, change Codex settings, or write a
project status record.

When selected for an iOS project:

1. Read current user and project-local rules, task state and relevant local knowledge first.
   Their permissions and project conventions remain authoritative.
2. Resolve the selected Xcode project's external status according to
   [PROJECT_MODE.md](PROJECT_MODE.md). Display `IOS Library: ON/AUTO`, `ON/ADVISORY`, `OFF`,
   `UNSET/invalid`, or `UNKNOWN` as observed in the first meaningful status response.
3. For `UNSET/invalid`, ask once whether the user wants ON. Continue with the complete local
   quality workflow as OFF until explicitly answered. Never silently create, repair or inherit
   a status record.
4. For OFF, perform the full task-appropriate local inspection, implementation/verification
   decisions and whole-change review. OFF is not a shortcut.
5. For ON, perform that same local work **first**, then use the project's reference profile from
   [PROJECT_MODE.md](PROJECT_MODE.md). Default `AUTO` applies the smallest evidenced route from
   [KNOWLEDGE_ROUTER.md](KNOWLEDGE_ROUTER.md) at each applicable stage within existing authority;
   `ADVISORY` reports the route's checks and recommendations without claiming they ran. Resolve
   actual findings, recheck changed boundaries and review the complete final artifact set before
   user handoff when implementation is authorized.
6. State observed evidence, unrun checks and remaining risk. Missing or unreviewed specialist
   material never becomes PASS. A later artifact change invalidates the previous final review.

`reference on/off/auto/advisory` changes only this project's future reference passes after an
explicit user request. No mode or profile changes authority for files, tests, builds, Git, network, dependencies,
signing, release or the user's final review/PR decision.

## Future project-local entrypoint (not installed)

For a separately approved pilot, copy only the exact reviewed release payload into a chosen
project-local directory and add a short reference to this file in that project's existing
`AGENTS.md` **after** its local/canonical instruction chain. Copying files without that explicit
entrypoint cannot make a fresh chat load the library. Do not replace the existing `AGENTS.md` or
put this block in a global Codex instruction file. The final relative library path and affected
`.xcodeproj` must be resolved from the approved project at activation time; neither may be
inferred from this draft.

The minimal project-local block should say: apply all existing project and canonical rules first;
then read `<relative-library-dir>/STARTUP_RULE.md` once per chat, identify the exact affected
`.xcodeproj`, and use `python3 <relative-library-dir>/tools/reference_mode.py status --root
<exact-repository-root> --project <repository-relative-project.xcodeproj>` only for that project.
Report `ON`, `OFF`,
`UNSET/invalid`, or `UNKNOWN` before the first reference pass. If there are multiple plausible
projects, an unresolved root, a failed status command, or no valid record, do the complete local
workflow as OFF and ask the user once; never infer ON. A fresh chat must not replay `on`, `off`,
`auto`, `advisory`, or `recover` from task history. Recovery is disabled; a user request does
not bypass that restriction. Other state transitions require an explicit current user request.
Run no build, test, agent, Git or external action because of
this entrypoint alone.

Before any pilot-ready claim, verify the copied file hashes and this entrypoint in a new chat
for the exact project, then observe ON/OFF and invalid-status cases. This section is a template
for a future approved change, not authority to make that change now.
