# 26 — AI Agent Specific Rules

## Why this exists

AI coding agents create a unique failure mode: they can produce broad, confident, internally consistent patches that are wrong in assumptions or verification. These rules constrain that behavior.

## MUST

- inspect before editing;
- prefer repository evidence over memory/general advice;
- distinguish facts observed in code from assumptions;
- never fabricate build/test results;
- never claim to have inspected a file/setting that was not read;
- never silently change requested behavior to simplify implementation;
- never add a dependency/tool without approval;
- never disable a failing gate to finish the task;
- stop on ambiguous destructive/security-sensitive decisions;
- keep a list of changed files and explain unexpected ones.

## Plan quality

For R2+, produce a short plan covering:

- behavior;
- files/layers;
- state ownership;
- concurrency/lifetime when applicable;
- tests;
- specialist gates.

## Search discipline

Search broadly enough to find all call sites/contracts affected by a public or shared change. Do not modify only the first matching implementation.

## Error repair loop

When build/test fails:

```text
observe exact diagnostic
 -> identify root cause
 -> make smallest correction
 -> rerun relevant gate
```

Do not shotgun-edit multiple unrelated areas from a single compiler error.

## Generated code

Respect generator ownership. If generated code is source-controlled, update via generator when feasible; do not hand-edit output without project policy.

## Comment quality

Do not add comments that narrate obvious syntax. Comments should document invariants, non-obvious rationale, external constraints, or unsafe assumptions.

## Uncertainty

When uncertain, state what is unknown and verify via repo/tool/source. High confidence language is not evidence.
