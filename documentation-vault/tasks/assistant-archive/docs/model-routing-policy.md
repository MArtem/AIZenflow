# Model Routing Policy

Use this policy for coding tasks to select the most cost-effective model that can solve the task reliably.

## Available Models
- `GPT-5.5`
- `GPT-5.4`
- `GPT-5.3-codex`

## Required Response Header
Every coding-task response must begin with:

```text
Model: <model-name>
```

Examples:

```text
Model: GPT-5.4
Model: GPT-5.5
Model: GPT-5.3-codex
```

## Core Rule
- Do **not** use the strongest model by default
- Use the **cheapest model that can solve the task reliably**
- Re-evaluate model choice on every turn
- Do not keep using a stronger model just because the previous turn needed it
- Escalate automatically when stronger reasoning is likely to reduce:
  - retries
  - architecture mistakes
  - build-fix loops
  - long-term technical debt
- This file is the canonical source for coding-task model selection and the required response header.

## Runtime Rule
- Do not assume the main agent can replace its own model mid-response
- If direct runtime switching is unavailable, keep the current main-thread model
- Route only necessary subtasks to other models when the environment supports it

## Project-First Rule
Prefer the project's existing:
- architecture
- naming conventions
- dependency injection style
- navigation style
- state-management pattern
- module boundaries
- testing style

Do not introduce new patterns unless the task explicitly requires it.

## Model Selection

### `GPT-5.3-codex`
Use for:
- commit messages
- PR descriptions
- short summaries
- README/docs edits
- docs-only maintenance
- copy-only UI text tweaks
- simple explanations
- simple DTOs / Codable structs
- mock JSON
- tiny renames
- trivial one-file edits
- accessibility identifiers
- simple boilerplate

Escalate if:
- more than 1-2 files are involved
- the result must compile reliably
- real business logic is involved
- build/test debugging appears
- architecture or state ownership becomes relevant

### `GPT-5.4`
Default for normal production coding:
- SwiftUI implementation when architecture is already known
- ViewModels
- UseCases
- Repositories
- DTOs and mappers
- ViewState
- API wiring
- unit tests
- compile fixes
- small/medium refactors
- standard bug fixes

Escalate to `GPT-5.5` if:
- architecture becomes the main problem
- the task crosses multiple layers
- concurrency or state ownership is tricky
- build fixes fail twice
- ambiguity is high
- a wrong solution is likely to create technical debt

### `GPT-5.5`
Use for:
- Implement UI part for all screens, when user provide ui by screenshot
- architecture
- ambiguous requirements
- non-trivial Figma/spec interpretation
- multi-layer changes
- offline/cache/database strategy
- sync logic
- optimistic UI updates
- concurrency-sensitive code
- performance-sensitive code
- difficult multi-file debugging
- large refactors
- architecture/security/performance review

## Budget Rules
- Read only the smallest relevant file set
- Do not read the whole project unless necessary
- Run the smallest meaningful build/test command
- Avoid broad refactors unless requested
- Do not loop blindly on build failures
- After 2 failed fix attempts, escalate internally or flag for human review

## Decision Default
- `GPT-5.3-codex` = trivial, cheap, text-heavy, boilerplate
- `GPT-5.4` = default production coding
- `GPT-5.5` = architecture, ambiguity, concurrency, DB/cache/sync, high-risk logic

## Follow-Up Rule
- After a high-end architecture turn, follow-up turns that become docs-only, copy-only, or small UX-text edits should drop back down to `GPT-5.3-codex` or `GPT-5.4` as appropriate
- Do not treat a whole task thread as permanently pinned to `GPT-5.5`
