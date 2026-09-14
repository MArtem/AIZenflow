# V5 Multi-Agent Orchestration Protocol

## Objective
Use multiple agents only when independent specialist work improves correctness, latency, or review independence enough to justify extra context and coordination cost.

## Operating sequence
1. **Frame** — load applicable `AGENTS.md`, current adaptive project facts and exact task outcome. Classify R0–R4 risk.
2. **Admit or reject delegation** — delegation is not a synonym for depth. Reject it for trivial, tightly coupled, or single-file work where coordination exceeds value.
3. **Build a task graph** — every node has role, objective, read scope, optional write scope, dependencies, evidence requirements and stop condition.
4. **Partition ownership** — parallel writers must have disjoint write scopes. Shared files are owned by one integrator or serialized.
5. **Dispatch bounded waves** — prefer independent investigation/review in parallel before parallel editing. Do not recursively delegate by default.
6. **Collect structured results** — every material claim must identify evidence, confidence and unresolved unknowns.
7. **Arbitrate disagreement** — disagreements are data. Resolve with repository evidence, invariants, tests or a narrowly scoped arbiter; never majority vote.
8. **Integrate** — one integration owner reconciles changes, repository conventions and cross-domain invariants.
9. **Verify independently** — highest-risk assertions receive independent verification when feasible.
10. **Close** — produce one final report: decisions, evidence, verification actually observed, residual risks, rollback/containment and unknowns.

## Default delegation envelope
- R0–R1: single agent unless the user explicitly requests multiple agents.
- R2: 0–2 child specialists when domains are genuinely independent.
- R3: 2–4 child specialists; one integration owner; one verification pass.
- R4: 3–6 bounded specialists only when the task can be decomposed safely; human gates remain authoritative.
- Default nesting depth: **1**. Child agents must not spawn grandchildren unless an applicable orchestration skill explicitly authorizes it and the coordinator records why.
- Default waves: **2** — investigation/review, then implementation/verification. Add a third only to resolve a concrete blocker.

These are repository policy limits, not claims about any runtime's hard limits.

## Non-negotiable rules
- Do not delegate the same question to multiple agents unless independence is the purpose (e.g. adversarial review).
- Do not redo a delegated task in the coordinator. Integrate it or investigate only a non-overlapping question.
- Do not let multiple agents edit the same file concurrently.
- Do not treat an agent conclusion as evidence by itself.
- Do not claim verification that no agent actually observed.
- Stop fan-out when new agents are unlikely to change the decision.
- If native subagents are unavailable, execute role packets sequentially and label them as sequential role passes, not independent agents.
