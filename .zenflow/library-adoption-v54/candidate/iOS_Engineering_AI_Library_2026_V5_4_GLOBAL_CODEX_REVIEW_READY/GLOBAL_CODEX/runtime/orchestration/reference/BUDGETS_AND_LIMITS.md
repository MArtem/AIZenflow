# Budgets and Limits

V5 uses explicit repository budgets regardless of runtime capability.

## Defaults
- max child agents per wave: 4
- max total child agents per task: 8
- max nesting depth: 1
- max duplicate independent reviewers for one question: 2
- max arbitration agents: 1 per unresolved conflict
- child context: minimum sufficient task packet; avoid full-history cloning when a scoped packet is enough and the runtime supports scoped forks

## Stop conditions
Stop spawning when: task graph is covered; remaining nodes are dependent; new work duplicates existing nodes; evidence converges; token/context cost exceeds expected risk reduction; or integration becomes the critical path.

Budgets may be raised by explicit user instruction, but write-scope and safety gates remain.
