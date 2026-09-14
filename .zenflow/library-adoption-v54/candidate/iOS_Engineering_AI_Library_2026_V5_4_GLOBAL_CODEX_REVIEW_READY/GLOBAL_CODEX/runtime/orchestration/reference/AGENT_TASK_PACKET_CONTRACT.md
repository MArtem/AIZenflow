# Agent Task Packet Contract

A delegated task must be solvable without reconstructing the coordinator's entire reasoning.

## Required packet
- **Task name / node ID**
- **Role**
- **Outcome** — one observable deliverable
- **Known facts** — repository-observed facts only
- **Assumptions/unknowns**
- **Invariants**
- **Read scope**
- **Write scope**
- **Do not touch**
- **Relevant commands** — observed commands only
- **Evidence required**
- **Result schema**
- **Escalate when**

## Result contract
Return: status, findings/changes, claims with evidence, files inspected/changed, commands actually run, verification result, confidence, unresolved unknowns, and conflicts with task assumptions. Never hide partial failure behind a success summary.
