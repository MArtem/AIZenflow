# Full-project iOS audit — curated copy-only route

Use for an explicitly requested whole-project audit or to select the relevant review domains for
a bounded change. Read project-local rules, product intent, supported platforms and the actual
target graph first. An audit request grants inspection and recommendations, not code changes,
builds, tests, network access, signing, publishing, or changes to Codex itself.

## Coverage contract

Establish the exact repository, Xcode project, targets, branch/base and requested depth. Inventory
app and extension entry points, source and resource membership, packages, build settings,
localizations and tests. Then assess each applicable domain: product/architecture, Swift and
concurrency, SwiftUI/UIKit and navigation, lifecycle/background, networking/offline behavior,
persistence/migration, security/privacy and external input, accessibility/localization, tests,
performance/memory/media, observability/incident recovery, release/dependencies/public APIs,
and AI or hardware capabilities where present. Trace cross-domain consumers and failure paths.

Select at most two supporting reference routes per bounded pass; continue passes until every
applicable domain has a recorded disposition. A large project may require a staged report and
explicit continuation, not a false claim of complete coverage. Apply project-local checks first
and the reference checks second. Do not treat a raw imported audit gate as an active rule.

For each domain record `CHECKED`, `NOT_APPLICABLE` with reason, `FINDING`, `UNVERIFIED`, or
`BLOCKED`, together with the inspected files and evidence limit. Static inspection cannot prove
runtime behavior, visual fidelity, performance, release readiness, or passing tests. Recommend
the smallest useful verification; run it only when authorized by the current task and project.

## Output and decision

Report concrete findings with severity P0–P3, affected path, reproducible scenario or code
evidence, impact, correction and verification need. Distinguish observed facts from inference.
Rank recommendations by user impact and risk, separating required fixes from optional work.
P0–P2 findings block a clean/PR-ready claim; unresolved or unobserved domains preclude a
whole-project production-ready claim. For a change review, recheck the complete final code,
resource, project and documentation diff after fixes; changed artifacts invalidate earlier
final-review evidence. No audit result grants authority to implement recommendations.

This route distills the thematic `v5.4/34_AUDIT_GATES/AG-01..24` coverage and production review
completeness ideas. The copied individual gates remain source material, not allowlisted payload.
