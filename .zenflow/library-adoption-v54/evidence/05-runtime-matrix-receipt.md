# Stage 5 receipt — independent runtime contract matrix

Historical receipt. The current corrective runtime matrix is recorded in
`18-corrective-s1-s6-receipt.md`; the older 134-test wording below is retained for provenance.

Date: 2026-09-11
Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`
Environment: macOS 26.6.1 arm64, Python 3.9.6, synthetic Git repositories and external state
roots only.

## Matrix result

`run_runtime_matrix_macos.py` exercised public `ios_ai.py` entrypoints with explicit state roots.

- Allowed: **9/9 PASS** — doctor, safe guard classification, declared-policy authority flags,
  external-state path, advisory build-phase scan, unchanged protection begin/verify/close, and
  an allowed scoped source change.
- Reject/incomplete: **8/8 PASS** — mutating guard command, unknown guard argv with secret-like
  token non-retention, dirty path outside scope, Git config mutation, index mutation without a
  declared transition, ref mutation, nested-repository mutation, and missing context freshness.
- Protection verification returns `ok:false`, a non-PASS status, and violations with exit 3;
  the matrix records the actual `DETECTED_AFTER_MUTATION` contract rather than requiring a
  generic status name.
- Guard returns exit 2 and `REVIEW_UNSUPPORTED` for advisory rejects; it is not treated as an
  executor or OS enforcement boundary.

## Scope boundary

This matrix is a bounded contract sample, not a completeness claim for all iOS repositories or
all possible command/build surfaces. The shipped 134-test suite remains required evidence for the
broader regression set.

Result: **PASS** for the declared runtime matrix; global activation remains unperformed.
