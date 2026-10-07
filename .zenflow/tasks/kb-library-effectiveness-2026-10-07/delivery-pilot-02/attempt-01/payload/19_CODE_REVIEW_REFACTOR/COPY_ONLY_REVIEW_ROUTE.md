# iOS code review — curated copy-only route

This route distills the task-relevant checks from the imported `IOS-19-01`–`IOS-19-10` and
their deep playbooks. Those originals remain inactive source material, not an
instruction to run their copy-paste prompts. Use this route after current project-local review;
see [../REVIEW_GUIDE.md](../REVIEW_GUIDE.md) for the whole-change review sequence.

## Establish the review boundary

- Identify the requested output: read-only findings, diagnosis, implementation correction, or
  pre-PR candidate. A review request alone does not authorize edits.
- Inspect the actual change against behavior and acceptance criteria, surrounding owners and
  call sites, affected targets, deployment range, tests and local conventions. Mark absent facts
  unknown rather than inventing a project context.
- Trace affected state/resource lifetimes and producer/consumer contracts. Include app extensions,
  widgets, generated code, serialization and resource lookup when they consume the change.
- For an authorized refactor, characterize observable behavior/public contracts before moving
  one real responsibility at a time. Preserve error recovery/messaging and async cancellation,
  backpressure and execution-order contracts, not only a matching happy-path return value.
  Before deleting apparently unused code or abstractions, check selectors/reflection, resources,
  external routes and feature flags; absence of direct call sites alone is insufficient.

## Challenge the risky paths

- Compare success with error, cancellation, retry, offline, permission and partial-result paths
  that are credible for this change. Check that UI state and persistent state remain possible.
- For asynchronous code, verify owner, actor isolation, task lifetime, reentrancy and cleanup;
  for memory-sensitive code, examine closures, tasks, timers, observers and delegates. Static
  inspection alone does not prove a leak or race is absent.
- For security/privacy, name the trust boundary and inspect negative inputs, secret/PII handling
  and logging. For performance, identify the workload and before/after measurement needed before
  claiming improvement.
- Check availability, target/package/resource membership, accessibility and localization where
  the changed surface makes them relevant. Style preferences must not obscure failure modes.
- For interactive UI, compare accessible labels with the information actually known to the
  user. An internal `empty`/default state may mean *unknown* on a hidden board or pending view;
  do not announce it as a confirmed negative fact. Trace the value producer and label consumer.

## Findings and correction

As a second layer, adjudicate the **local-first candidate findings before adding more**. For
each proposed P0–P2, trace an actual caller or input producer, the allowed value range and the
current product/deployment contract. Distinguish a reproducible present path from a direct call
with an impossible current UI value, a future consumer, or an unapproved product assumption.
Keep the static fact but downgrade or mark severity conditional when reachability or impact is
not established. Challenge missing localization only against the app's supported locales or an
explicit localization requirement; an English-only target can still have future readiness work
without a proven current wrong-language defect. Record duplicate, rejected and refined findings
as well as genuinely new ones; zero incremental findings is an honest outcome.
Do not promote an unused enum case, asymmetric presentation or plausible game convention to a
P0–P2 product defect without an explicit requirement or current behavior contract; report the
observed asymmetry and ask for the missing product decision instead.

Record each actionable finding as `severity → location → violated invariant → failure scenario →
evidence → smallest correction → relevant regression check`. Distinguish observed evidence from
inference; avoid a speculative architecture rewrite for an unproven cause. P0–P2 block a
ready-for-user-review or ready-for-PR claim. Report P3 or fix it. For an authorized correction,
keep the diff coherent, inspect affected consumers again, and repeat the complete final review
after material edits.
Rank supported findings by severity, likelihood and blast radius. Retire migration seams only
after the defined compatibility window and parity evidence; no automatic adapter or rewrite is
required. Performance refactors need a measured bottleneck and comparable regression evidence.

Tests, builds, diagnostics, Git, dependencies, release actions and PR creation still require the
current task's permission. If needed evidence cannot be collected, report
`INSUFFICIENT_EVIDENCE`; never imply the imported playbook authorized execution.
