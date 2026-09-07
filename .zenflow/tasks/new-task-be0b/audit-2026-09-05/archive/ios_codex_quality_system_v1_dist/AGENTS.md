# iOS Engineering Agent Contract

This file is the compact mandatory bootstrap for Codex. More detailed rules live under `ios-quality/`.

## Priority

1. System/developer/user instructions.
2. Project-specific `AGENTS.override.md` or deeper-scoped `AGENTS.md` files.
3. `ios-quality/config/PROJECT_PROFILE.yaml` and `project.env`.
4. This file and the policy library.
5. Existing repository conventions when they do not conflict with higher-priority requirements.

If rules conflict, stop and report the conflict instead of silently choosing the more convenient rule.

## Core behavior

- Optimize for correctness, safety, maintainability, reviewability, and minimal blast radius.
- Never declare success from inspection alone. Completion requires verification evidence.
- Make the smallest change that fully solves the task. Avoid unrelated cleanup and opportunistic refactoring.
- Preserve existing architecture and conventions unless the task requires change or they create a concrete correctness/security problem.
- Do not introduce a dependency, change a dependency version, alter signing/entitlements, weaken security, perform destructive data migration, or change public API compatibility without explicit user approval when required by the gate matrix.
- Do not bypass compiler/concurrency/safety diagnostics simply to make code compile.
- Do not change tests to make a broken implementation pass unless the expected behavior itself changed and that change is justified.
- Never delete persistent user data as a fallback for a migration/opening failure.
- Never claim a device-specific, performance, accessibility, privacy, migration, or security behavior was verified if it was not actually checked.

## Mandatory startup sequence for any code-changing task

1. Read `ios-quality/config/PROJECT_PROFILE.yaml` if it exists.
2. Read `ios-quality/POLICY_ROUTER.md`.
3. Inspect repository status, relevant target/module, nearby tests, build configuration, and local conventions.
4. Produce task analysis using the concepts in `templates/TASK_ANALYSIS.md`.
5. Assign risk level R0-R5 and trigger tags.
6. Read all policy files required by those trigger tags.
7. Identify acceptance criteria, invariants, expected tests, and rollback concerns before editing.
8. If required information cannot be inferred safely from the repository, ask for clarification before making a consequential change.

## Mandatory implementation rules

- Swift 6 / concurrency diagnostics are correctness signals. Prefer fixing ownership/isolation/sendability rather than suppressing diagnostics.
- `@unchecked Sendable`, `nonisolated(unsafe)`, unsafe pointers, `Task.detached`, raw locks/semaphores, `try!`, `fatalError`, force unwraps, warning suppression, sanitizer suppression, and broad ATS exceptions are **review triggers**, not normal shortcuts.
- Unstructured `Task` must have a clear owner, lifetime, cancellation policy, and allowed mutation domain.
- UI state mutation must respect actor/main-thread requirements.
- Every `await` inside mutable actor-isolated logic is a reentrancy boundary; revalidate assumptions after suspension when necessary.
- New code should model impossible states out where practical and avoid duplicated mutable sources of truth.
- User-visible strings, accessibility, privacy, and error states are part of feature correctness.
- Networking changes must consider cancellation, retries/idempotency, status-code handling, decoding failures, authentication, timeouts, and sensitive logging.
- Persistence changes must consider existing on-device data and migration paths.

## Forbidden “fixes” unless explicitly justified and reviewed

Do not use these merely to silence a problem:

```text
@unchecked Sendable
nonisolated(unsafe)
@preconcurrency import
Task.detached
try!
fatalError / preconditionFailure in recoverable production flows
force unwrap introduced without a proven invariant
swiftlint:disable / warning suppression
SWIFT_SUPPRESS_WARNINGS
blanket NSAllowsArbitraryLoads
catch { } / ignored persistence failures
sleep-based synchronization in tests
removing/weakening a failing test
```

If one is truly necessary, document the invariant, alternatives considered, scope, and verification in the task/PR evidence.

## Verification contract

Before commit, run the applicable gates from `ios-quality/gates/GATE_MATRIX.md` using `ios-quality/scripts/quality_gate.sh` where possible.

At minimum for code changes:

- build the affected scheme/target;
- run targeted tests for changed behavior;
- inspect the final `git diff` line by line;
- confirm no unexpected dependency, project-file, entitlement, privacy-manifest, or generated-file changes;
- report unverified areas explicitly.

High-risk triggers require additional gates. Never downgrade a gate because it is inconvenient.

## Git / commit rules

- Work on a task branch, not protected integration branches.
- Do not rewrite unrelated history.
- Do not commit secrets, local machine paths, DerivedData, result bundles, or credentials.
- One commit should represent one coherent change unless the repository has a different established convention.
- Commit message must describe behavior/intent, not merely files changed.
- Before PR, the working tree should contain only intentional changes.

## Completion report

A completion message/PR must include:

- what changed;
- why the design is correct;
- risk level and trigger tags;
- build command/result;
- tests run/result;
- specialist gates run/result;
- files intentionally changed;
- known limitations or unverified behavior;
- any required follow-up or human approval.

If a required gate failed or could not run, the task is not “done.” Report it as blocked or partially verified.
