# AGENTS.md Design Standard

Use `AGENTS.md` as a routing map, not as an encyclopedia.

## Root file should contain
- project identity and top-level module map;
- source-of-truth links for architecture, commands and quality gates;
- mandatory before/after-edit behavior;
- risk/evidence rules;
- explicit paths to specialized skills;
- local non-obvious constraints that materially change decisions.

## Keep out of the root file
- long framework tutorials;
- duplicated Swift style guides;
- every possible edge case;
- volatile facts that can be mechanically discovered;
- instructions that apply only to one subtree.

## Nested AGENTS.md
Use a nested file when a subtree has distinct invariants: persistence schemas, SDK public API, extension targets, test fixtures, generated code, security-sensitive modules, or scripts. More local rules should narrow the parent, not duplicate it.

## Freshness
Every rule should have a clear owner/source. If the project reality differs from documentation, surface the drift and update the system of record instead of silently following stale text.
