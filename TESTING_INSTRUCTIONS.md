# TchopApp Testing Instructions

## Purpose
This file defines the active verification policy for `TchopApp`.

Use it for:
- build/test scope selection
- API tracing mode selection
- reporting verification results

## Core Baseline
- Do not write tests by default
- Do not run tests by default
- Do not boot simulator UI by default
- Use the cheapest verification path that proves the requested behavior
- Do not run `Low` build verification automatically after every step; run it only when the recent change set is large enough, risky enough, or integration-sensitive enough that a compile check is justified by cost

## Verification Levels
Verification runs only when the user explicitly asks for them.

### `Absent`
- no build
- no tests
- no simulator verification

### `Low`
- build on `iPhone 17 Pro (iOS 26.0)`

### `Medium`
- all requested tests
- build on `iPhone 17 Pro (iOS 26.0)`

### `Full`
- all requested tests
- build on `iPhone 16 Pro (iOS 18.2)`
- build on `iPhone 17 Pro (iOS 26.0)`

## API Inspection First
When the user asks to inspect an API path, do not default to XCTest or simulator UI.

Use first:
1. `scripts/api_http_trace`
2. `scripts/api_method_trace`

### `scripts/api_http_trace`
Use when the user needs:
- real HTTP request/response tracing
- transport-layer inspection

### `scripts/api_method_trace`
Use when the user names a known app method and wants:
- code-path trace
- real HTTP when that path reaches transport
- mapping/persistence explanation after transport

Current known method id:
- `login.submit`

## Mode Selection
Use the cheapest mode that still answers the user request:

1. method-driven API tracing
2. feature-action verification
3. UI-driven verification

Use UI-driven verification only when the user explicitly needs:
- button/gesture wiring validation
- input-field behavior
- navigation transitions
- visibility/state changes that exist only at UI level
- true end-to-end screen interaction

## New Screen Workflow
For new API-backed screen work, prefer this order:

1. discovery
2. screen/state/API contract definition
3. trace method id definition if useful
4. API integration and mapping
5. cheap trace verification
6. UI wiring
7. UI-driven verification only if explicitly requested

## Reporting Rules
When verification is run, report:
- what level was executed
- what commands were run
- what passed
- what failed
- whether failure is code, test, or environment infrastructure

If a requested verification run finds a real project issue:
- fix it
- rerun the same verification level
- report the rerun result

## Canonical Commands
- Build/test helper:
  [scripts/verify.sh](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/verify.sh)
- HTTP trace:
  [scripts/api_http_trace](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/api_http_trace)
- Method trace:
  [scripts/api_method_trace](/Users/Artem/.zenflow/worktrees/new-task-be0b/scripts/api_method_trace)

## Archive Policy
Older verbose testing workflows are preserved only in:
- [docs/archive/TESTING_INSTRUCTIONS.legacy.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/docs/archive/TESTING_INSTRUCTIONS.legacy.md)

That file is not part of the default read path.
