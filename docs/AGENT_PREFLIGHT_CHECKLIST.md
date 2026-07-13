# Agent Preflight Checklist

## Purpose
Use before any non-trivial implementation, refactor, documentation migration, package adoption, review, or new project/task bootstrap.

## Checklist
- Correct app/worktree?
- Correct task ID?
- Correct sandbox root under `/Users/Artem/.zenflow`?
- Correct documentation boundary?
- Correct source of truth from `./docs/SOURCE_OF_TRUTH_MAP.md`?
- Correct model route from `./docs/MODEL_ROUTING_RULE.md`?
- Product requirements and acceptance criteria clear?
- Build/test/simulator permissions clear?
- Files likely touched identified?
- User approval needed for any irreversible, external, destructive, or broad action?
- Local exception needed? If yes, create a local exception ADR.

## Stop Rule
If ownership, product behavior, persistence, privacy, navigation, state flow, or acceptance criteria are unclear, stop and ask instead of guessing.
