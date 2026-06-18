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

## Quality-First Delivery Rule
When a feature is moving from prototype/restoration state toward production-ready status, do not rely on the original implementation pass alone.

Run a separate production-hardening pass that checks:
1. product contract completeness
2. state and lifecycle correctness
3. package/app ownership correctness
4. platform constraints and edge cases
5. performance and memory risks
6. persistence/sync implications if relevant
7. accessibility and interaction semantics
8. verification strategy and whether targeted tests or review are justified

If required information is missing for one of these checks, ask for it explicitly instead of guessing.

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

## Production-Hardening Workflow
When the user prioritizes final quality over raw speed, use this order before calling a feature production-ready:

1. lock the product contract
2. implement the minimum correct version
3. run targeted contract verification
4. run production-hardening review across architecture, lifecycle, performance, memory, and edge cases
5. request any missing design/TZ/platform details instead of guessing
6. run the smallest justified verification that proves the hardened result

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
  [scripts/verify.sh](./scripts/verify.sh)
- HTTP trace:
  [scripts/api_http_trace](./scripts/api_http_trace)
- Method trace:
  [scripts/api_method_trace](./scripts/api_method_trace)

## Archive Policy
Older verbose testing workflows are preserved only in:
- [docs/archive/TESTING_INSTRUCTIONS.legacy.md](./docs/archive/TESTING_INSTRUCTIONS.legacy.md)

That file is not part of the default read path.
