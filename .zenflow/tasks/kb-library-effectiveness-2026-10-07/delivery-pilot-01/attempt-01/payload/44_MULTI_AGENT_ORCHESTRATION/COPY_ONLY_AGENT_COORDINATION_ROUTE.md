# Agent coordination — curated copy-only route

Use when an authorized task benefits from genuinely separable research or review. One agent is
the default. This document is guidance, not permission to create chats, invoke subagents,
contact external services, share secrets, write files, or change Git state. Follow current user,
project, tool and model-routing limits before any delegation.

1. Frame one objective, scope, risk, expected evidence, resource ceiling and stop condition.
   Delegate only if independent work is likely to improve coverage or speed enough to justify
   coordination cost. Keep a single accountable integrator.
2. Partition by disjoint files or independent questions. Give each worker a bounded packet:
   inputs, exact read/write scope, dependencies, output format, evidence requirements and
   forbidden actions. Read-only reviewers must remain read-only. Never assign concurrent
   writers to the same file or let a worker broaden authority.
3. Collect outputs as claims, not proof. Verify citations, inspected revisions and limitations.
   A second pass by the same agent is not an independent review. Resolve disagreement against
   code and evidence, not by vote; preserve unresolved uncertainty in the final report.
4. Integrate once, inspect the complete result and run only authorized checks. Human approval
   remains required for destructive or external actions, credentials, publication, releases,
   policy exceptions and any other decision outside the task's authority. Consensus cannot
   substitute for it.
5. Stop when the marginal value of another wave is low, the scope/budget is reached, or a
   decision requires the user. If delegation is unavailable or unauthorized, use sequential
   perspective passes and label them honestly; do not imply multiple agents ran.

Start dependent work only after its necessary inputs are resolved; serialize shared project,
package, routing, localization and generated files under one owner. Keep packets minimal and
redacted, with known facts separated from assumptions, forbidden actions and escalation criteria.
A timeout or partial worker result leaves that node incomplete, not the entire task automatically
failed or successful. Retain supported observations, inspect a failed writer's actual diff before
retrying, and retry only when the failure is understood and the next attempt materially differs.
Verification failures return to the integrator without silently widening the verifier's write
scope. Preserve contested/stale claims and rejected recommendations with reasons; do not summarize
disagreement away or rank evidence by model name. Existing model-routing rules govern any supported
model/effort choice; archived wave counts, scores and inheritance defaults are not current authority.

This route preserves the useful admission, write-scope, evidence-integrity, conflict-closure,
integration and budget/termination gates from `v5.4/44_MULTI_AGENT_ORCHESTRATION` and
`v5.4/49_V5_AUDIT_GATES`. Their copied originals remain excluded source material and do not
activate agents or runtime machinery.
