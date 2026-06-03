# New Chat Handoff

## Identifiers
- Project: `TchopApp`
- Worktree: `/Users/Artem/.zenflow/worktrees/new-task-be0b`
- Task: `new-task-be0b`
- Task ID: `be0b925f-37c1-468e-a4b0-061fc6ae30cd`
- Previous chat ID: `cafd90cf-f9f7-4f9d-b4b9-ae98ba2ff693`
- Linked project worktree: `/Users/Artem/.zenflow/worktrees/mvvmexample-3c80`
- Required model: **GPT-5.5**

## Mandatory Startup Rule
Before any code, documentation, git, project, build, or task action:

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Mandatory Startup Read Order
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
8. `./.zenflow/tasks/new-task-be0b/handoff.md`
9. `./.zenflow/tasks/new-task-be0b/plan.md`
10. `./docs/documentation-split/reusable/MVVMEXAMPLE_REMEDIATION_SPEC.md`
11. `./docs/IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`
12. `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`
13. `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`

## Mandatory Working Response Header
Every working, status, readiness, planning, or confirmation response must start with:

- model
- active phase
- files being inspected or changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation inside `/Users/Artem/.zenflow`

## Current User Rules
- Treat every implementation as highest-level production product code; never lower quality because a project is described as demo, sample, prototype, test, or pre-production.
- For reviews, audits, planning, and requirement analysis, provide the fullest unbiased analysis with priorities. Do not silently simplify, defer, dismiss, or complicate scope on the user's behalf.
- Do not guess product decisions. Ask when behavior is ambiguous.
- Avoid decorative abstractions, wrappers, protocols, factories, and use cases.
- Reusable packages provide mechanisms; app and feature layers provide product decisions.
- Package-owned tests must live with their package so source, tests, and documentation can move together.
- New projects use neutral reusable package naming such as `AppInfrastructure`, `AppNetworking`, and `AppLocalization`; do not promote `Tchop*` branding into unrelated projects.
- New-project MVVM defaults to explicit intent methods. Do not use generic `send(_:)`, `dispatch(_:)`, or UI action enums as boilerplate without explicit approval and documented rationale.
- Do not modify `./TchopAppTests` unless the user explicitly allows test writing again. Package tests under `./Packages/TchopInfrastructure/Tests` are allowed for package work.
- Do not run simulator UI, manual validation, or Instruments unless explicitly requested.
- Keep `./.zenflow/tasks/new-task-be0b/plan.md` updated before finishing a work block.

## Current Task State
The approved reusable package universality and hardening scope has progressed through:

- generic mechanism-vs-product-policy cleanup for widgets and UI configuration;
- product localization resources split from reusable localization lookup;
- analytics and error core/adapter target splits;
- networking source modularization;
- package README, DocC, neutral promotion guidance, and package-owned tests;
- analytics and branding extensibility;
- Core Data background execution boundary;
- networking auth refresh coalescing, injectable retry sleeper, rich bounded HTTP failure context, and task cancellation propagation;
- explicit main-context database contracts and `SwiftDataModelActorDatabaseManager`;
- `NavigationEvent` value isolation cleanup;
- `SyncCore` / `SyncObservation` split so the sync mechanism no longer depends on Observation UI state.

The `TchopApp` worktree was clean when this handoff was prepared.

## Latest Verification Baseline
- `(cd ./Packages/TchopInfrastructure && swift test)` succeeded with **64 XCTest tests and 37 Swift Testing tests**.
- `./scripts/verify.sh low` succeeded with **BUILD SUCCEEDED**.
- `plutil -lint ./TchopApp.xcodeproj/project.pbxproj` succeeded.
- `git diff --check` succeeded.
- `python3 ./scripts/check_docs_index.py` succeeded.

## Linked MVVMExample State
The linked worktree `/Users/Artem/.zenflow/worktrees/mvvmexample-3c80` contains uncommitted applicable package-sync changes:

- `./Packages/AppInfrastructure/Package.swift`
- `./Packages/AppInfrastructure/Sources/AppImageLoading/CachedRemoteImageView.swift`
- `./Packages/AppInfrastructure/Sources/AppImageLoading/ImageMemoryCache.swift`
- `./Packages/AppInfrastructure/Sources/AppImageLoading/RemoteImagePipeline.swift`
- `./Packages/AppInfrastructure/Sources/AppImageLoading/PlatformImage.swift`
- `./Packages/AppInfrastructure/Sources/AppLocalization/AppStrings.swift`
- `./Packages/AppInfrastructure/Sources/AppNetworking/URLSessionNetworkClient.swift`
- `./Packages/AppInfrastructure/Tests/AppImageLoadingTests/ImageMemoryCacheTests.swift`
- `./Packages/AppInfrastructure/Tests/AppNetworkingTests/URLSessionNetworkClientTests.swift`

Previously verified in MVVMExample:

- `(cd ./Packages/AppInfrastructure && swift test)` succeeded with 14 Swift Testing tests.
- `./scripts/verify.sh build` succeeded with `BUILD SUCCEEDED`.
- `git diff --check` and docs index checks succeeded.

Do not overwrite or discard those changes. Before any MVVMExample action, run `git status --short` in that worktree and reread its local rules.

## Next Safe Work Block
Perform a focused package concurrency audit of remaining `@unchecked Sendable` declarations. For each declaration:

1. identify mutable state ownership and all cross-task/process access;
2. prove the current lock, actor, immutable-value, or framework thread-safety contract;
3. keep `@unchecked Sendable` only with explicit documented rationale;
4. otherwise replace it with an actor or lock-safe implementation without adding decorative layers;
5. add or update package-owned concurrency tests;
6. sync only applicable neutral improvements into MVVMExample.

Current candidates:

- `./Packages/TchopInfrastructure/Sources/TchopNetworking/APIConnectivity.swift`
- `./Packages/TchopInfrastructure/Sources/TchopOnDeviceAI/FoundationModelsOnDeviceAIManager.swift`
- `./Packages/TchopInfrastructure/Sources/TchopPushNotifications/TchopPushNotifications.swift`
- `./Packages/TchopInfrastructure/Sources/TchopShareSupport/TchopShareSupport.swift`
- `./Packages/TchopInfrastructure/Sources/TchopUIConfiguration/TchopUIConfiguration.swift`
- `./Packages/TchopInfrastructure/Sources/TchopWidgets/TchopWidgets.swift`

## Remaining Risks After The Next Block
These are not approved implementation decisions yet; report and prioritize them rather than silently changing them:

- cache metadata, size limits, and eviction policy;
- share-support multi-process file coordination, size limits, UTType validation, and security-scoped resource behavior;
- push payload extensibility and platform adapter scope;
- Apple authentication nonce/server-verification payload scope;
- OnDeviceAI core/adapter separation and app-specific prompt policy;
- sync run reports, cancellation status semantics, and background integration;
- navigation snapshot diagnostics/error reporting;
- manual simulator, accessibility, memory, and Instruments validation.

## Must Not Do
- Do not treat test counts alone as proof of production readiness.
- Do not add speculative packages or features to MVVMExample.
- Do not rename all `Tchop*` modules in the current app worktree solely for cosmetic neutrality; use neutral naming when promoting to unrelated projects.
- Do not weaken strict concurrency, suppress warnings, or keep `@unchecked Sendable` without evidence.
- Do not expose captured HTTP response bodies or headers through logs, diagnostics, analytics, or user-visible errors without explicit redaction policy.
- Do not run app test targets, simulator UI, or Instruments without explicit user permission.

## Completion Rule For The Next Chat
After each coherent block:

1. update `./.zenflow/tasks/new-task-be0b/plan.md`;
2. run relevant package tests;
3. run `git diff --check`;
4. run `plutil` if project files change;
5. run build when implementation-level package/app changes require it;
6. report completed work, verification, remaining risks, and whether MVVMExample required sync.
