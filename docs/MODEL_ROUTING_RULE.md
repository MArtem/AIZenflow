# Model Routing Rule

## Purpose
Choose the operating mode, model, and reasoning level from expected result quality, risk, reversibility, ambiguity, evidence strength, and whole-workflow cost. Quality, correctness, safety, maintainability, and evidence always outrank economy. The active mode controls how aggressively to pursue resource savings after those floors are satisfied.

## Operating Mode Authority
Exactly one operating mode is active:

| Mode | Goal | Default routing posture |
| --- | --- | --- |
| `качество` (`quality`) | Minimize hidden error, incomplete analysis, and rework | Use `sol` whenever additional judgment can materially improve the result; delegate only bounded mechanical execution |
| `сбалансированный` (`balanced`) | Minimize total workflow cost without materially weakening quality | Use `tera` for explicit, bounded, strongly verifiable standard work; escalate to `sol` when judgment or risk grows |
| `эконом` (`economy`) | Use the least costly route likely to succeed once | Start low for deterministic work, use `tera` for most bounded production work, and preserve all hard escalation floors |

The latest explicit user choice sets the mode. Recognize the Russian names and the English aliases above. The mode persists for the current task/thread until the user explicitly changes it; a one-off model selection is not a mode change. Record the active mode in a context handoff. Never change modes silently, although a mode change may be recommended with reasons. If no explicit or handed-off mode exists, use `качество` so introducing this system cannot silently lower the established quality bar.

The mode changes routing economy, not permissions or engineering standards. It cannot authorize code, tests, builds, tools, commits, destructive actions, product decisions, or evidence claims, and it cannot weaken a newer user instruction, a project restriction, or a hard risk floor.

## Selection Authority And Reporting
The assistant selects the best route and recommends a switch when risk changes; Codex cannot change the primary selector itself.

Before meaningful work and in every required response header, state the active mode, factual model, and reasoning level plus one of:

- `Смена модели: не требуется`;
- `Смена модели: рекомендуется: GPT-5.6 <sol|tera|luna>, <низкий|средний|высокий> уровень мышления`;
- `Смена модели: требуется: GPT-5.6 <sol|tera|luna>, <низкий|средний|высокий> уровень мышления`.

Use `требуется` when the current route is insufficient for the applicable quality or risk floor; report it before acting and ask the user to select it. Use `рекомендуется` only for an optional economy-driven change when the current stronger route remains valid. Use `не требуется` when the current route is the selected route or retaining it is preferable. Never recommend downgrading an active high-risk block merely to save resources.

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

## Mode Routing Matrix
Classify the work first, then apply the active mode. These are starting routes; hard floors and newly discovered evidence override them.

| Work class | `качество` | `сбалансированный` | `эконом` |
| --- | --- | --- | --- |
| Deterministic, reversible, fully checked | `luna` low/medium; retain a stronger current route when the block is tiny | `luna` low/medium | `luna` low; medium only when several explicit conditions interact |
| Standard, bounded, known ownership | `sol` medium; `tera` medium only when equivalent quality is expected | `tera` medium; `sol` medium when judgment materially affects the result | `tera` medium; `luna` medium only for an approved mechanical contract |
| Complex but bounded and strongly verifiable | `sol` high | `tera` high or `sol` medium according to ambiguity and consequence | `tera` high; move to `sol` when reversibility or evidence is insufficient |
| Broad, ambiguous, high-impact, high-risk, or final gate | `sol` high | `sol` high | `sol` high |

Reasoning-level meaning is stable across modes:

- `low`: deterministic execution with explicit inputs, local effects, and direct checks;
- `medium`: bounded judgment, several interacting conditions, or standard multi-file work with clear ownership;
- `high`: ambiguity, broad impact, difficult root cause, weak evidence, irreversible consequences, architecture, or a critical final review.

Use the mode matrix directly for ordinary tasks. Do not perform a ceremonial numeric score. When routing is genuinely borderline, compare consequence of error, ambiguity, blast radius, reversibility, verification strength, novelty, state/concurrency, sensitive data, and workflow length; document the decisive factors rather than presenting false precision.

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

## Escalation And De-escalation
Escalate immediately when an assumption behind the current route fails, including newly ambiguous requirements, a high-risk domain, unexpectedly broad ownership, weak or unavailable verification, an unexplained failure, contradictory evidence, or a change that is harder to reverse than first assessed. Do not spend repeated attempts on an underpowered route.

De-escalate only at a clean phase boundary after decisions and invariants are fixed, the remaining work is mechanical, inputs and acceptance checks are explicit, and rollback is straightforward. In `качество`, prefer retaining the current stronger route unless savings are material and quality is demonstrably unchanged. In `сбалансированный`, recommend a cheaper route for a substantial isolated execution phase. In `эконом`, proactively recommend the least costly adequate route, but never below a hard floor.

## Context, Economy, And Final Review
- Load Level 0 once, then focused evidence; never skip a routed gate to save tokens.
- Apply the active mode's starting route when no stronger trigger exists.
- Prefer `tera` only when requirements and ownership are explicit, checks are strong, reversibility is good, and using it is not expected to reduce the mode's required result quality.
- Use `sol` high for high-risk triggers, broad related changes, warnings, deviations, hard-to-revert behavior, repeated patterns, or final high-risk review. Small isolated low-risk changes may self-review only with complete evidence.
