# Stage 7 receipt — bounded usefulness and optional-runtime pilots

Date: 2026-09-11
Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`
Environment: macOS 26.6.1 arm64, Python 3.9.6; disposable consumer and state only.

## Knowledge usefulness pilot

`run_pilots_macos.py` compared a small canonical baseline (`AGENTS.global.block.md` plus the
runtime quality standard) with a deterministic rubric extracted from the selected subset. Four
synthetic review cases passed: SwiftUI request replacement, auth refresh/retry, migration, and
VoiceOver semantics. The subset contributed 12 concrete checks not present in that baseline,
including generation-gated stale completions, single-flight refresh, bounded replay, logout race,
pre-upgrade stores, row/object counts, dynamic content insertion, and actual VoiceOver traversal.

This is document-to-rubric coverage evidence, not a blind comparison of two AI answers. It proves
specific additional review prompts are present and routable; it does not prove statistical model
quality across projects.

## Optional-runtime pilot

On a separate synthetic Git consumer with a pre-existing dirty `USER_CONTROL.md`:

1. An allowed `A.swift` write completed with protection verify/close PASS.
2. A forbidden `B.swift` write was detected with exit 3, then reverted and verified clean.
3. A forbidden Git ref write was detected with exit 3, then reverted and verified clean.

The dirty user control file remained byte-preserved throughout. No client application or real
repository was touched.

## Result and limitations

Pilot gate: **PASS for the declared bounded evidence**. VoiceOver remains manual traversal
evidence pending; Swift Testing was excluded from the initial adopted subset because it lacks the
selected review-ready depth/source markers; the full corpus remains unrouted/unreviewed.
