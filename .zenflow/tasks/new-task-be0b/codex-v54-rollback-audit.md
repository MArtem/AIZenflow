# V5.4 Codex rollback audit — evidence and open checks

Historical snapshot from before final current-tree publication and the
post-runtime-move fresh-chat check. Do not use its pending/uncommitted claims as
current state; see `v54-retirement-published-status.md` and current `handoff.md`.

Status: read-only inventory, 2026-09-26. This is not a claim that every Codex preference has
factory values. The user confirmed a **targeted rollback of proven V5.4-owned effects**, while
preserving pre-existing user configuration, chats, plugins, credentials and useful knowledge.

| Surface | V5.4 capability | Observed state | Disposition |
| --- | --- | --- | --- |
| Global `~/.codex/AGENTS.md` | Host entry could write a managed block | Exact installed-only file backed up under `codex-recovery/2026-09-26/`; old path absent; fresh chat saw no global entry | Rolled back, recoverable |
| Canonical bootstrap | Earlier automatic route to installed V5.4/runtime | Exact removal committed as `8cf5803` and remote `main` matched; ordinary baseline remains; fresh chat did not load installed layer | Rolled back and published |
| Ignored `.codex-runtime/ios-engineering` | Runtime, descriptor, shim and state | Exact eight-file subtree moved to recovery after full app restart; former path remains absent; managed hashes matched | Quarantined, recoverable; no post-move fresh-chat check |
| `~/.codex/config.toml` | Possible configuration surface | Exact file exists; targeted marker search found no `ios-engineering`, `ioslib-`, `GLOBAL_CODEX` or `v5.4` references | Unchanged; no reset justified |
| Global namespaced `ioslib-*` skills | Optional full-mode installation | Recovered registry says `mode: reference`, `skills_to_install: []`, and empty skills ownership; no `ioslib-*` entries in checked host skill roots | No deletion justified |
| Alternate host entry/shim/state | Possible installation destinations | Exact `~/.codex/AGENTS.override.md`, `ios-engineering-shim` and `ios-engineering-state` paths absent in current check | No deletion justified |
| Auth/Keychain | Not a legitimate knowledge-layer dependency | Not inspected or modified during rollback | Preserve; do not inspect or reset without a separate precise decision |
| Other Codex settings, plugins, chats and caches | Not proven V5.4-owned | Not inventoried as V5.4 changes | Preserve; broad factory reset prohibited by current evidence |

The tracked V5.4 release documents describe installers, runtime/shim, global AGENTS routing and
optional namespaced skills. They establish **possible** write surfaces, not proof those writes
occurred on this host. The recovered registry specifically identifies the `reference` install,
the canonical ignored runtime home, no installed skills, and the host-entry receipt identifies
`~/.codex/AGENTS.md`. The quarantined metadata and exact checks establish the narrower observed
set above. No installer/uninstaller or host-mutating tool was run for this audit. The tracked
V5.4 tree remains useful historical source and is not itself an active Codex installation merely
because it exists.

Next bounded checks: (1) inspect exact current instruction-entry paths and explicitly named
V5.4 markers without opening credentials; (2) compare all recoverable installation receipts
against current paths and distinguish absent, owned and unknown; (3) obtain a fresh-chat result
after the runtime move. Do not delete an unknown file,
reset `config.toml`, touch Keychain/auth, or clear user data to make a scan look clean.

The exact canonical bootstrap diff removed only the former V5.4 auto-route and runtime exception.
`git diff --check` and the task-worktree bootstrap checker passed. An earlier failure came from
running that *project* checker at the documentation-vault root, which lacks project-local
`scripts/` and `docs/` files; it was not a bootstrap regression. The canonical vault checker
currently reports stale manifests because the incomplete untracked reference candidate changes
the file inventory. The isolated rollback was committed as
`8cf58031e49194c4745eb6c016085177358339f0`; remote `main` matched exactly. The incomplete
reference candidate was not staged or published.
