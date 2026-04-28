# TchopApp Testing Instructions

## Purpose Of This Document
This document defines executable testing instructions for `TchopApp`.

It is not a generic QA checklist.
It is an operational document that tells the agent:

- what kind of testing task is being requested;
- what the entry point for that task is;
- what actions must be performed;
- what evidence must be collected;
- what result format must be returned to the user.

This is a living document.
Whenever a new testing mode is introduced, or an existing one changes, this file must be updated in the same work stream.

---

## How To Use This Document
Each instruction in this file must contain:

1. a clear task name;
2. the entry point the user provides;
3. the runtime actions the agent must perform;
4. the data that must be collected;
5. the exact structure of the report that must be returned.

If a request matches one of the instructions below, the agent must follow that instruction rather than improvising a new workflow.

---

## Instruction 1: UI-Driven API Testing

### Purpose
Use this instruction when the user wants to validate a server request that is triggered by a real UI action inside the app.

This instruction is for full-chain runtime validation.
The goal is not only to see whether the UI responds.
The goal is to confirm the entire request pipeline from UI gesture to final side effect.

### Entry Point
The user provides one of the following:

- a button to press;
- a control to toggle;
- a text field to type into;
- a tab to open;
- a cell or card to tap;
- a gesture to perform;
- any other user action that should trigger a server request.

Examples:

- "Tap the Like button on the featured article card"
- "Open Profile and toggle restore navigation"
- "Pull to refresh the feed"
- "Type text into search and submit"
- "Switch to a tab that triggers remote loading"

### Required Runtime Behavior
When this instruction is used, the agent must:

1. launch the app in the simulator with the appropriate runtime configuration;
2. navigate to the correct screen;
3. perform the exact UI action described by the user;
4. allow the real in-app action chain to execute;
5. observe the result across all relevant layers.

The test is valid only if the full runtime chain is exercised through the UI.
Static code reading alone is not enough for this instruction.

### Required Observation Scope
The agent must inspect the full path as far as the app currently implements it.

That includes, when applicable:

- UI event handling;
- SwiftUI view callbacks;
- view-model method calls;
- coordinator or routing behavior;
- repository calls;
- service or API manager calls;
- request construction;
- URL, method, body, query, headers;
- auth headers and token behavior if present;
- response status and response body;
- decoding/parsing;
- DTO creation;
- mapping into app/domain/presentation models;
- persistence writes;
- cache writes;
- widget sync side effects;
- visible UI update after completion;
- error handling path if the flow fails.

If some stage does not exist in the current implementation, the report must explicitly say so rather than guessing.

### Required Inputs The Agent May Need
If the action cannot be executed without extra setup, the agent must ask only for the minimum missing input.

Examples:

- login credentials;
- required launch environment;
- database backend mode;
- target screen or content identity if multiple similar elements exist.

### Required Report Format
The answer must be returned as a sequential trace.

The trace must be ordered chronologically from user action to final effect.

#### Success Case Format
If the flow succeeds, the agent must return:

1. the exact UI action performed;
2. the exact chain of runtime calls, step by step;
3. the request details:
   - HTTP method
   - URL/path
   - query items
   - headers
   - request body or encoded payload
4. the response details:
   - status code
   - relevant headers if important
   - response body summary
5. parsing and mapping details:
   - decoded DTO type
   - mapped app/domain model
6. persistence details:
   - whether anything was saved
   - which repository/method saved it
   - which backend/store received it
7. final user-visible result in the UI.

The report should be detailed enough that a developer can reconstruct the full runtime chain without rerunning the app immediately.

#### Failure Case Format
If the flow fails, the agent must return:

1. the exact UI action performed;
2. the full runtime chain up to the failure point;
3. the exact failing layer;
4. the exact error text, log, or observed failure signal;
5. a short explanation of what happened;
6. the most likely root cause;
7. the recommended fix;
8. the proposed implementation direction for that fix.

If multiple plausible causes exist, the agent must say so and separate:

- confirmed facts;
- likely cause;
- unconfirmed hypothesis.

### Required Level Of Detail
This instruction expects more than "request succeeded" or "button works".

At minimum, the report must be precise about:

- which method or callback was entered first;
- which object owned each next step;
- where the request was formed;
- where the response was decoded;
- where state was persisted or updated;
- where the visible UI result came from.

If names are known from the codebase, they must be included.

Examples:

- `NewsFeedView` callback
- `NewsFeedViewModel.handleFeaturedArticleAction(...)`
- `SwiftDataAppContentRepository.performFeaturedArticleAction(...)`
- `StubFeedAPIManager.performFeaturedArticleAction(...)`
- `APIManager.execute(...)`

### Required Evidence Quality
The agent should prefer direct runtime evidence over inference whenever possible.

Preferred evidence sources:

- simulator interaction;
- app logs;
- request logs;
- runtime state changes;
- repository or persistence side effects;
- concrete code paths confirmed against the current code.

If some part of the chain is inferred from code rather than observed directly, the report must mark it as inferred.

### Constraints
- The agent must not skip simulator execution if the request is meant to be triggered from the UI.
- The agent must not stop at the networking layer if the flow continues into decoding, persistence, or UI updates.
- The agent must not fabricate missing request or response fields.
- The agent must not report assumptions as confirmed runtime facts.

### Completion Criteria
This instruction is complete only when the user receives:

- the UI action performed;
- the chronological runtime trace;
- the request details;
- the response details;
- the persistence/result details;
- and, if applicable, the failure analysis and proposed fix.

---

## Future Instructions
Additional testing instructions should be added below this section.

Each new instruction must follow the same structure:

1. purpose;
2. entry point;
3. required runtime behavior;
4. required observation scope;
5. required report format;
6. completion criteria.
