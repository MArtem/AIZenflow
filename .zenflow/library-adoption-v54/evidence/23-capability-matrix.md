# V5.4 capability matrix — task-local acceptance contract

Дата: **2026-09-14**. Эта матрица описывает продуктовые возможности и границы доказательств.
Она не является разрешением на host mutation и не превращает наличие файлов в доказательство
их загрузки или использования.

| Capability | Entry point | Preconditions / authority | Verification | Current status |
|---|---|---|---|---|
| Canonical knowledge for existing/new projects | Active global instruction entrypoint → canonical bootstrap | Exact host discovery path; preserve local/override precedence; separate read/write authority | Fresh first-entry sessions across existing, empty, imported, worktree, nested and non-Git flows | **PENDING** — host entrypoint and real sessions not inspected/run |
| Manual unpack/connection | `MANUAL_DEPLOYMENT.md` + relocatable `MANUAL_SHIM/bin/ios_ai.py` | Operator copies the versioned payload, verifies hashes, connects the managed AGENTS block, and starts Codex with effective `CODEX_HOME`; no installer execution | Source/extracted parity, relocation test, manual runbook review, fresh-session proof | **SYNTHETIC PASS / REAL PENDING** |
| Installer reference profile | `install_global.py --mode reference` | Dry-run/preflight ID, collision/ownership/path checks, explicit permission to modify user-global Codex configuration | Install lifecycle fixtures, validator, rollback/cleanup semantics | **SYNTHETIC PASS / INDEPENDENT REVIEW PENDING** |
| Installer full profile | `install_global.py --mode full` | Explicit opt-in after matching dry-run; only namespaced `ioslib-*` skills; no collision with user-owned skills | Full-mode preflight and managed-tree validation | **SYNTHETIC PASS / REAL INSTALL PENDING** |
| Runtime protection/session | `ios_ai.py protect begin|verify|close` | Git repository, declared scope, one writer per Git common directory, permitted lifecycle | 156-test suite, state/lifecycle and failure-injection fixtures | **SELF-TEST PASS / REAL CONSUMER PENDING** |
| Advisory review and routing | Global AGENTS block, skills, prompt packs and playbooks | Task-relevant route selected; knowledge never grants execution permission; subagents remain bounded/explicit | Route/skill static inventory and task pilot evidence | **AVAILABLE AS REFERENCE; automatic global route not proven** |
| Package validation | `validate_package.py` | Extracted candidate and declared manifest | `1360 files / 60 skills / 51 sections / 288 playbooks / errors=0` | **PASS** on source and extracted V13 trees |
| Installed-tree validation | `validate_global_install.py` | Synthetic Codex home or explicitly authorized real target | Lifecycle and ownership fixtures | **SYNTHETIC PASS** |
| Update and uninstall | `sync_global.py`, `uninstall_global.py` | Ownership registry, managed hashes, explicit target roots | Pre/post-publication failure, late cleanup, concurrent-change fixtures | **SELF-TEST PASS / INDEPENDENT REVIEW PENDING** |
| Existing-library duplicate handling | Separate compatibility/profile decision | Exact external source identity and hash; semantic overlap is not a duplicate; conflict disables no section automatically | Profile comparison and explicit operator review | **CONTRACT DEFINED; real existing-library inventory pending** |
| iOS domain guidance | 51 knowledge sections, 60 namespaced skills, 288 playbooks | Relevant task route and supported platform profile; unreviewed material is not promoted by selected subset evidence | Domain-specific review/pilot and primary-source verification | **REFERENCE CORPUS; not universal quality guarantee** |

## Parity statement

Manual and installer paths target the same active payload, runtime, namespaced skills and global
instruction contract after successful verification. They do not have identical operational
safety mechanics: the installer adds ownership journaling, automatic rollback and machine-readable
state, while manual deployment relies on operator backup/path/hash checks. Therefore parity means
the same intended runtime result, not identical failure recovery.

## Acceptance rule

Only rows marked PASS by observed evidence may be used as completion claims. `SYNTHETIC PASS`,
`REFERENCE`, `PENDING` and `INDEPENDENT REVIEW PENDING` are deliberately non-equivalent statuses.
The matrix does not claim zero risk, complete defect prevention, kernel isolation, backup of app
source, or automatic adoption by every Codex project.
