# Global Architecture — V5.4 Review Ready

```text
Review-ready package (source)
├── GLOBAL_CODEX/
│   ├── AGENTS.global.block.md
│   ├── KNOWLEDGE_ROUTER.md              one shipped first-entry knowledge route
│   ├── skills/ioslib-*/                 60 optional full-mode skills
│   └── runtime/
│       ├── bin/ios_ai.py                safe CLI façade
│       ├── protection/protection.py     observation/session/guard primitives
│       └── vendor/adapt_project.py      bounded metadata-only adapter
├── 00_META ... 50_CLIENT_CODE_PROTECTION/  knowledge and policies
├── tests/                               synthetic standard-library suite
├── install_global.py                    preflight + transactional install
├── sync_global.py                       manifest-aware transactional update
└── uninstall_global.py                  ownership-aware removal

Configured Codex user scope (never the client repo)
├── <AGENTS destination>                 existing bytes + one managed block
├── <runtime/shim root>/                 managed façade + INSTALLATION.json selector + INSTALLATION.md
├── <state root>/                        private external state
│   └── <repo-key>/
│       ├── context/                     metadata only
│       └── protection/sessions/<id>.json
└── <skills root>/ioslib-*               full mode only

Client repository
├── app/project/test/config files         changed only for the user's task
├── local AGENTS.md                       more-specific project instruction layer
└── no library infrastructure/state
```

## Authority and precedence

Runtime authority, user/project instruction authority, and knowledge authority are distinct. Bundled Markdown/skills provide knowledge and workflow guidance; they do not grant permission to execute commands. More-specific project-local instructions govern project conventions, subject to higher-priority system/developer/user constraints. A repository README/CI/script/AGENTS-like text discovered by the adapter is treated as repository-derived data, not as an automatic permission expansion.

## Reference vs full

`reference` is the default **installer** pilot mode: runtime + knowledge reference + minimal global instruction layer, with no takeover of the global skills namespace. It is not passive because it changes user-global Codex configuration. `full` is explicit opt-in and requires a matching full-mode preflight ID; only `ioslib-*` skill targets are considered. For evaluation that must not change global instructions, `PROJECT_REFERENCE_OPT_IN.md` defines a separate no-install advisory workflow.

`MANUAL_DEPLOYMENT.md` is the manual counterpart to the installer. It keeps the versioned payload
in an external directory, installs the same relocatable shim, optionally copies the same namespaced
skills, and connects the same global instruction block without invoking installer code. Both paths
consume the same data-only `INSTALLATION.json` contract and external state boundary; transaction
ownership and automatic rollback remain installer conveniences that the manual operator replaces
with a read-only preflight, inspected backup and explicit path/hash checks.

Both modes publish a generated, managed `ios-engineering-shim/INSTALLATION.json` selector. It records
the exact release/protection identities, runtime CLI, knowledge root and external state root, so
reference-mode knowledge discovery does not depend on a guessed source path. `INSTALLATION.md` is
human-readable explanation only; the install validator checks both against the ownership registry.

## Transaction boundary

Before the first installation mutation, preflight resolves and validates source identity, Codex home, AGENTS destination, skill/runtime/state roots, collisions, ownership marker, local modifications, namespace, and proposed operations. Fresh install/update uses staging plus rollback logic. Managed files are hash-tracked; unmanaged or locally modified managed content is never silently destroyed.

## Protection boundary

Each protection session has a unique ID, schema/version, repository identity, immutable initial baseline, declared path scopes and explicit Git transitions. There is no shared `BASELINE.json` that a later begin can overwrite. Incomplete observation cannot create a valid PASS.

A snapshot includes Git identity/HEAD/tree, individual refs, local config fingerprint, semantic index entries, changed/staged paths, dirty content hashes and nested repository state. Commit transitions compare baseline tree to current tree and do not implicitly permit config, branch, unrelated ref, staging, protected-path or out-of-scope changes.

## Secure external state

State writes reject symlink components/final symlinks, use no-follow/open-directory semantics where the platform supports them, create private temporary files, fsync and atomically publish within a verified directory. Failure to establish required privacy/containment fails closed.

## Resource bounds

Protection, adaptation and legacy scanning use explicit file/byte/output/time/depth budgets. Budget exhaustion, unreadable input, malformed subprocess output, timeout, truncation or partial scan is an incomplete observation and therefore non-PASS/non-fresh.

## Honest guarantees

- **Prevention:** only actions actually rejected before mutation (for example installer collision/symlink/ownership failures and secure state-write refusal).
- **Detection:** session verification observes after-the-fact repository state differences.
- **Advisory:** command/build/risk/knowledge analysis does not intercept arbitrary execution.

No claim is made of kernel sandboxing, source backup/recovery, complete ignored-file protection, or detection of a transient write that is fully restored before the next snapshot.

## Writer-session invariant

The protection runtime supports **one writer session per Git common directory**. Lifecycle transitions and writer admission use a private `flock`-protected common-dir registry plus a persistent writer lease on supported POSIX systems. Linked worktrees have distinct worktree identities but share ordinary `refs/*` and repository config, so they are deliberately serialized into the same writer slot. Concurrent writers require independent repositories/clones with different Git common directories. Session schema 3 encodes the current writer contract. Valid V5.2 schema-2 sessions with lifecycle `closed` are accepted only through a read-only archival compatibility reader: their UUID, baseline hash, repository identity and audit structure are validated, they never acquire a writer lease, and their historical verification is not promoted to current evidence. V5.2 `active`/`verified` sessions sharing the current Git common-dir remain fail-closed and must be explicitly resolved with the V5.2 runtime before writer admission. The legacy registry scan is itself bounded and fail-closed per admission attempt: at most 10,000 repository entries, 10,000 session entries, 32 MiB of session JSON, and 10 seconds of observation are allowed; exceeding any envelope refuses admission rather than claiming a complete scan.

## Command identity and privacy

`ALLOW_READ_ONLY` for `git`/`pwd` requires a trusted executable identity, not only a basename. Arbitrary relative executable paths and PATH-resolved executables outside conservative system roots remain `REVIEW_UNSUPPORTED`. Guard diagnostics use fixed reason codes/text and do not echo unknown executable, option, or subcommand tokens.

## Observation completeness

Installer/package traversal follows the same fail-closed rule: unexpected directory-walk errors cannot silently reduce the ownership/package tree while preserving a successful result.

Unexpected directory-walk/scandir errors make protection/build observation incomplete and make adapter context partial. Stable partial context is never fresh. Subprocess observation cleanup covers the whole post-`Popen` lifetime; total-deadline exceptions terminate/reap the owned child, with POSIX process-group termination used for inherited descendants that have not deliberately escaped that group.
