# AI iOS Task Router

## Purpose

Use this compact entry point for AI, ML, Apple Intelligence, Foundation Models, Core AI,
Core ML/Create ML, Vision, Speech, Translation, App Intents, RAG, agents, model-provider,
tool-calling, and AI-evaluation work. It preserves the complete master reference without making
every AI task load all 96 sections.

## Loading Contract

1. Read this router completely.
2. Apply the core rules below to every AI task.
3. Open only the matching section ranges in `AI_iOS_MASTER_PROMPT.md`.
4. Read the complete master prompt only for a broad AI-platform audit, a cross-cutting AI
   architecture design, or a change to the master prompt itself.
5. Current user instructions, repository rules, task overrides, approved scope, and build/test
   permissions remain higher priority.

## Core Rules For Every AI Task

- Start with user value and test whether a deterministic or specialized Apple framework solves
  the problem before selecting a generative model.
- Verify fast-changing API, availability, device, locale, privacy, pricing, and provider claims
  against current primary documentation and the active SDK; never invent API signatures.
- Keep model/provider calls out of SwiftUI rendering and preserve the project's actual ownership
  boundaries. Add providers, routers, protocols, mocks, flags, or layers only for a current proven
  need.
- Treat user content, retrieved data, OCR, tool output, URLs, files, and model output as untrusted.
  Validate deterministically before persistence, navigation, or action execution.
- Never ship provider secrets in the app. Minimize off-device data, disclose cloud processing,
  and require confirmation for irreversible or sensitive actions.
- Bound input, output, context, cost, retries, tools, time, storage, memory, and retained history.
  Support cancellation, explicit failure, safe fallback, offline/unavailable UX, and stale-result
  rejection where relevant.
- Define how quality will be evaluated. Builds/tests are used only when current permissions and
  risk justify them; passing automation never replaces semantic review.

## Section Routes

Use the stable route ID in task notes and receipts. The numeric range is a locator inside the
versioned master; it is not an instruction to load unrelated sections.

| Route ID | Task | Read master sections |
|---|---|---|
| `AI.CLASSIFY` | Classification, discovery, minimal architecture | 1–6 |
| `AI.LOCAL` | Foundation Models, Core AI/Core ML, local runtimes | 7–11 |
| `AI.CLOUD` | Cloud providers, OpenAI, routing, hybrid execution | 12–16 |
| `AI.RETRIEVAL` | RAG, local retrieval, embeddings | 17–19 |
| `AI.INTENTS` | App Intents, App Entities, parameters, system surfaces | 20–24 |
| `AI.APPLE_CAPABILITIES` | Writing Tools, Image Playground, Translation, Speech, Vision, Natural Language, Sound, Create ML | 25–33 |
| `AI.AGENTS` | Agents, tool calling, MCP, structured output, prompts and injection | 34–40 |
| `AI.TRUST` | Privacy, retention, security, safety, high-stakes output, hallucinations, citations | 41–48 |
| `AI.RUNTIME` | UX, streaming, concurrency, errors, retry/fallback/offline, model downloads and capability | 49–58 |
| `AI.COST_RUNTIME` | Performance, memory, thermal, cost, context, caches, persistence, observability | 59–68 |
| `AI.EVALUATION` | Evaluation, datasets, testing, mocks, nondeterminism, previews, rollout, localization, accessibility, disclosure | 69–80 |
| `AI.APP_ARCH` | App architecture, ViewModel/SwiftUI, background work, multimodal/document/image input, validation, confirmation | 81–89 |
| `AI.DELIVERY` | Implementation workflow, plan, report, prohibitions, technology choice, final principles, task context | 90–96 |

Combine only the ranges required by the actual task. For example, a bounded local OCR change
normally needs sections 1–4, 30, 41, 49, 51, 53, 58–61, 69–72, 79, and 81–90—not the complete
cloud, RAG, agent, and provider material.

## Specialist Route Ownership

Choose one primary owner before adding a narrow supplement:

| Concern | Primary skill | Add only when the task also contains |
|---|---|---|
| API schema, DTO/domain mapping, decode/version/error contract | `ios-api-contracts` | `ios-network-resilience` for transport retry/timeout or `ios-offline-sync` for durable replay/conflict |
| Transport reliability, retry/backoff, timeout, cancellation, upload/download | `ios-network-resilience` | `ios-api-contracts` for payload contract or `ios-offline-sync` for durable local mutation |
| Durable offline mutation, outbox/replay, conflict, relaunch, app-group sync | `ios-offline-sync` | `ios-api-contracts` for remote contract or `ios-data-migration` for schema migration |
| Verification strategy and permission-bounded test choice | `ios-test-strategy` | `ios-testing-debugging` for an observed failure, flake, hang, or runtime diagnosis |
| Test/runtime diagnosis and regression evidence | `ios-testing-debugging` | `ios-test-strategy` only for a new verification matrix |

Do not activate all overlapping routes because a task mentions a generic word such as API, file,
review, or test. A skill trigger must describe the action/risk it owns; a reference document may
still be consulted as a narrow supplement.

## Canonical Files

- Compact router: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/AI_iOS_TASK_ROUTER.md`
- Complete deep reference: `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md`
- Project distribution mirrors: `./docs/agent-prompts/`
