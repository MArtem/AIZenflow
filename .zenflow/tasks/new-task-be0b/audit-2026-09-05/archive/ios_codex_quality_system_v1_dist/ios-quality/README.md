# iOS Codex Quality System v1

A project-agnostic, quality-first rule library and executable gate system for Codex-driven iOS development.

## What this is

This repository is meant to be copied into an iOS codebase and used as a persistent engineering control layer for Codex. It combines:

- a compact root `AGENTS.md` that Codex reads automatically;
- project-specific configuration that is created during onboarding;
- normative engineering policies using MUST / SHOULD / MAY language;
- a risk model and trigger-based gate routing;
- executable build/test/diff/static checks;
- human approval gates for risky actions such as dependency changes;
- templates for task analysis, verification evidence, exceptions, ADRs, commits, and PRs.

The system is intentionally conservative. Its default is **quality and safety over speed**.

## Design goals

1. Reduce the probability of defects before code is written.
2. Reduce blast radius when a defect still occurs.
3. Prevent AI shortcuts that merely silence diagnostics.
4. Require evidence before a task can be declared complete.
5. Adapt to SwiftUI, UIKit, mixed apps, Swift 6.x, and legacy projects.
6. Support a generic core plus a later project-specific profile.
7. Keep human approval for consequential dependency, security, migration, and release decisions.

## Installation in a future project

Copy:

- `AGENTS.md` to the Git repository root;
- the entire `ios-quality/` folder (this package can be renamed to that) into the repository root.

Then run:

```bash
./ios-quality/scripts/discover_project.sh
```

Review the generated/discovered values and create:

```text
ios-quality/config/project.env
```

from:

```text
ios-quality/config/project.env.example
```

Also fill out `templates/PROJECT_PROFILE.yaml` and save the project-specific copy as:

```text
ios-quality/config/PROJECT_PROFILE.yaml
```

No dependency is installed automatically. If the system recommends SwiftLint, swift-format, a security scanner, or any other package/tool that is not already available, Codex must request explicit user approval before adding it.

## Normal Codex flow

```text
Task
  -> inspect AGENTS.md
  -> inspect project profile
  -> analyze task and repository
  -> classify risk and trigger tags
  -> read only the relevant policy files
  -> produce a change plan
  -> pass pre-change gate
  -> implement minimal correct patch
  -> build + targeted tests + triggered specialist gates
  -> review actual diff
  -> pass pre-commit gate
  -> commit
  -> pass pre-PR gate
  -> produce verification evidence
  -> human review / merge
```

## Modes

- `STRICT` — default. Maximum validation that is reasonable for the detected risk.
- `STANDARD` — normal feature work, but high-risk triggers still force stricter gates.
- `FAST` — only valid for R0/R1 work. It may never downgrade an automatically detected R3+ change.

Risk escalation always wins over a requested faster mode.

## Current technical baseline used to design v1

The generic rules were reviewed against public guidance available on 2026-09-05, including:

- Xcode 26.6 / Swift 6.3-era tooling;
- Swift 6 full data-race safety and Swift 6.2+ approachable concurrency behavior;
- Swift Testing and Xcode Test Plans;
- Apple privacy manifests / required-reason APIs;
- Apple accessibility, localization, performance, MetricKit and Instruments guidance;
- OWASP MASVS mobile security controls;
- current Codex `AGENTS.md` instruction behavior.

The **project profile**, not this date, controls what the agent may actually use. A legacy project must not be upgraded merely to satisfy this library.

## Important principle

This system is a guardrail, not a substitute for engineering judgment. A gate can require a human decision. A rule can have a documented exception. The agent must never “satisfy” the system by weakening tests, hiding warnings, disabling diagnostics, deleting data, or broadening permissions.
