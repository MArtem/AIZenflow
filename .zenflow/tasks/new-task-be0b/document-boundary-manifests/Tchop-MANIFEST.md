# Tchop Documentation Boundary

## Scope
This folder contains only Tchop-specific documentation.

Allowed here:
- Tchop local rules and exceptions;
- Tchop plans, handoffs, ADRs, audits, histories, and reports;
- Tchop app-specific prompts or skills;
- Tchop integration notes for reusable packages;
- Tchop product, runtime, persistence, UI, release, and verification decisions.

Not allowed here:
- reusable/global rules unless copied only as explicit app-local reference;
- documentation for MVVMExample, BattleshipGame, AIFieldbook, or future apps;
- package-manager rules that are app-neutral and belong in `reusable/`;
- architecture-catalog content that is not Tchop-specific.

Local Tchop exceptions must stay here unless explicitly promoted to reusable through `DOCUMENT_BOUNDARY_STANDARD.md`.
