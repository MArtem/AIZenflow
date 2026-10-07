# Reference review guide — candidate

Use after the project's local review at every relevant stage. This is a reasoning guide, not an
automated reviewer or permission to edit, test, build, use Git, or create a PR. Identify the actual
task output first: findings/advice for a read-only task, a design decision for a planning task,
or the complete code/resource diff for an implementation task.

## Review sequence

1. State the requested behavior, acceptance criteria, non-goals, repository conventions, and
   affected owners and consumers. Mark unknown product decisions instead of guessing.
2. Trace the success path and credible failure/negative paths, including cancellation, partial
   output, compatibility and rollback when relevant. Compare before/after behavior.
3. Check the smallest relevant domain risks: Swift isolation/ARC, UI state/lifecycle, data and
   network contracts, privacy/security, accessibility/localization, performance and observability.
4. Compare the full candidate diff with the change contract. Inspect adjacent call sites,
   generated/configuration files and mirrored documentation claims. Include staged, unstaged and
   relevant untracked files; a changed-files list from only one Git diff view is incomplete.
   Include dependency lockfiles where changed; resolve their producer and affected consumers
   rather than dismissing them as generated noise.
   If a supporting scan failed, was skipped or had unreadable inputs, report the affected review
   scope as unverified even when another static check passed. Do not treat a clean linter or build
   as proof of semantic correctness.
5. Classify concrete findings by severity. Unresolved P0–P2 block a readiness claim; report P3
   explicitly or fix it. Recheck corrected boundaries and repeat one full final-diff review after
   material fixes. State what remains unverified.

## Change surface

For any structural or resource change, inspect the applicable rows: Xcode target/scheme/build
phase membership; package/module ownership and dependency direction; app versus extension access;
asset catalog and resource-bundle lookup; localization/RTL and accessibility; supported platform
and toolchain; entitlements/capabilities; dependency provenance/privacy; affected tests, build
targets and manual QA. Do not call a code-only diff review complete when these changed.

## Design to iOS

Check the supplied design identity, frames/variants, component states, assets and typography
against the project's design system. Review layouts across the supported size range, Dynamic
Type, VoiceOver, contrast, RTL and localized expansion. A screenshot or pixel-fidelity claim
requires an actual authorized comparison; missing design access or visual evidence is
`INSUFFICIENT_EVIDENCE`, never a visual PASS.

## Handoff

Give the user the evidence-backed candidate or prioritized findings, the complete changed-file
set, observed checks, omitted checks and residual risks. The user owns their final review; commit
and PR are separate authorized transitions. Never call an unrun check successful.
