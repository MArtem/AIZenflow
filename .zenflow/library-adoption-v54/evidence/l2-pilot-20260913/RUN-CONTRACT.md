# L2 blind A/B run contract

Status: `EXECUTED_AND_SCORED`; frozen inputs and evaluator keys were unchanged after execution.
Date: 2026-09-13.

## Common conditions

- A uses the canonical engineering review instructions only.
- B uses the same instructions plus the exact seven-document pilot payload listed in
  `proposed-integration/PROFILE.md`.
- Use two fresh isolated contexts per task, randomize A/B order, and do not expose the other
  run's output or the evaluator-only key.
- Model/effort target: `GPT-5.6 Luna / xhigh` for both arms. If the independent runner cannot
  use this route, record the actual model/effort and mark the comparison non-equivalent.
- Permissions: read-only review; no build, test, network, Git mutation, file write, or release
  action. Repository paths are synthetic snippets only.
- Output schema for every finding: `task_id`, `finding_id_or_none`, `severity`, `file_or_symbol`,
  `evidence_quote_or_span`, `why_it_is_a_defect`, `recommended_change`, `confidence`,
  `authority_or_scope_note`.
- Record wall time and actual tokens for each arm. Unavailable tokens are `UNKNOWN`; never infer
  them from context size.
- The evaluator receives `evaluator-only/` only after all A/B outputs and the holdout outputs are
  sealed. The reviewer receives `reviewer-inputs/` and this contract only.

## Frozen packet identities

| Packet | SHA-256 |
|---|---|
| `reviewer-inputs/T1-cancellation-stale-response.md` | `0144be296f45d0b44a4cbdb9125ebf02d0235e9b943f4e879d0399df11f50c22` |
| `reviewer-inputs/T2-auth-refresh-logout.md` | `06afba11aa3a9ea084e5cb695ab0a6dc7cdb27be6283f1bd55a1ea12971de736` |
| `reviewer-inputs/T3-swiftui-ownership-identity.md` | `0e50d82167da672f768c20f660a3bf214f18d4e6cd0f37ee85ea7676e4b23ede` |
| `reviewer-inputs/H-holdout-actor-cancellation.md` | `f32fb24e011542fbb62ee498711ac3216d77b0f2ee60e58341284f5201bd3bad` |
| `evaluator-only/answer-key.md` | `128352d0901ca41fa0fa46bfe92ce8ee640d1914b7ecc51537ef667ccbee4de3` |
| `evaluator-only/holdout-key.md` | `3d80a6fc446142e1d5e6cfdcfa528e8f3280f5dcddd0dae18749d21625676da1` |

## Scoring gate

Count only code-anchored confirmed findings. The candidate passes utility only if B identifies
at least one additional confirmed substantial issue across T1–T3, preserves substantial A
recall, leaves all controls unflagged, adds no dangerous advice/authority expansion, and stays
within 50% measured input/time overhead. The frozen holdout must show no new substantial miss
relative to A. If the conditions are not met, record `NO_DEMONSTRATED_GAIN`.

Do not change the threshold, subset, prompts, or answer key after outputs are available.
