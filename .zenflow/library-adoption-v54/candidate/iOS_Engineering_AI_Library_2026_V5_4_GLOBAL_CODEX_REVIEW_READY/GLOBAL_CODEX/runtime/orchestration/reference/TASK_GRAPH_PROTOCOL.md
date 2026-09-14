# Task Graph Protocol

Represent work as a DAG, not a flat agent list.

Each node requires:
- stable `node_id`
- role and objective
- dependencies
- read scope
- write scope (`[]` for read-only)
- required facts/invariants
- required evidence level
- output contract
- stop condition
- escalation condition

## Graph rules
- No cycles.
- A node may start only when dependencies that affect its correctness are closed.
- Parallel writable nodes must have disjoint file/glob ownership.
- Cross-cutting shared files (`project.pbxproj`, package manifests, generated schemas, central DI containers) are serialized under one owner.
- Verification nodes do not silently mutate product code; findings return to the integrator unless explicitly authorized.
- Prefer the smallest graph that covers material risk boundaries.
