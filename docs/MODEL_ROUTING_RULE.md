# Model Selection Rule

## Authority

This is the sole active rule for choosing a model and reasoning level. It supersedes earlier routing matrices, estimates, benchmark summaries, and model-selection guidance. The available routes are GPT-5.6 Sol, Terra, and Luna.

## Official Product And Usage Baseline

For ChatGPT/Codex subscription work, route by the current official product roles and the actual task risk, not by API token prices or an averaged benchmark score:

- Sol is intended for the hardest work: complex reasoning, ambiguous problems, advanced coding, and high-stakes decisions.
- Terra is the everyday workhorse for production tasks, coding, analysis, and work that requires sound judgment.
- Luna is optimized for fast, high-volume routing, classification, extraction, automation, and focused coding tasks.

ChatGPT Plus usage is not a fixed token-price conversion. It varies with the selected model, context size, reasoning, tools, retrieval, caching, and whether work is local or cloud. Current plan limits are published as ranges, may share a five-hour window, and may also have weekly limits. Do not convert them into a guaranteed task count or a fixed total-task percentage.

API pricing is a separate billing surface and applies only when work uses an API key. Never use API input/output prices alone to predict ChatGPT Plus consumption. Consult the current official [Codex pricing and usage documentation](https://learn.chatgpt.com/docs/pricing) when a numeric limit or price affects a decision; do not copy volatile pricing tables into this durable rule.

Do not route from an unversioned average of heterogeneous coding benchmarks. Prefer the official product roles above, the risk triggers below, deterministic verification, and project-specific evaluation evidence when it exists.

Practical iOS interpretation:

| Model | Default scope | Do not use as the primary route for |
| --- | --- | --- |
| `GPT-5.6 luna` | fully specified mechanical edits, localization, formatting, simple models, and small reversible changes | architecture, large repository reasoning, Swift 6 concurrency, persistence, unknown bugs, or security-sensitive work |
| `GPT-5.6 tera` | normal SwiftUI/UIKit, MVVM, feature work, bounded refactors, tests, routine reviews, and reproduced bugs | a task whose risk or ambiguity makes failure/rework materially more expensive than Sol |
| `GPT-5.6 sol` | architecture, Swift 6 concurrency, migration/sync, privacy/security, performance, unknown production bugs, broad refactors, and high-risk final review | routine bounded work when Terra can meet the same quality bar |

Default effort: `medium`. Use `low` only for deterministic mechanical work. Use `high` for Sol when ambiguity, irreversible consequence, broad impact, or difficult diagnosis requires it.

## Operating Modes

The user selects one persistent mode: `качество`, `сбалансированный`, or `эконом`. The mode sets the economy target; it never lowers correctness, safety, maintainability, or evidence requirements. If no mode is stated, use `качество`.

- `качество`: prefer Sol when its additional judgment can materially reduce error or rework.
- `сбалансированный`: Terra is the normal default for bounded implementation; Sol protects high-risk work; Luna is limited to mechanical work.
- `эконом`: use Luna only when its mechanical scope is explicit and easily checked; otherwise Terra remains the default.

## Command-Time Decision Rule

After every user request or command, assess the **currently selected** model and reasoning level against the requested block.

1. If the current route can meet the required quality and risk floor, report `Смена модели: не требуется` and proceed immediately. Do not propose a cheaper or stronger model merely as an optimization.
2. If the current route is not adequate, do **not** inspect, plan, edit, run tools, or begin the requested task. Report `Смена модели: требуется: <model>, <level>` and wait for the user to switch or explicitly direct an exception.
3. A required-switch proposal states: current route; target route; concrete risk that the current route cannot safely cover; expected quality/rework gain; relative token/limit cost; the smallest viable alternative; and what remains unverified if the user elects to continue unchanged.

Codex cannot change the primary selector. A one-off model selection does not change the operating mode. Never change either silently.

## Execution Economy Heuristics

- For normal bounded work, prefer one Terra session that owns discovery, planning, implementation, correction, and reporting end-to-end, with deterministic tools providing the evidence.
- Do not require a `Luna -> Terra -> Sol` pipeline for every task. Each handoff reloads context and can cost more than it saves.
- Use Luna only for an isolated, fully specified mechanical block with direct verification. Do not start a separate Luna discovery pass when Terra would need to reread the same repository context.
- Use Sol at the boundaries where stronger judgment materially reduces expected rework or harm: ambiguous requirements, unknown or repeatedly failed defects, Swift concurrency, persistence or migration, security or privacy, public contracts, CI/signing, broad architecture, or irreversible consequences.
- Sol may plan or review a high-risk block while Terra implements a stable approved plan. Keep Sol as the end-to-end implementer when splitting ownership would lose critical context or make rework more likely.
- Add an independent review only when correlated misunderstanding is a material risk. Keep it bounded to the task contract, acceptance criteria, affected-component map, diff, and tool evidence; do not automatically reload the whole repository.
- A model-written self-review is useful but is not independent evidence. Build, tests, static gates, hashes, and other deterministic outputs remain the source of verification claims.
- Estimate economy from total task cost, including context reloads, tool calls, failed attempts, and rework. Do not promise fixed savings percentages.

When evidence is weak or a change affects concurrency, persistence, security, navigation ownership, public contracts, or multiple dependent files, do not assume the cheaper route remains economical; apply the Sol risk floor before implementation.

## Reporting

Every required header states factual model, reasoning level, operating mode, and either `Смена модели: не требуется` or `Смена модели: требуется: …`. Meaningful results identify the model used. Context handoffs preserve the active mode and the current model decision.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
