# Knowledge router — review candidate

This is the single shipped entrypoint for the library's knowledge. Read it first, then load one
common baseline and only the smallest relevant route. Do not paste the complete corpus, all 60
optional skills, or all deep playbooks into context.

## Common baseline

For every task covered by this iOS library, read:

1. `00_META/START_HERE.md`;
2. `GLOBAL_CODEX/runtime/core/QUALITY_STANDARD.md`;
3. `GLOBAL_CODEX/runtime/core/EVIDENCE_AND_VERIFICATION_POLICY.md`.

The repository's own instructions and the user's explicit safety constraints remain authoritative.
Knowledge never grants permission to run commands, use Git, delegate work, change dependencies,
or release an app.

## Route selection

Choose one primary route from the task and repository evidence:

| Task shape | Primary material |
| --- | --- |
| ordinary implementation or bug fix | matching `31_DEEP_PLAYBOOKS/OP-IOS-*` plus the affected numbered section |
| code review or refactor | `38_REPO_WORKFLOWS/V3-WF-02_PR_REVIEW.md` plus the affected numbered section |
| cross-domain task | one playbook for each explicitly evidenced domain, maximum two supporting routes |
| protection, release, or high-risk migration | matching workflow, `50_CLIENT_CODE_PROTECTION/`, and an explicit human gate |
| unclear/unsupported task | stop with `review_required`; do not infer a low-risk route |

The bundled namespaced skills are optional indexes into these documents. `full` mode does not make
all skills mandatory. Review, subagent, and runtime actions are bounded by available tools and the
active task's permissions; unavailable independence must be reported, never simulated.

## External knowledge compatibility

The profile is separate from this immutable corpus and lives at the external state root as
`knowledge-profile.json`. Build or refresh it only with an explicit source root and confirmation:

```text
python3 <runtime>/ios_ai.py profile build --source-root <external-root> --activate --write
```

If the external library uses a different layout, an explicit mapping may be supplied for each
known equivalent path, for example
`--map 03_CONCURRENCY/IOS-03-01_STRICT_CONCURRENCY_MIGRATION.md=concurrency/strict.md`.
Only an exact mapped relative-path and SHA-256 match from a revalidated, explicitly active source
may be marked `disabled_exact_duplicates`. `profile status` always observes the active runtime
library selected by `INSTALLATION.json`; it never adopts a persisted candidate root or an arbitrary
diagnostic replacement. An external `--source-root` must be supplied for the current task before
any exclusions are returned. A persisted `active` flag is eligibility metadata, not proof that the
replacement was selected or read for this task. Changed, missing, malformed, or merely similar
material invalidates the profile or remains an overlap; it never disables a whole section. A clean
installation or a status call without an explicitly selected source has no duplicate exclusions.

## Stop and report

Every route reports selected documents, missing/partial observations, and whether any external
profile was active. The useful outcome is bounded task guidance and evidence, not maximum context
size or automatic fan-out.
