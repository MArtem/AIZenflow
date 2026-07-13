# BattleshipGame Documentation Boundary

## Scope
This folder contains only BattleshipGame-specific documentation.

Allowed here:
- BattleshipGame local rules and exceptions;
- BattleshipGame plans, handoffs, ADRs, audits, histories, and reports;
- BattleshipGame app-specific prompts or skills;
- gameplay, UX, runtime, persistence, and verification decisions for BattleshipGame.

Not allowed here:
- reusable/global rules unless copied only as explicit app-local reference;
- documentation for Tchop, MVVMExample, AIFieldbook, or future apps;
- game-engine or architecture rules that are app-neutral and belong in `reusable/`.

Local BattleshipGame exceptions must stay here unless explicitly promoted to reusable through `DOCUMENT_BOUNDARY_STANDARD.md`.
