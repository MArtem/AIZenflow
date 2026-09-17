# L0 correction notes and acceptance matrix

Date: 2026-09-12. Executor: GPT-5.6 Luna xhigh. This document supersedes the broad completion
interpretation in the earlier stage receipts; it does not invalidate the narrower observations
that those receipts actually recorded.

## Candidate identity

| Item | Observed value | Scope |
|---|---|---|
| Input ZIP | `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY.zip` | User supplied; immutable input |
| Input ZIP SHA-256 | `7013500596533af138c857d4e98471f9108ffe3c6eaae4055400e439e3f522ce` | Intake identity |
| Candidate root | `.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY` | Isolated working copy |
| Candidate runtime SHA-256 | `d27f6db6b80b5755e1c90fa36155334839fb703c1b01c52d74a591101ee4c6f1` | Candidate `ios_ai.py` |
| Candidate test SHA-256 | `04d6b6f74cd15ab3d2c80db676a5b06d6ac53d380e49c619ab8c1d818ff040ce` | Candidate `test_review_ready.py` |
| Candidate manifest SHA-256 | `16e70e5c6082bd52a90932b687c5a34b4831fcb545ddd246c7361d906a2d1adc` | Candidate `GLOBAL_MANIFEST.json` |
| Existing candidate ZIP SHA-256 | `900329bae58e596ca8d7549bec0bf0be38fa87d30000f41611360cdc0169af4c` | Prior local dist; not a new release |
| Package status | `review_candidate_independent_review_required` | Not an acceptance or release status |

No commit or remote branch identifies the supplied library. The manifest has
`source_commit: null`, and no `LICENSE`, `NOTICE`, `COPYING`, or SPDX declaration was detected
in the candidate. Provenance, redistribution rights, and maintenance ownership are therefore
`UNKNOWN`; this blocks promotion/publication until resolved by the owner.

## Correction of previous claims

| Earlier wording | Correct interpretation |
|---|---|
| `12/12 deepened docs PASS` | Structural/routing checks passed for twelve selected files; semantic correctness, source review, and compile validity were not established. |
| `knowledge pilot PASS` | A deterministic document-to-rubric phrase-coverage check passed; no comparative AI code-review utility was measured. |
| `9 allowed + 8 reject PASS` | The listed public CLI scenarios passed; the complete required combination matrix was not executed. |
| `session history preserved` | Installer preserved bytes of a text sentinel; a valid V5.2 session lifecycle through installer update was not established by that fixture. |
| `registry deadline bounded` | Repository/record/byte bounds were exercised; deadline behavior after the final expensive operation was not tested. |
| `stages 0–9 complete` | Preparation artifacts exist; L0–L7 gates remain open in the operational plan. |

The unchanged narrower evidence remains reusable only under its original platform, candidate,
fixture, command, and scenario scope. A green Python suite does not establish iOS source quality,
global safety, or production readiness.

## Acceptance matrix

Status vocabulary: `PASS` means the stated bounded claim is directly supported; `PARTIAL` means
some evidence exists but the required claim is wider; `UNKNOWN` means the required fact is not
established; `PENDING` means a required future gate has not run; `NOT_APPLICABLE` means the claim
is outside this candidate phase.

| ID | Claim | Expected evidence | Observed evidence | Status | Limitation / next action |
|---|---|---|---|---|---|
| L0-01 | Input is immutable and identified | ZIP hash and isolated candidate | ZIP SHA and isolated candidate recorded | PASS | Recompute after any candidate change |
| L0-02 | Package structure is valid | Validator counts and zero errors | 1,357 files, 60 skills, 51 sections, 288 playbooks | PASS | Structural claim only |
| L0-03 | Candidate Python regression suite passes | Current candidate run, 0 skip | Prior macOS 134/134, 0 skip | PARTIAL | Re-run after new runtime changes |
| L0-04 | Provenance is sufficient for adoption | Source commit, attribution, license/notice | Source commit null; declarations absent | UNKNOWN | Obtain owner provenance/license decision |
| L0-05 | Knowledge is semantically correct | Full selected-doc review and primary-source comparison | Structural checks and URL availability only | PENDING | L1 |
| L0-06 | Knowledge improves our reviews | Predeclared A/B code-review pilot | Phrase/rubric coverage only | PENDING | L2 |
| L0-07 | Runtime contract is complete | Independent required combination matrix | 9/8 bounded scenarios | PARTIAL | L3 |
| L0-08 | Runtime resource envelope is enforced | Boundary tests including final operation/deadline | Repo/record/bytes tests; deadline gap | PARTIAL | L3 |
| L0-09 | Installer preserves real legacy state | Valid old CLI state through update/repeat | Text sentinel plus separate cross-version lifecycle | PARTIAL | L4 combined scenario |
| L0-10 | Global installation is safe for this Mac | Exact real paths, baseline, install/rollback pilot | No real global mutation performed | PENDING | L7, separate approval |
| L0-11 | Runtime is an optional layer | Opt-in behavior without global obligation | Installed reference block imposes protection-session instruction | PENDING | L5 contract redesign/check |
| L0-12 | Independent control-plane review exists | Reviewer distinct from implementer | Astra review found gaps; no final independent acceptance | PENDING | L6 |

## L0 decision

L0 is complete as an accounting correction with open provenance. The library is **not ready for
global installation**. The next useful block is L1 semantic review of the selected knowledge
subset; L3/L4 runtime work may proceed independently in the isolated candidate. No real Mac,
Codex home, client repository, Git state, or canonical documentation repository was changed.
