# START HERE — V2

## Default operating stack
For a real repository task provide the agent with:
1. `MASTER_SYSTEM_PROMPT.md`
2. `V2_EXECUTION_PROTOCOL.md`
3. `PROJECT_CONTEXT_TEMPLATE.md` (filled or discoverable from repo)
4. one primary `OP-IOS-*` Deep Playbook
5. at most 1–2 supporting playbooks when risks genuinely intersect

Do **not** concatenate dozens of skills. Deep Playbooks already import the common quality/evidence rules.

## Choose a mode
- **IMPLEMENTATION** — new/changed behavior.
- **REVIEW** — PR/diff/architecture/security/performance audit.
- **DIAGNOSTIC** — crash/race/hang/leak/flaky/perf/data/network investigation.
- **MIGRATION** — Swift 6, UIKit→SwiftUI, Observation, persistence, dependencies, modularization, CI, etc.

## Before code
The agent must perform repository inspection and record:
- toolchain/deployment;
- source of truth;
- mutable-state/resource owner;
- actor/task/lifecycle boundaries;
- call sites/blast radius;
- relevant tests and CI commands;
- R0–R4 risk;
- invariants and most dangerous negative path.

## After code
The agent must execute available verification and report:
- `Verified` — observed build/test/instrument evidence;
- `Reasoned` — static/design conclusions not executed;
- `Unknown` — not verified.

## Fast routes
- Common task → `32_AGENT_PROMPTS_V2/PROMPT_INDEX.md`.
- Technology-specific deep reasoning → `31_DEEP_PLAYBOOKS/OP-IOS-*.md`.
- Code idiom/reference → `33_CODE_PATTERNS/CODE_PATTERN_INDEX.md`.
- Merge/release audit → `34_AUDIT_GATES/AUDIT_GATE_INDEX.md`.
- Investigation/migration/report skeleton → `35_ENGINEERING_TEMPLATES_V2/TEMPLATE_INDEX.md`.

## Hard stop
Never weaken ATS/trust/auth/privacy, destroy a production store, remove migration compatibility, or introduce `@unchecked Sendable` merely to make a build green. Escalate risk, collect evidence, and design a safe boundary instead.
