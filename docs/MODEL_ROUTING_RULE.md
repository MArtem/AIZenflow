# Model Routing Rule

## Purpose
Choose model quality and reasoning effort by task risk, reversibility, and evidence needs. Save resources only where doing so cannot reduce correctness, safety, maintainability, or verification confidence.

## Selection Authority
The user authorizes the assistant to choose the best available model for each task and to recommend a change when risk changes.

If Codex app fixes the primary model, the assistant cannot switch that primary model by itself. When a real switch is needed, ask the user to switch or continue with the best available model and report residual risk.

## Stable Risk Classification
Before editing code or documentation, classify meaningful work as one of:

1. **Low-risk execution** — reversible mechanical work with architecture and ownership already decided.
2. **Standard high-quality task** — normal planning, implementation, review, or documentation work requiring full context discipline.
3. **High-risk planning + final review** — execution may be routine, but architecture/data/security/performance decisions and the final gate need the strongest available model.
4. **High-risk full task** — risk remains high throughout implementation and verification.

Report the risk class, actual selected model, and reasoning level. Do not encode a model version into the class name; model availability changes faster than the risk taxonomy.

## Current Model Mapping
- **GPT-5.6 sol**: preferred daily high-quality default when available and stable.
- **GPT-5.6 tera**: highest-risk architecture, security/privacy, persistence/data-loss, concurrency, package-boundary, performance, and final-review work when its extra cost is justified.
- **GPT-5.6 luna**: low-risk read-only inventory, formatting, mechanical migration, and reversible execution only.
- **GPT-5.5**: high-quality fallback for planning, high-risk decisions, and final gates when GPT-5.6 variants are unavailable or unsuitable.
- **GPT-5.4**: approved-plan low-risk execution fallback when available; it must not invent architecture.

These are qualitative routing preferences, not measured quality percentages. Change them only from actual tool behavior, evaluation results, or explicit user direction.

## High-Risk Triggers
Use **high-risk planning + final review** or **high-risk full task** for:

- architecture, module/package boundaries, public APIs, composition, navigation, or app-wide state ownership;
- persistence, migration, data loss, offline/sync, cache durability, files, uploads/downloads, or app groups;
- concurrency, actors, cancellation, `Sendable`, or main-thread ownership;
- security, privacy, authentication, authorization, tokens, secrets, or sensitive logging;
- performance-sensitive SwiftUI/render/media paths;
- package adoption, Xcode integration, target membership, signing, release, or broad multi-file refactors;
- ambiguous product behavior or decisions that establish a repeated pattern;
- important final reviews where failure would be expensive or hard to reverse.

UI/design work from Figma, screenshots, PDF/SVG/CSS, or pixel-perfect references is standard/high-risk work unless the user explicitly relaxes it.

## Low-Risk Execution Boundary
Low-risk execution is appropriate only when:

- the intended behavior and ownership are already approved;
- the change is local, reversible, and does not establish a new pattern;
- persistence, security/privacy, navigation/state, public API, package, data-loss, and performance-sensitive decisions are absent;
- verification is known and permitted.

If any of those conditions becomes false, escalate instead of improvising.

## Two-Phase Workflow
For non-trivial work that can be safely split:

1. The high-quality planner defines goal, affected files, ownership, invariants, rejected alternatives, implementation steps, verification, rollback, and executor limits.
2. A lower-cost executor implements only that contract.
3. The strongest required model reviews deviations, warnings, and high-risk surfaces before completion.

Keep the work on the primary high-quality model when delegation is unavailable, would add context overhead, or would reduce confidence.

## Context And Output Budget
- Load router-defined Level 0 once, then only task-relevant docs and directly affected code/contracts.
- Prefer diffs and focused files over full-repository loading.
- Do not skip task-routed architecture, security/privacy, persistence, performance, navigation/state, accessibility/localization, or evidence gates to save tokens.
- Keep execution reports concise; planning reports must contain enough reasoning to prevent ownership or architecture mistakes.

## Final Review
Use a high-quality final review when the change touches high-risk triggers, more than five meaningfully related files, failed/warning checks, plan deviations, hard-to-revert behavior, or future repeated patterns.

Small isolated low-risk changes may self-review if all required evidence is available.
