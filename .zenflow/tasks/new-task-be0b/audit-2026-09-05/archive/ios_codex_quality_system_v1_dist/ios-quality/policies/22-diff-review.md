# 22 — Diff Review Discipline

## The final diff is authoritative

Before commit, Codex MUST inspect the complete diff and answer for every changed file:

- Why is this file changed?
- Is the change required for the task/correctness?
- Did formatting/generated metadata create unrelated churn?
- Did public API change?
- Did actor/task ownership change?
- Did persistence/network/security behavior change?
- Did dependencies/project settings/entitlements/privacy change?
- Are tests proving behavior rather than mirroring implementation?

## Fail conditions

Pre-commit gate fails on unexplained:

- `Package.resolved` changes;
- project/workspace file churn;
- entitlement/capability/privacy manifest changes;
- localization deletion;
- test removal/weakening;
- warning/lint suppression;
- generated or binary files;
- unrelated file formatting;
- secrets/local machine paths.

## Patch size

Large diff is not automatically bad, but it raises review risk. When a task can be safely split, SHOULD separate mechanical migration from behavioral change.

## Self-review pass

Codex MUST perform one review pass as if reviewing another engineer’s PR, looking for:

- incorrect assumptions;
- edge cases;
- stale async completion;
- nil/error/cancellation paths;
- state ownership leaks;
- retain cycles;
- missing tests;
- misleading names/comments;
- accidental behavior changes.
