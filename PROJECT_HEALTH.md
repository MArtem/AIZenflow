# Project Health

## Purpose
This document is the reusable package and ownership map for iOS projects in this worktree.

Read it when you need to answer:
- what is reusable;
- what must stay app-specific;
- where new behavior should live;
- which boundary owns state, persistence, navigation, or platform integration.

## Root Rule
- If behavior is reusable and entity-agnostic, the package/manager should own it.
- App code keeps project-specific mapping, domain rules, endpoint semantics, persistence schema choices, routing, UI composition, and product policy.
- Do not add extra shim, protocol, factory, or adapter layers over a good reusable package unless there is a concrete current boundary requirement.
- Do not allow app-specific branding or source-project terminology in reusable/shared docs, package names, prompts, or skills.

## Reusable Package Inventory
### `AppNavigation`
Owns generic tab/router primitives and navigation snapshot persistence contracts.

Must not know about:
- concrete app tab enums;
- app route payloads;
- app URL structure;
- feature ViewModels or repositories.

### `AppFileStorage`
Owns product-neutral file storage domains, validation, protection policy hooks, and safe file operations.

Must not know about app content models, feature copy, or product-specific retention policy.

### `AppIntentSupport`
Owns reusable App Intents support primitives where appropriate.

Must not decide app-specific intent names, entity semantics, privacy policy, or feature behavior.

### `AppOnDeviceAI`
Owns reusable local AI capability checks and product-neutral wrappers when adopted.

Must not decide what user content may leave device boundaries.

### Other `App*` Packages
Packages under `./PackagesForReuse` own product-neutral mechanisms for networking, persistence, logging, observability, localization, permissions, lifecycle, validation, image/media handling, configuration, analytics, security, sync, cache, and platform capabilities.

The current package catalog is the source of truth for exact package availability.

## What Must Stay In The App Target
- app DTO to domain mapping policy;
- app persistence schema and migration/data-loss decisions;
- feature-specific repository composition;
- app routing and deep-link semantics;
- target-specific UI composition and design-system usage;
- app-specific user/session flows;
- local-only/cloud/privacy policy;
- product copy, localization strings, and accessibility labels.

## Runtime Notes
- Integration mode is project-specific and must be recorded in the active app/task docs.
- `./PackagesInUse`, `./PackagesForReuse`, SwiftPM, or another integration path may be selected only through the current project contract or ADR.
- Reusable baseline docs must not encode one app's active package list or integration decision.

## Placement Rule
If a new package or manager rule changes ownership boundaries, update this file.
If it changes only current task behavior, update task docs instead.

For hands-on integration guidance and reuse notes, use:
- [docs/PACKAGES_AND_MANAGERS.md](./docs/PACKAGES_AND_MANAGERS.md)

## Current Project Overlay

Package adoption and source-integration decisions for AI Fieldbook are app-specific. Load them
from `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook/` only when that app is
in scope; do not promote its current package list into this reusable ownership map.
