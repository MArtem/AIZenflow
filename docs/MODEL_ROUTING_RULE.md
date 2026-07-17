# Model Routing Rule

## Purpose
Choose model and reasoning from expected result quality, risk, reversibility, ambiguity, evidence strength, and cost. Quality, correctness, safety, maintainability, and evidence outrank economy; economy remains important and selects the cheaper route only when the expected result is not materially weakened.

## Selection Authority And Reporting
The assistant selects the best route and recommends a switch when risk changes; Codex cannot change the primary selector itself.

Before meaningful work and in every required response header, state the factual model and reasoning level plus one of:

- `Смена модели: не требуется`;
- `Смена модели: требуется: GPT-5.6 <sol|tera|luna>, <низкий|средний|высокий> уровень мышления`.

When required, report the switch before acting and ask the user to select it. Retain a stronger current route; do not downgrade a high-risk block merely to save resources.

## Stable Risk Classification
Before editing code or documentation, classify meaningful work as one of:

1. **Low-risk execution** — reversible mechanical work with behavior and ownership already decided.
2. **Standard task** — normal planning, implementation, review, or documentation.
3. **High-risk planning + final review** — a decision or final gate needs the strongest route.
4. **High-risk full task** — risk remains high through implementation and verification.

Report the risk class, actual model, and reasoning level. Do not encode model names in the risk classes.

## Available Models And Levels
Only these models are available, each with `low`, `medium`, and `high` reasoning:

| Route | Use it for |
| --- | --- |
| `GPT-5.6 luna` | Fully specified, low-risk, reversible reads or approved mechanical execution |
| `GPT-5.6 sol` | Maximum-quality route for judgment-heavy, ambiguous, broad, high-impact, high-risk, or final-gate work |
| `GPT-5.6 tera` | Resource-efficient high-quality route for bounded work when scope, ownership, and verification are strong enough to preserve the required result |

Choose the model first, then the lowest reasoning level that still preserves the required quality and evidence:

| Route | Low | Medium | High |
| --- | --- | --- | --- |
| `luna` | Simple read-only/mechanical | Bounded mechanical work with known checks | Larger still-low-risk mechanical block; move to `sol` when judgment matters |
| `sol` | Small judgment-bearing work | Default standard work | Broad, ambiguous, multi-file, high-impact, high-risk, visual-reference, or final-review work |
| `tera` | Bounded low-ambiguity work where economy matters | Standard work with explicit scope and strong checks | Larger bounded work only when its evidence and reversibility make the expected result equivalent to `sol` |

A higher reasoning level does not make an unsuitable model appropriate. At the same reasoning level, this user-approved routing policy treats `sol` as the higher-quality route and `tera` as the more resource-efficient route; this is a project policy, not a general provider benchmark. If uncertainty, irreversibility, or required evidence grows, move to `sol` first, then raise the reasoning level.

## High-Risk Triggers
Use **high-risk planning + final review** or **high-risk full task**, normally `GPT-5.6 sol` at high reasoning, for:

- architecture, public/package APIs, navigation, or app-wide state;
- persistence, migration/data loss, sync, durable cache/files, app groups, or transfers;
- concurrency, actors, cancellation, `Sendable`, or main-thread ownership;
- security/privacy, identity, secrets, or sensitive logging;
- performance-sensitive UI/media, package/Xcode integration, signing/release, or broad refactors;
- ambiguous repeated patterns or expensive-to-reverse final reviews.

UI/design work from Figma, screenshots, PDF/SVG/CSS, or pixel-perfect references starts at `GPT-5.6 sol` with high reasoning. Use `tera` only when the work is bounded, the reference and acceptance evidence are strong, and the expected fidelity is not materially reduced.

## Low-Risk Execution Boundary
Low-risk execution is appropriate only when behavior and ownership are approved; the change is local, reversible, and non-pattern-forming; high-risk domains are absent; and permitted verification is known. Escalate instead of improvising when any condition becomes false.

## Two-Phase Workflow
For non-trivial work that can safely split:

1. Routed `sol`/`tera` defines ownership, invariants, alternatives, implementation, verification, rollback, and limits.
2. `luna` executes only an approved low-risk contract; otherwise retain the primary route.
3. `sol` performs required high-risk final review.

Keep work on the primary route when delegation would add context overhead or reduce confidence.

## Context, Economy, And Final Review
- Load Level 0 once, then focused evidence; never skip a routed gate to save tokens.
- Default to `sol` medium when judgment materially affects the result and no stronger trigger exists.
- Prefer `tera` medium for bounded standard work only when requirements and ownership are explicit, checks are strong, reversibility is good, and using it is not expected to reduce quality.
- Use `sol` high for high-risk triggers, broad related changes, warnings, deviations, hard-to-revert behavior, repeated patterns, or final high-risk review. Small isolated low-risk changes may self-review only with complete evidence.
