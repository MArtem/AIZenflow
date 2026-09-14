# Project Model Schema

`PROJECT_MODEL.json` is the durable interchange format for V4. Schema version: `4.0`.

Top-level sections:
- `meta`: schema version, generated time, repository root, source fingerprint.
- `git`: branch and cleanliness metadata.
- `inventory`: projects, workspaces, packages, schemes, test plans, CI/config files.
- `xcode`: observed build settings and optional tool output.
- `targets`: target-like records extracted from project files.
- `source`: source counts, languages, directories and framework imports.
- `signals`: technology and architecture signals with evidence/confidence.
- `command_candidates`: build/test/lint/release commands with provenance.
- `risks`: risk leads, severity, confidence and evidence.
- `active_skills`: skill names and selection reasons.
- `nested_agent_candidates`: proposed scopes and local concerns.
- `unknowns`: facts that matter but were not established.

Consumers must tolerate additive fields and reject incompatible major schema versions.
