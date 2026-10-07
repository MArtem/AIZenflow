# Change risk and evidence selection

Adapted from `v5.4/00_META/CHANGE_RISK_MATRIX.md`. Risk guides **which evidence to seek**, not
permission to run commands or a guarantee that a category is safe.

| Class | Typical surface | Evidence to consider when authorized and relevant |
| --- | --- | --- |
| R0 | Naming, documentation or local mechanical cleanup | Exact diff, affected references, static format/link checks |
| R1 | Bounded business logic or UI change | Invariants, nearby tests, target build and relevant interaction evidence |
| R2 | Network, persistence, navigation, concurrency or shared API | Producer/consumer map, negative path, integration and compatibility evidence |
| R3 | Schema, module graph, security/privacy, CI or broad migration | Staged contract, regression, failure/rollback and independent review |
| R4 | Potentially destructive data, payment, auth or public SDK break | Explicit proof of preservation/containment, rollout and human decision |

Increase scrutiny for weak tests, offline writes, user-created data, background execution,
multi-target code, binary SDKs, extensions sharing storage, concurrency escape hatches or a
release-sensitive window. The class is a working estimate; change it when inspected facts change.
For R2+ decisions, compare genuinely viable alternatives when ownership, compatibility,
reversibility or evidence cost differs materially; do not invent a second design merely to
fill a template. Rank a suspected defect separately by impact, evidence provenance and
confidence, and route it to only the audit domains supported by observed project facts.

At planning, translate the user journey into observable acceptance and explicit non-goals,
including relevant offline/error/permission states and rollout constraints. Separate a missing
product decision from an implementation defect. Recommend a bounded spike only for a concrete
uncertainty, with a question, stop condition and evidence budget. Material decisions need context,
alternatives, consequences and a revisit/rollback criterion in the project's decision record;
do not create documents or flags as rituals.

For an authorized modernization, require a real benefit and success metric: characterize,
migrate one bounded slice, compare, then expand or stop. Review dual-state/dual-write hazards,
old/new compatibility and cleanup criteria across affected consumers. Dependency removal needs
public/transitive usage accounting; a minimum-OS change needs supported-user/device impact,
availability-shim inventory and release communication. No framework or language-mode change is
authorized merely by this recommendation; choose the relevant specialist route for its contract.

No class automatically requires or permits a build, test, network call, signing, dependency
change, installation, commit or PR. If necessary evidence is unavailable, use
`INSUFFICIENT_EVIDENCE` and narrow the claim. See [EVIDENCE_POLICY.md](EVIDENCE_POLICY.md).

## Action advice, not silent authority

At each task stage, assess whether a build, test, Simulator/device check, independent agent,
network lookup, dependency operation, Git action, performance measurement, release check, or
another consequential step would materially reduce uncertainty or prevent a credible failure.
Recommend an action when its expected evidence is worth its time, cost and risk; recommend
against it when the question can be settled by a smaller static check. Reassess after findings
or a changed diff. The recommendation must name the question, smallest useful scope, expected
evidence, cost/risk, current permission status and what remains unverified if skipped.

For `AUTO`, perform only advice and checks already allowed by the task and project; ask before
an action lacking authority. For `ADVISORY`, present the decision and proposed check without
claiming it was run. Neither profile turns a recommendation into permission. Do not offer a
ritual build/test or automatic agent wave merely because a risk class is high.
