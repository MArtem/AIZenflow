# Stage 3 receipt — legacy registry/process/privacy hardening

Date: 2026-09-11
Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`
Input ZIP SHA-256: `7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce`

## Change contract

- Legacy V5.2 `closed` records remain archival-only and byte-preserved.
- Legacy V5.2 `active`/`verified` records sharing a Git common directory block admission, while remaining inadmissible as current sessions.
- Registry observation must not materialize an unbounded directory listing or claim completeness after exceeding an input/time envelope.
- Malformed, foreign, symlinked, unreadable, or over-budget state fails closed.

## Candidate delta

- `GLOBAL_CODEX/runtime/bin/ios_ai.py`: added a read-only legacy-active scanner mode, streaming `os.scandir` traversal, aggregate limits of 10,000 repository entries, 10,000 session entries, 32 MiB of session JSON, and 10 seconds of observation, plus normalized iteration errors.
- `tests/test_review_ready.py`: strengthened the existing A53 active/verified regression assertion to require the shared Git common-directory blocker message; test count remains 134.
- `GLOBAL_ARCHITECTURE.md`, `GLOBAL_MANIFEST.json`, `REVIEW_READY_VALIDATION_REPORT.md`, and `REVIEW_FINDINGS_MATRIX.md`: synchronized the bounded-scan contract and residual finding disposition.
- `PACKAGE_FILE_MANIFEST.json`: refreshed hashes and sizes for modified package files.

## Evidence

- `validate_package.py`: PASS — `files=1357 skills=60 sections=51 playbooks=288 errors=0`.
- Full isolated candidate suite: PASS — `REVIEW_READY_TEST_SUMMARY total=134 pass=134 fail=0 skip=0`; macOS 26.6.1 arm64, Python 3.9.6, approximately 22.00 seconds.
- `check_registry_bounds_macos.py`: PASS — repository, record, and byte budgets each refused with the expected `ProtectionError`; malformed private JSON refused with `ProtectionError`.
- Prior macOS measurement: 10,000 closed records were approximately 6.39 MB and scanned in approximately 3.95 seconds with zero blockers.
- `git diff --check`: PASS for the worktree task changes; candidate package manifest and JSON files were parsed successfully.

## Residual risk / disposition

- The candidate remains `review_candidate_independent_review_required`; this receipt is not an independent acceptance.
- Licensing/provenance remains an open adoption gate because the supplied artifact has no detected LICENSE/NOTICE/SPDX declaration and no source commit.
- No global install, real Codex-home mutation, client-repository mutation, Xcode build, signing, Simulator/device run, or external publication was performed.
