# Current evidence index — remediation continuation

Date: 2026-09-10. This index is the routing authority for current task claims. Earlier receipts are
preserved and are not silently edited.

## Classification rule

- `CURRENT`: the receipt is bound to the current decision and its exact inputs are listed below.
- `SUPERSEDED`: a newer receipt replaces the same claim; the older file remains useful chronology.
- `HISTORICAL`: durable background or a completed earlier block, not evidence for the current head.

Any implementation receipt in this directory not listed as `CURRENT` below is `HISTORICAL` unless a
later receipt explicitly marks it `SUPERSEDED`. A historical PASS never upgrades a current BLOCKED,
missing, or not-run gate.

## Current receipts

| Claim | Current evidence | Exact identity / limitation |
| --- | --- | --- |
| Remediation plan/state | `../../remediation-plan-luna-xhigh.md`, `../../plan.md`, `../../handoff.md` | Current task state is bound to implementation commit `231fb0e3`; receipt-only follow-up may change the final tip. |
| Package library | `PackagesForReuse/PACKAGE_SNAPSHOT_MANIFEST.json` | 40 roots/5 helpers, 21 active roots/3 active helpers; canonical revision is recorded in the manifest. |
| Knowledge freshness | `6.3-knowledge-freshness-2026-09-10.md` | Registry 18 active/5 complete/4 deferred; no maturity upgrade from document count. |
| QC graph evidence | `8.2-graph-static-evidence-802b-2026-09-10.json` | Bound to consumer source head `e201fc8a5e6aeffec2f0455225f9e50f81df815b` and QC pin `802b4833c3c7cebb1c7e920b964451587a0bab42`. |
| Pilot closure | `8.2-pilot-closure-2026-09-10.json` | User-confirmed manual workflow green; no captured run identifier. |
| Promotion/release decision | `9.1-promotion-release-options-2026-09-09.md` plus `8.3-11.2-remediation-superseding-closeout-2026-09-10.md` | Internal pilot selected; stable QC/release remains `NOT_READY`. |

## Superseded or historical groups

- Pre-graph 8.2 static/doctor receipts are `SUPERSEDED` by the graph receipt and paired owner
  decision; they must not be used to reopen a resolved graph gate or to claim a newer head.
- The earlier 8.2 continuation paragraphs in `handoff.md` and
  `universal-quality-control-plan.md` are `HISTORICAL`; their superseding sections identify the
  current status.
- Audit-era 0.x–7.x implementation receipts, the original 30-block plan and archive decisions are
  `HISTORICAL` evidence for provenance and design decisions.
- Any runtime/build receipt not named in the current table is bounded historical evidence and does
  not imply a fresh build/test result after the remediation changes.

## Omitted evidence

No package build/test, Xcode build, Simulator/UI run, physical-device VoiceOver traversal,
Instruments, archive, signing, TestFlight, App Store submission, release tag, or stable-QC
promotion was performed in this remediation continuation. These omissions are intentional and do
not become PASS by absence of a failure.
