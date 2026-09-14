# Evidence Ledger Protocol

The coordinator keeps a ledger for every material claim.

Fields: `claim_id`, claim, status (`supported|contested|unknown|stale`), evidence type, source/file/command, agent/node, confidence, timestamp/run, affected decision.

Evidence priority is contextual but generally: observed runtime/test/build output > repository source/config > deterministic derivation > heuristic inference > agent opinion.

An agent report is provenance, not proof. When two reports conflict, compare their underlying evidence. Evidence becomes stale when the project fingerprint or relevant files change.
