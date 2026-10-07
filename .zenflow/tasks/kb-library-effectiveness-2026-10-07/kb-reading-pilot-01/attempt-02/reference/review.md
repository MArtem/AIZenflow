# Reference review guide — candidate

Use after the project's local review at every relevant stage. This is a reasoning guide, not an
automated reviewer or permission to edit, test, build, use Git, or create a PR. Identify the actual
task output first: findings/advice for a read-only task, a design decision for a planning task,
or the complete code/resource diff for an implementation task.

## Review sequence

Apply the current canonical KB `ENGINEERING_CHANGE_QUALITY_STANDARD.md` for behavior/authority,
producer-consumer agreement, ordering, input/resource envelopes, negative paths, full candidate review,
findings and readiness thresholds. Its final adversarial review and exact-SHA receipts remain required
under actual Git permission. Reuse a current completed read; this guide does not define a second loop.

Within that loop, challenge the actual candidate inventory:

- Include staged, unstaged and relevant untracked artifacts; one Git diff view is incomplete.
- Resolve changed dependency lockfiles to their producer/consumers rather than dismissing generated noise.
- Include adjacent call sites, generated/configuration files and mirrored claims when affected.
- A failed/skipped supporting scan or unreadable input leaves that scope unverified; another passing check
  does not fill the gap. A clean linter/build does not establish semantic correctness.
- Use the smallest relevant domain routes for Swift isolation/ARC, UI state/lifecycle, data/network,
  privacy/security, accessibility/localization, performance and observability; record exclusions.

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
