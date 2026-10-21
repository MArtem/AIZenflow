# Build/modularity/tooling comparison — 2026-10-14

Ten bodies LIB-0193–LIB-0202 read completely and 30 dispositions inspected: ten active, twenty archive. Curated LIB-0192 was reviewed separately. This reads documentation about build/configuration/secrets; no app configuration, secret, toolchain or runtime was accessed.

- 0193-U01: Xcode Targets/SwiftPM/Modules and Modular checks preserve target/product/resource/plugin graph, visibility, actual boundaries and testing structure. Package Ownership differentiates catalog/source verification/app adoption/release; a package source does not authorize SwiftPM app integration.
- 0194-U01: Modules/Build Performance and Modular requirements retain dependency direction/cycles/transitive impact and measured clean versus incremental rebuild cost. More modules are not assumed faster.
- 0195-U01: Build Performance explicitly retains type-checking, dependency fanout, generated code/macros/scripts/module invalidation/linker; comparable measurement is required for a speed claim.
- 0196-U01: Xcode Configuration and Configuration Environments retain xcconfig precedence/inheritance, effective flags/warnings/language/isolation mode, explicit environments and no production demo fallback.
- 0197-U01: Targets And Build Phases explicitly retains schema/version inputs, reproducible generator, checked-in output policy, local/CI verification when permitted, declared script effects and generator correction instead of hand edits.
- 0198-U01: same section explicitly says style PASS does not justify compiler suppressions, unrelated churn or hidden machine changes; approved workflow/readability and scope remain.
- 0199-U01: Xcode SwiftPM/Supply Chain plus Dependency Approval/Removal/Update retain actual necessity/maintenance/platform/concurrency/privacy/license/size/transitive and exit costs; no package download or adoption follows.
- 0200-U01: Binary And Runtime Diagnosis explicitly measures symbols/resources/platform slices/linkage in comparable configurations and protects compatibility/resources/modularity. Source diff size cannot prove shipping size.
- 0201-U01: Xcode Configuration and Configuration Environments separate versioned public configuration from secure secret injection, prevent committed defaults/dev credentials shipping and require redacted diagnostics. Actual credential handling is not inspected here.
- 0202-U01: Reproducibility And CI explicitly retains pinned profile, approved caches, cache-key completeness/clean fallback, no hidden machine state, actionable developer diagnostics and local/CI parity. No install/configuration permission is implicit.

Engineering/Testing/Toolchain/current overrides preserve actual context, minimal diff, invariant/failure review and permitted evidence across all sources. Each U02 retires minimum-two options; each U03 retires V2/Library/deep-playbook bindings. Linked OP bodies remain independently unread. No missing useful condition identified within these ten sources. Technical freshness, actual build determinism/performance and executable examples remain UNVERIFIED.
