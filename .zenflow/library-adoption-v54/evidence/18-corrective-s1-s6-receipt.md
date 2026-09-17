# Corrective S1–S6 receipt — Luna Xhigh

Date: **2026-09-13**. Scope: V5.4 corrective candidate, task-local proposed knowledge route,
and disposable macOS consumer fixtures. No canonical repository, real Codex home, app consumer,
remote Git, Xcode, Simulator, signing, or release target was changed.

## Inputs and identities

- Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`.
- Candidate source file count: **1,357**; package symlinks and Python bytecode: **none**.
- Original V5.4 input SHA-256: `7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce`.
- Original extracted V5.4 → current candidate comparison: **14 changed files**; this count was
  measured by `diff -qr` and is not treated as a completeness proof by itself.
- Canonical documentation base checked by the proposed patch:
  `cb8ffedf7e5c032478e36fa8f2f1e751952ad76b`.
- Proposed route patch SHA-256:
  `6971fcd509e9f48570a2d8bf8ad629643399726a1c0ed856f9957e5b7a305cc1`.
- Proposed profile SHA-256:
  `40c7bb0de641a09747870fc498918a0deff339b0ccc09c42a900e4c0a189b985`.

## Corrective findings and gates

| Finding | Result | Evidence boundary |
|---|---|---|
| A54-R1 P1 late backup cleanup could destroy a published install | **CLOSED in candidate** | Post-publication cleanup is no longer rollback-triggering; incomplete cleanup returns explicit exit 5 and preserves published content/shim/registry. Covered by `test_F10_late_backup_cleanup_failure_preserves_published_state` with two backups. |
| A54-R2 P2 final scanner validation could finish after deadline and return success | **CLOSED in candidate** | Deadline checked after record validation and before success; slow-final-validation and per-file 4 MiB boundary tests pass. Cooperative checkpoint only, not a hard syscall interrupt. |
| A54-R3 P2 identity regression test was weak | **CLOSED in candidate** | Private-mode same-bytes/different-inode replacement fixture passes for identity mismatch; bounded in-memory bypass proof produced `MUTATION_BYPASS_FAILURES=1`, so the test is sensitive to removing the protection. |
| A54-R4 L2 packets/keys were not frozen | **CLOSED as an evaluated gate** | Separate T1/T2/T3/holdout inputs and answer keys are SHA-pinned; eight scored fresh outputs are stored under `evidence/l2-pilot-20260913/results/`. Frozen utility verdict is `NO_DEMONSTRATED_GAIN` because measured input overhead is 236.8–244.0%, above the ≤50% threshold. |
| A54-R5 knowledge integration was prose-only | **Prepared; real promotion pending** | Applyable canonical patch, integrity-pinned seven-document route, disable semantics, and disposable consumer rehearsal are present. Canonical patch remains unapplied. |

## S1/S2/S3 candidate verification

Observed commands and results:

```text
PYTHONDONTWRITEBYTECODE=1 python3 -B tests/run_all.py
REVIEW_READY_TEST_SUMMARY total=143 pass=143 fail=0 skip=0

PYTHONDONTWRITEBYTECODE=1 python3 -B validate_package.py
Review-ready package validation: files=1357 skills=60 sections=51 playbooks=288 errors=0

PYTHONDONTWRITEBYTECODE=1 python3 -B evidence/run_runtime_matrix_macos.py
allowed=9/9 PASS; reject_or_incomplete=8/8 PASS; platform=macOS; Python=3.9.6
```

The source candidate contains these current corrective identities:

| File | SHA-256 |
|---|---|
| `GLOBAL_CODEX/runtime/bin/ios_ai.py` | `ac70bf3d73ae3db099d49fabb809fb460cc4eae21f6790e2dd47f5c558e0850a` |
| `GLOBAL_CODEX/runtime/protection/protection.py` | `bae8f4703cc9aa5876d42b6cd00f9f4068777a685a84afae369868dc399eeae6` |
| `sync_global.py` | `80b8c8ff2fa292a9e33129194d2b6cb7ed91f9ffc409298489eaaa09174d1c65` |
| `tests/test_review_ready.py` | `054c169fd28afc5f7abe4c6dda5c6cc8544ae01a771135201e6f02d4db07d493` |

The current manifest/report/matrix are synchronized to 143/143 and the candidate validator
passes. `git diff --check` passes for the candidate delta.

## S4/S6 knowledge-route and consumer rehearsal

The proposed route is `ios-library-pilot-v54`; it contains PROFILE plus seven existing reviewed
documents for task-local concurrency, SwiftUI state/identity, auth refresh/retry, and
authentication. It is optional advisory knowledge, not Level 0, not a permission boundary, and
not a full 60-skill install. Route integrity uses SHA-256 and skips the route on missing, symlink,
oversized, or altered payload while retaining the ordinary baseline.

`git apply --check` against canonical base `cb8ffedf7e5c032478e36fa8f2f1e751952ad76b`: **PASS**.
The patch is the control-plane change; the exact canonical-source/distribution-mirror payload
copy is deliberately separate and frozen in `proposed-integration/payload-import-manifest.json`.

Disposable route rehearsal:

```text
route_patch_check=PASS
baseline_route: exit=0, documents=3, failures=[]
enabled_route: exit=0, documents=8, failures=[]
disabled_route_not_resolved=true
disabled_route_baseline_preserved=true
reenabled_route: exit=0, documents=8
altered_profile_skips_route=true
overlay_optional_document_skips_route=true
consumer_git_state_preserved=true
```

Disposable knowledge/runtime pilot:

- four deterministic domain cases PASS with **12 additional domain-specific checks**;
- method is explicitly document-to-rubric coverage, not blind model evaluation;
- allowed source write PASS;
- forbidden source write and forbidden ref mutation detected with exit 3;
- rollback after each violation PASS;
- dirty user-owned control sentinel preserved.

The expanded route scenario matrix contains 14 expected outcomes: 11 PASS checks, two
`CONTRACT_ONLY` cases (non-iOS and linked-worktree behavior is outside this resolver's observed
surface), and one `NOT_EXECUTED` case (runtime opt-in is intentionally separate).

All fixture roots and state remained under `/Users/Artem/.zenflow`. The rehearsal does not prove
agent adherence, process-level interception, whole-Mac safety, universal project coverage, or
quality improvement across arbitrary codebases.

## Current status

- Candidate runtime/installer fixes: **bounded candidate PASS**; independent control-plane review
  completed with the advisory-integrity residual recorded in stage 20.
- Knowledge route: **disposable integration PASS**, proposed canonical promotion only.
- L2 blind A/B utility: **EXECUTED; NO_DEMONSTRATED_GAIN** under frozen ≤50% overhead gate.
- Provenance/license/redistribution: **UNKNOWN**.
- Real consumer and global activation: **NOT EXECUTED**.
- iOS/Xcode/device/Simulator/UI/signing/release evidence: **OMITTED by scope**.

This receipt supersedes broad current-status claims in stages 05, 13, 14, and 17 where they
predate the A54 corrective work; those historical receipts remain preserved for traceability.
