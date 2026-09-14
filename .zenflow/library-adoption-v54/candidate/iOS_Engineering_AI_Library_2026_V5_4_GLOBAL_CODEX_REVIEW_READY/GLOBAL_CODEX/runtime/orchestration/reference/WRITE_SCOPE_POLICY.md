# Write Scope Policy

## Default
Explorers, auditors and reviewers are read-only. Parallel editing is allowed only after ownership partitioning.

## Rules
- One file has one writer per wave.
- Directory ownership is acceptable only when boundaries are real and generated/shared files are excluded.
- If two tasks need the same file, serialize them or assign the shared file to the integrator.
- `project.pbxproj`, shared package manifests, central routing/DI registries, localization catalogs and generated outputs are high-collision resources.
- A writer discovering required out-of-scope edits must stop and request scope expansion; it must not silently cross ownership.
- Integration changes occur after child write scopes are closed.
