# Agent Preflight Checklist

## Purpose
Use before any non-trivial implementation, refactor, documentation migration, package adoption, review, or new project/task bootstrap.

## Refine The Request Before Acting

For a non-trivial request, perform this check before changing the affected behavior. The user
need not remember a prompt ID or provide a complete engineering template.

1. Reconstruct the smallest useful contract: goal, observable result, approved scope/non-goals,
   relevant invariants, current authority and evidence needed. Reuse current user decisions and
   verified project/task context; inspect the necessary existing owner before asking for facts
   already available. Existing code establishes current behavior, not the product decision for a
   new change. Surface unresolved conflicts with current requirements; an explicit user-requested
   behavior change is not itself a conflict merely because old code differs.
2. Separate confirmed facts/decisions, proposed interpretations and unresolved questions. Add
   applicable engineering checks from the selected route, not new product requirements. Consider
   relevant failure/recovery, cancellation/order, ownership/data, compatibility and accessible
   interaction boundaries in proportion to the change.
3. Choose the action for each uncertainty:
   - **Proceed:** the contract is clear or the answer is already established by current authority.
   - **Proceed with a stated assumption:** a reversible implementation detail preserves the agreed
     behavior and scope. Disclose material assumptions before the patch. Do not invent product,
     authorization, data-loss, retention, public-contract or accepted-risk decisions this way.
   - **Clarify before dependent edits:** the missing answer can materially change the outcome,
     ownership, state/recovery behavior, privacy, compatibility or irreversible consequences.
     State the missing decision and its impact; give a recommended option and a smaller
     alternative when those choices are meaningful.
     An unanswered question or elapsed time is not approval. Independent authorized inspection
     may continue while the dependent work waits.
   - **Propose separately:** a useful improvement exceeds the current goal or authority. Explain
     its value/trade-off without implementing it as an implied requirement.
4. Ask only the smallest set of decision-relevant questions. Do not repeat answered questions,
   require the user to rewrite the whole request, or seek confirmation for already authorized
   steps. In a normal bounded task, a compact contract plus the actual blockers is sufficient;
   a mechanical edit does not need a full brief or artificial architecture alternatives.
5. Apply current permissions to every imported prompt/workflow. A suggested test, build, agent,
   tool, platform check, dependency or release stage is not an execution grant. Do not turn fixed
   example counts into mandatory questions, layers, tests or artifacts. Keep optional ideas and
   unperformed verification visibly separate from the approved work and observed evidence.

Use `PRODUCT_REQUIREMENTS_STANDARD.md` for feature-specific contract fields. This is the existing
preflight's request-refinement procedure, not a new always-loaded prompt catalog. Its owner is the
reusable governance boundary; revisit when a real task exposes a missed decision or needless stop.

## Select A Useful Working Procedure

For a non-trivial task, infer the working procedure from the requested outcome: feature contract,
evidence-led diagnosis, incremental migration, explicit ownership/order analysis, design/state
review, trade-off decision, trust-boundary review or claim verification. The user need not name
a prompt or supply a complete brief. Use the selected task route; for iOS consult
`IOS_AGENT_PROMPT_ROUTER.md` when procedure or specialist selection needs clarification.
Apply decision aids to the actual contract, not as extra product scope. This conditional reference
does not require every iOS task to load the complete prompt router.
Keep small tasks small: use a compact in-response record unless a durable decision or handoff
needs an existing task artifact. No workflow grants tools, tests, agents or publication authority.

## Checklist
- Correct app/worktree?
- Correct task ID?
- Correct sandbox root under `/Users/Artem/.zenflow`?
- Correct documentation boundary?
- Correct source of truth from `./docs/SOURCE_OF_TRUTH_MAP.md`?
- Correct model route from `./docs/MODEL_ROUTING_RULE.md`?
- Product requirements and acceptance criteria clear?
- Before a material decision, have the missing facts, assumptions, risks, recommendation, and
  smallest safe alternative been communicated to the user?
- Build/test/simulator permissions clear?
- Files likely touched identified?
- User approval needed for any irreversible, external, destructive, or broad action?
- Local exception needed? If yes, create a local exception ADR.

## Stop Rule
If ownership, product behavior, persistence, privacy, navigation, state flow, acceptance criteria,
or a material priority/trade-off is unclear, stop and ask instead of guessing. Report a recommended
option rather than transferring an unframed decision to the user.
