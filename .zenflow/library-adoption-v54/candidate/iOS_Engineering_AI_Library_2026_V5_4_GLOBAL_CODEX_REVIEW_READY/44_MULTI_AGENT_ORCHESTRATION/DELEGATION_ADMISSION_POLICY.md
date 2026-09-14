# Delegation Admission Policy

Delegate only when **all** are true:
1. There are at least two materially distinct questions or disjoint code slices.
2. Each delegated node has a bounded deliverable and evidence contract.
3. Parallelism or independent review has concrete value.
4. Context can be scoped without hiding facts needed for correctness.
5. Write ownership can be made disjoint or read-only.

Strong reasons to delegate: cross-domain R3/R4 change; independent security/concurrency review; large repository discovery split by module; disjoint implementation slices; verification that can run independently.

Reject delegation for: formatting; small localized fixes; a single tightly coupled state machine; one shared file; work requiring continuous back-and-forth; tasks where every agent would read the same full repository and produce the same artifact.

## Admission score
Score 0–2 for each: domain independence, parallel value, verification independence, write separability, risk reduction. Delegate at **7+**, consider at **5–6**, otherwise remain single-agent. Explicit user request may override the threshold but not safety/write-scope rules.
