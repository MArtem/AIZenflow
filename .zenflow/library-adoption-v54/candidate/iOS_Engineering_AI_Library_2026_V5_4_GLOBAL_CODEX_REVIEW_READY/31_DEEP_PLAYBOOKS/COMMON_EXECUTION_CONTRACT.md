# Deep Playbook Common Execution Contract

This file contains the workflow intentionally shared by all operational deep playbooks. It exists to keep generic execution/reporting mechanics out of topic-specific content; **file count is not a quality metric**.

## Shared workflow

1. Resolve applicable system/user/project instructions and deployment/toolchain constraints.
2. Inspect the concrete owners, callers, state/lifetime/dependency boundaries and nearby tests before proposing a change.
3. State task-specific invariants and at least one falsifiable failure scenario for R2+ work.
4. Prefer the smallest change that preserves the observed contract; do not add abstraction solely to match a library pattern.
5. Run only authorized verification. Distinguish observed, inspected, inferred and unknown evidence.
6. Report remaining risk and partial/blocked verification explicitly.

## Shared stop conditions

Stop or return review-required instead of inventing confidence when repository evidence is incomplete, permissions are unclear, a required operation exceeds declared scope, a build/test surface may execute unknown actions, or a migration/security/concurrency invariant cannot be established.

## Topic-specific requirement

Every `OP-IOS-*` playbook must derive its concrete traps from its source skill plus the actual repository/task. A generic checklist never substitutes for local invariants, failure modes or evidence.
