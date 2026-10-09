# Evidence-Based Engineering Rules

<!-- Rule ID: QC.EVIDENCE.FRESHNESS v1.0 -->

## Purpose
Prevents unsupported claims such as “fixed”, “optimized”, “safe”, or “production-ready”.

## Evidence Rule
Every strong completion claim must include evidence:
- source/code evidence
- build result
- test result
- static check
- simulator/manual verification
- Instruments/profiler metric
- release/CI result
- or explicit remaining risk when evidence is unavailable

Evidence classes do not imply one another. A source/document/diff check, compiled target,
passing test, runtime observation or production cohort supports only its declared scope and
conditions. In particular, a passing test does not establish that every affected app/extension
target builds, that a screen matches its design, or that races and memory leaks are absent.
Negative and failure paths need their own evidence. Missing, partial, stale, failed or skipped
observations remain explicit gaps; another passing check cannot turn them into PASS.

## Forbidden Claims Without Evidence
- “performance improved” without metric or code-level proof and remaining-risk note
- “production-ready” without production readiness gate
- “secure” without security/privacy gate
- “migration safe” without migration reasoning/check
- “accessible” without accessibility review
- “done” without definition-of-done check

## Report Template
- Claim
- Evidence
- Scope
- Verification not run
- Remaining risk

For meaningful completion reports, use the stricter shape in `./docs/COMPLETION_REPORT_CONTRACT.md`.
