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

### Local Trace Commands
Two lightweight local commands are now part of the testing toolbox:

1. `scripts/api_http_trace`
2. `scripts/api_method_trace`

They exist specifically to avoid the expensive path of simulator UI, test targets, and `xcodebuild` when the user only wants API-chain inspection.

`api_http_trace` is the lowest-cost transport tracer.
It performs a real HTTP request and prints request/response details.

`api_method_trace` is the lowest-cost app-flow tracer currently available.
It resolves a known app method to its code path, prints the chain, and when the method reaches HTTP it executes the real request through `api_http_trace`.

Important constraint:
`api_method_trace` is intentionally lightweight.
It does not boot the app, run UI, or execute XCTest.
Its contract is:

- static code-path trace from the named app method;
- real HTTP request when that method produces one;
- explicit description of mapping/persistence steps that follow in app code.

---

## How To Use This Document
Each instruction in this file must contain:

1. a clear task name;
2. the entry point the user provides;
3. the runtime actions the agent must perform;
4. the data that must be collected;
5. the exact structure of the report that must be returned.

If a request matches one of the instructions below, the agent must follow that instruction rather than improvising a new workflow.

### Default Mode Selection
API-triggered testing must not default to the most expensive runtime path.

Use the cheapest mode that still proves the requested behavior:

1. `Method-Driven API Testing`
2. `Feature-Action API Testing`
3. `UI-Driven API Testing`

`UI-Driven API Testing` is reserved for cases where the user explicitly wants to validate:

- button or gesture wiring;
- field/input behavior;
- navigation transitions;
- visibility or state changes that only exist at the UI layer;
- or a true end-to-end screen interaction.

If the user says only "test method ..." or names a known feature entry method, the agent should not start with the simulator.

### New Screen And API Workflow
For new feature work, the preferred delivery order is:

1. screen and user-flow discovery;
2. API contract intake from Swagger/OpenAPI;
3. state and persistence policy definition;
4. stable trace method id definition;
5. API integration and mapping;
6. `api_method_trace` verification;
7. UI wiring;
8. optional UI-driven validation only if explicitly requested.

This order is intentional.
The API and state contract should be stable before expensive UI-level validation.

### Mandatory Discovery Questions Before Starting A New Screen
When the user says work is starting on a new screen or feature, the agent must first collect the minimum implementation contract.

The agent should ask about all items below unless the user already provided the answer:

1. screen goal and user flow;
2. source of truth for data;
3. read-only fields vs editable fields;
4. user actions available on the screen;
5. required UI states:
   - loading
   - success
   - empty
   - error
   - partial error
6. required persistence behavior:
   - save locally or not
   - overwrite or merge
   - refresh from persistence after save or not
7. update policy:
   - optimistic
   - non-optimistic
   - partial refresh
   - full refresh
8. API contract source:
   - Swagger/OpenAPI
   - examples
   - auth requirements
   - required headers
9. error policy:
   - inline error
   - blocking error
   - retry behavior
10. desired trace method ids for future low-cost API verification.

The agent should not start implementation until these answers are either provided or safely inferred and stated back explicitly.

---

## Instruction 1: Method-Driven API Testing

### Purpose
Use this instruction when the user wants the cheapest practical verification of a server-triggering flow and can provide, or wants the agent to determine, the exact app method that starts the chain.

This is the default mode for new API integration testing.

### Preferred Local Entry
Use:

```sh
scripts/api_method_trace <method-id> [options]
```

Current supported method identifiers:

- `login.submit`

Future feature work should add new stable method identifiers such as:

- `profile.load`
- `profile.update`
- `feed.refresh`
- `featuredArticle.like`
- `featuredArticle.comment`

Current supported environments:

- `reqres_demo_auth`
- `local_stub`

### Entry Point
The user provides one of the following:

- an exact method name to invoke;
- a feature method plus parameters;
- a method name and permission to choose parameters;
- a new API contract plus a request to expose and test the launch method.

Examples:

- "Test method `submitRegistration` with these parameters"
- "Run `refresh()` and choose valid inputs yourself"
- "I will give you Swagger, add it, then tell me the method to call"

### Required Runtime Behavior
When this instruction is used, the agent must:

1. identify the exact entry method;
2. construct the smallest valid runtime graph needed to invoke it;
3. call the method directly;
4. let the real downstream chain execute;
5. observe request creation, response handling, mapping, persistence, and final state changes.

Simulator UI interaction is not required for this instruction.
`xcodebuild` and XCTest are also not required for this instruction.

### Required Observation Scope
The agent must inspect the full chain below the method entry point.

That includes, when applicable:

- method ownership and caller context;
- validation logic;
- view-model or coordinator logic;
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
- final returned value or published state mutation.

When the method is handled through `api_method_trace`, the downstream HTTP request must still be executed for real if the code path reaches transport.

### Required Inputs The Agent May Need
If the user does not provide parameters, the agent may:

- derive valid inputs from code;
- derive valid inputs from fixtures;
- derive valid inputs from Swagger/OpenAPI examples;
- state which inputs were chosen and why.

The agent should ask for extra input only when parameters cannot be safely inferred.

### Required Report Format
The answer must be returned as a chronological trace starting from the invoked method.

#### Success Case Format
If the flow succeeds, the agent must return:

1. the exact method invoked;
2. the parameters used;
3. the exact chain of runtime calls, step by step;
4. the request details:
   - HTTP method
   - URL/path
   - query items
   - headers
   - request body or encoded payload
5. the response details:
   - status code
   - relevant headers if important
   - response body summary
6. parsing and mapping details:
   - decoded DTO type
   - mapped app/domain model
7. persistence details:
   - whether anything was saved
   - which repository/method saved it
   - which backend/store received it
8. final returned value or observable state result.

#### Failure Case Format
If the flow fails, the agent must return:

1. the exact method invoked;
2. the parameters used;
3. the full runtime chain up to the failure point;
4. the exact failing layer;
5. the exact error text, log, exception, or failure signal;
6. a short explanation of what happened;
7. the most likely root cause;
8. the recommended fix;
9. the proposed implementation direction for that fix.

### Completion Criteria
This instruction is complete only when the user receives:

- the method entry point used;
- the parameters used;
- the chronological runtime trace;
- the request details;
- the response details;
- the mapping/persistence details;
- and, if applicable, the failure analysis and proposed fix.

---

## Instruction 2: Feature-Action API Testing

### Purpose
Use this instruction when the user does not name a low-level method, but does name a feature action that is already exposed in the app layer and does not need real UI interaction.

This is a middle ground between direct method invocation and full simulator-driven testing.

### Entry Point
The user provides one of the following:

- a feature action name;
- a logical action on a screen model;
- a known app flow trigger that already maps to one app-layer entry method.

Examples:

- "Test the registration action"
- "Test featured article like action"
- "Test feed refresh action"

### Required Runtime Behavior
When this instruction is used, the agent must:

1. resolve the action to the real app-layer method that owns it;
2. invoke that action without simulator UI;
3. let the downstream request chain execute;
4. observe the same request/response/mapping/persistence path as in method-driven testing.

### Required Report Format
The report format matches `Method-Driven API Testing`, but must additionally include:

1. the named feature action from the user;
2. the resolved concrete method that was actually invoked.

### Completion Criteria
This instruction is complete only when the user receives:

- the feature action they requested;
- the resolved concrete method;
- the chronological runtime trace;
- the request details;
- the response details;
- the mapping/persistence details;
- and, if applicable, the failure analysis and proposed fix.

---

## Instruction 3: UI-Driven API Testing

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
