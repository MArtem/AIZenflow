# Project Health

## Purpose
Ownership and runtime health map for `<AppName>`.

Use it to decide:
- what is reusable
- what must stay app-specific
- where new behavior should live
- what risks are known

## Root Rule
Reusable, entity-agnostic mechanics should live in shared packages/modules. App-specific product policy, UI composition, persistence schema, routing, and feature contracts stay in the app layer.

## Module / Package Inventory
Fill this as the project structure becomes known.

### `<ModuleOrPackageName>`
Owns:
- `<responsibility>`

Must not know about:
- `<forbidden dependency>`

## Current Known Risks
- `<risk>` — status: `<open/mitigated/accepted>`

## Verification Baseline
- Build command: `<command>`
- Test command: `<command>`
- Static gates: `<command>`
