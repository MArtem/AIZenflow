# Master Plan — iOS Codex Quality System

## 1. Objective

Create a persistent engineering control system that Codex applies throughout the complete lifecycle of iOS code changes: task interpretation, repository analysis, design, implementation, testing, validation, commit, PR preparation, and release-risk review.

The system is designed to minimize both **defect probability** and **defect impact**.

## 2. Architecture

```text
User task / Jira / local prompt
          |
          v
Root AGENTS.md (small, mandatory)
          |
          v
Project Profile + repo-scoped overrides
          |
          v
Risk classifier + trigger tags
          |
          v
Policy Router
          |
          +--> Core policies
          +--> Trigger-specific policies
          |
          v
Change plan + acceptance criteria + invariants
          |
          v
Implementation
          |
          v
Executable quality gates
          |
          v
Evidence package
          |
          v
Commit / PR
          |
          v
Human review / merge
```

## 3. Rule taxonomy

Every normative rule is classified as:

- **MUST** — violation blocks the gate unless an approved exception exists.
- **SHOULD** — default expectation; deviation requires a concrete reason.
- **MAY** — allowed option, selected by project context.

A separate **review trigger** category identifies constructs that are legal but disproportionately risky.

## 4. Scope model

The generic library intentionally does not impose one architecture. It supports SwiftUI, UIKit, mixed apps, modular monoliths, SPM modules, legacy code, and different minimum iOS versions.

Project-specific decisions are captured in `config/PROJECT_PROFILE.yaml`, such as:

- Xcode / Swift version;
- Swift language mode;
- default actor isolation / upcoming features;
- minimum iOS version;
- SwiftUI/UIKit mix;
- architecture and dependency direction;
- package manager and allowed dependencies;
- workspace/project/scheme/test plan;
- supported locales and accessibility requirements;
- persistence/networking stack;
- CI/release conventions.

## 5. Risk model

- **R0 — non-code**: docs/comments/metadata with no runtime effect.
- **R1 — local low risk**: isolated UI/style or pure-function change with small blast radius.
- **R2 — normal product change**: normal feature/bug spanning a small number of components.
- **R3 — high risk**: concurrency, networking, public API, dependency, cross-module, persistence, background/lifecycle, or broad state changes.
- **R4 — critical**: auth/security/privacy, irreversible operations, migrations with data-loss potential, payment/identity, signing/entitlements.
- **R5 — release/systemic**: broad architecture/repository migration, release pipeline, high-impact upgrade path, or change whose failure can affect most users and is hard to roll back.

Risk is determined by potential impact, reversibility, reach, and uncertainty — not lines changed.

## 6. Validation modes

- **STRICT (default):** all gates appropriate to risk and trigger set.
- **STANDARD:** normal development throughput; never suppresses mandatory R3+ specialist gates.
- **FAST:** permitted only for R0/R1 and automatically escalates when triggers demand it.

## 7. Lifecycle

### Phase A — Intake

1. Parse requested behavior and constraints.
2. Inspect relevant repository areas before suggesting a solution.
3. Identify existing tests and conventions.
4. Define explicit acceptance criteria and non-goals.
5. Identify ambiguity whose resolution could materially change implementation.
6. Assign risk + trigger tags.

### Phase B — Design

1. Define state ownership and dependency boundaries.
2. Define concurrency/isolation/cancellation if applicable.
3. Define persistence/network/security implications.
4. Identify migration/backward-compatibility requirements.
5. Select smallest solution with acceptable risk.
6. Determine test and gate plan before coding.

### Phase C — Implementation

1. Make a minimal patch.
2. Preserve public behavior not targeted by the task.
3. Avoid unsafe escape hatches.
4. Add/adjust tests concurrently with behavior.
5. Keep generated/build files out of the patch unless intentional.

### Phase D — Verification

1. Static/compiler diagnostics.
2. Build affected target/scheme.
3. Targeted tests.
4. Full tests when risk requires.
5. Trigger-specific gates: concurrency, sanitizer, migration, accessibility, privacy, performance, etc.
6. Review actual diff for scope and accidental changes.

### Phase E — Commit / PR

1. Ensure clean intentional diff.
2. Re-run required pre-commit gates.
3. Commit coherent change.
4. Run stricter pre-PR gates.
5. Produce evidence-based PR description.
6. Explicitly list unverified behavior and residual risks.
7. Human review/merge.

## 8. Enforcement levels

The library uses three mechanisms:

1. **Compiler/tool enforced** — build errors, Swift 6 data-race safety, tests, sanitizer/runtime issues, lint.
2. **Script enforced** — diff patterns, dependency changes, secret patterns, project-file changes, privacy manifest presence, test/build commands.
3. **Reasoning/human enforced** — architecture, correctness, threat model, migration safety, UX/accessibility quality, dependency approval.

A reasoning rule must not be falsely presented as fully automated.

## 9. High-value defect prevention themes

The system concentrates effort where iOS defects are expensive:

- stale or duplicated UI state;
- actor/task lifetime and cancellation errors;
- main-thread hangs and accidental MainActor CPU work;
- retain cycles and long-lived async captures;
- partial network/error handling;
- token refresh races;
- corrupted or destructive persistence migration;
- privacy/secret leakage in logs;
- dependency/supply-chain drift;
- unlocalized or inaccessible UI;
- project settings, entitlements and signing drift;
- tests that pass only by timing or shared mutable state;
- AI-generated broad refactors unrelated to the requested behavior.

## 10. Project onboarding

When a real project appears, Codex runs a read-only discovery phase and creates a project profile. It must discover rather than assume:

- Git default/integration branch and repository cleanliness expectations;
- `.xcworkspace` vs `.xcodeproj`;
- shared schemes and test plans;
- build configurations;
- Swift language version and concurrency build settings;
- deployment target;
- SwiftUI/UIKit usage;
- module graph and package dependencies;
- code style/format/lint tooling;
- testing framework and existing test taxonomy;
- persistence, networking, authentication and analytics stacks;
- privacy manifest, entitlements and capabilities;
- localization catalog(s);
- CI commands if present.

The generated profile requires human review before it becomes authoritative.

## 11. Human approval gates

Codex must ask before:

- adding/removing/updating dependencies;
- intentionally changing a dependency resolution;
- changing public API in a way that can break clients;
- changing signing, entitlements, capabilities, keychain access groups, ATS exceptions, or privacy declarations with external impact;
- destructive or irreversible migration strategies;
- weakening security/diagnostics/tests;
- broad architecture migration outside task scope;
- committing/pushing when the user’s workflow requires confirmation.

## 12. Evidence package

Every completed non-trivial task should be able to produce:

```text
Risk: R2
Triggers: SWIFTUI, NETWORKING

Build:
  command: ...
  exit: 0

Tests:
  targeted: 17 passed
  full: not required by R2 policy

Special gates:
  localization: PASS
  privacy: PASS
  dependency diff: PASS (none)

Diff review:
  5 files intended
  0 unexpected project/dependency changes

Unverified:
  physical-device low-connectivity transition

Residual risk:
  low
```

## 13. Maintenance strategy

The library must be versioned independently from app code. Review source baselines when:

- a new stable Xcode/Swift release lands;
- Swift concurrency semantics change;
- App Store privacy/security requirements change;
- OWASP MASVS/MASTG changes materially;
- Codex instruction-loading behavior changes;
- project-specific postmortems reveal a missing rule.

Rules discovered from incidents should be promoted from local workaround to repeatable gate when appropriate.
