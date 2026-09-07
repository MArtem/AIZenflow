# Gate Matrix

Legend:

- **A** = always for this risk level when code changes.
- **T** = when matching trigger applies.
- **H** = human approval/verification.
- **—** = normally not required.

| Gate | R0 | R1 | R2 | R3 | R4 | R5 |
|---|---:|---:|---:|---:|---:|---:|
| G00 task/acceptance criteria | A | A | A | A | A | A |
| G01 repo/profile/instruction inspection | A | A | A | A | A | A |
| G02 risk + trigger classification | A | A | A | A | A | A |
| G03 change plan | — | light | A | A | A | A |
| G04 architecture/invariant review | — | — | T | A | A | A |
| G05 human consequential-change approval | — | — | T | T/H | H | H |
| G10 forbidden/unsafe construct scan | — | A | A | A | A | A |
| G11 compiler/build | — | A | A | A | A | A |
| G12 targeted tests | — | T | A | A | A | A |
| G13 full relevant test plan | — | — | T | T | A | A |
| G14 concurrency gate | — | — | T | T | T | T |
| G15 sanitizer/runtime diagnostics | — | — | T | T | A when relevant | A when relevant |
| G16 memory/lifetime review | — | — | T | T | T | T |
| G17 networking/auth gate | — | — | T | T | T | T |
| G18 persistence/migration gate | — | — | T | T | A | A |
| G19 security/privacy gate | — | — | T | T | A | A |
| G20 dependency/supply-chain gate | — | — | T/H | T/H | H | H |
| G21 accessibility gate | — | T | T | T | T | T |
| G22 localization gate | — | T | T | T | T | T |
| G23 performance/responsiveness gate | — | — | T | T | T | A when perf-critical |
| G24 background/lifecycle gate | — | — | T | T | T | T |
| G25 public API/module compatibility | — | — | T | T | T | A when applicable |
| G26 build settings/signing/entitlements | — | — | T/H | T/H | H | H |
| G30 final diff scope review | A | A | A | A | A | A |
| G31 secrets/local-path/generated-artifact scan | — | A | A | A | A | A |
| G32 dependency/project/privacy diff review | — | A | A | A | A | A |
| G33 verification report | light | A | A | A | A | A |
| G34 pre-commit evidence gate | — | A | A | A | A | A |
| G40 clean/reproducible pre-PR validation | — | — | T | A | A | A |
| G41 release/rollback compatibility | — | — | — | T | A | A |
| G42 human PR/release signoff | — | — | project | project | H | H |

## Trigger tags

Core trigger set:

```text
CONCURRENCY
SWIFTUI
UIKIT
NAVIGATION
NETWORKING
AUTH
PERSISTENCE
MIGRATION
SECURITY
PRIVACY
MEMORY
PERFORMANCE
ERROR_HANDLING
ACCESSIBILITY
LOCALIZATION
DEPENDENCY
LOGGING
BACKGROUND
PUBLIC_API
BUILD_CONFIG
RELEASE
LEGACY
```

The agent may add project-specific tags, but these canonical tags drive the base library.

## Mode interaction

`FAST`, `STANDARD`, `STRICT` affect optional depth, not mandatory risk gates.

Example:

```text
User requests FAST
Change touches token refresh actor
 -> CONCURRENCY + AUTH
 -> at least R3
 -> R3 mandatory gates still run
```

## Completion rule

A task may be marked complete only when every required gate is one of:

- PASS;
- NOT_APPLICABLE with reason;
- APPROVED_EXCEPTION with linked exception record.

`SKIPPED`, `UNAVAILABLE`, or `FAILED` means the task is not fully verified.
