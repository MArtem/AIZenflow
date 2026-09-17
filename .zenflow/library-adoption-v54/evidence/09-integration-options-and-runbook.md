# Stage 9 receipt — integration options and operator runbook

Date: 2026-09-11
Candidate archive SHA-256: `900329bae58e596ca8d7549bec0bf0be38fa87d30000f41611360cdc0169af4c`

## Recommendation

Choose **A — no-install knowledge reference-only** for the first internal adoption decision.
The candidate's runtime passed the disposable acceptance envelope, but the artifact still needs
independent re-review and licensing/provenance clarification. Option A gives useful, bounded
knowledge immediately without changing global Codex configuration or adding a new write gate.

## Options

### A — knowledge reference-only (recommended now)

Source of truth is the immutable, version-pinned candidate archive stored outside every client
repository. Route only the 12-document subset in
`06-knowledge-adoption-map.md`; treat every document as advisory and keep project/user/system
rules authoritative. Do not run `install_global.py`, `sync_global.py`, or `uninstall_global.py`.

Operator sequence:

1. Keep the archive in an approved internal path outside client repositories and record its SHA.
2. For a task, reference only the selected absolute document paths with an explicit “advisory
   knowledge; no permission” instruction.
3. Use existing project protection/build/test rules and collect evidence under the project task.
4. To disable, stop referencing the archive; retain or archive the pinned copy for reproducibility.

Trade-off: no automatic context/runtime protection or skill discovery. This is intentional until
the runtime and provenance gates are closed.

### B — knowledge plus optional runtime (later pilot)

Source of truth remains the pinned archive; runtime state belongs in the approved external state
root, never in a client repository. This mode requires a separately approved synthetic/real
Codex-home path, independent re-review, provenance decision, and explicit consent to modify the
managed global AGENTS block. It installs reference mode only and keeps the 60 skills out of the
global namespace.

Dry-run/apply/verify sequence for a separately approved target (not executed here):

```bash
python3 validate_package.py
python3 tests/run_all.py
python3 install_global.py --mode reference \
  --codex-home <approved-codex-home> \
  --runtime-root <approved-runtime-root> \
  --skills-root <approved-skills-root> \
  --agents-file <approved-codex-home>/AGENTS.md \
  --dry-run
python3 install_global.py --mode reference \
  --codex-home <approved-codex-home> \
  --runtime-root <approved-runtime-root> \
  --skills-root <approved-skills-root> \
  --agents-file <approved-codex-home>/AGENTS.md
python3 validate_global_install.py --codex-home <approved-codex-home>
```

Before apply, inspect every reported path/collision and preserve a recoverable AGENTS/state
baseline. After apply, read the generated `ios-engineering-shim/INSTALLATION.md` and run one
bounded pilot task. Roll back with `uninstall_global.py --dry-run`, then `--yes` only when the
preflight reports no modified/unknown managed content. Never delete external session history to
force a green uninstall.

### C — full global activation (not recommended yet)

This is the explicit opt-in path that adds all 60 namespaced `ioslib-*` skills and the managed
global instruction layer. It requires all B gates plus owner approval of global precedence,
staged rollout/disable, and a current license/provenance decision. Use a matching full dry-run
preflight id:

```bash
python3 install_global.py --mode full --codex-home <approved-codex-home> \
  --runtime-root <approved-runtime-root> --skills-root <approved-skills-root> \
  --agents-file <approved-codex-home>/AGENTS.md --dry-run
python3 install_global.py --mode full --codex-home <approved-codex-home> \
  --runtime-root <approved-runtime-root> --skills-root <approved-skills-root> \
  --agents-file <approved-codex-home>/AGENTS.md \
  --preflight-id <exact-id-from-dry-run>
python3 validate_global_install.py --codex-home <approved-codex-home>
```

Any collision, modified managed asset, state-marker mismatch, or failed validation is a stop,
not a reason to bypass the preflight. Disable/rollback follows the B uninstall sequence.

## Canonical integration changeset (prepared, not applied)

- Add the pinned archive location and SHA to the internal documentation owner record, not to any
  client repository.
- Add the 12-document adoption map to the process router as advisory routes; leave all other
  corpus material unrouted.
- Preserve the existing canonical rules as the higher-priority authority; do not copy the
  package's global AGENTS block into project-local docs.
- Require the library's protection session only for an explicitly approved optional-runtime
  task; do not make it a hidden permission layer.
- On update: new archive SHA → delta review → affected runtime/knowledge checks → pilot → explicit
  promotion. On rollback: retain external state/session evidence and revert only owned managed
  assets after a clean preflight.

## Owner decisions required

1. Select A, B, or C; current recommendation is A.
2. For B/C, name the exact approved global Codex home, skills root, runtime root, and AGENTS file.
3. Resolve whether the missing LICENSE/NOTICE/SPDX and source commit are acceptable for internal
   use; do not publish or redistribute while UNKNOWN.
4. Obtain independent re-review of the final seven-file candidate delta.
5. Set supported macOS/Python and iOS/Swift/Xcode profiles; no iOS app compile/device evidence is
   included in this candidate review.
