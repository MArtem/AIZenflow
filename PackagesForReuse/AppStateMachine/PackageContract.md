# AppStateMachine Package Contract

## Package identity

- Package name: `AppStateMachine`
- Root folder: `AppStateMachine/`
- Primary target: `AppStateMachine`
- Test target: `AppStateMachineTests`

## Standalone rules

This package must remain a single-folder standalone Swift Package.

Required constraints:

1. No sibling path dependencies.
2. No remote package dependencies.
3. No imports of sibling SDK packages.
4. No app-specific or product-specific logic.
5. No product-domain state, event, route, profile, feed, news, or account concepts.
6. All source, test, documentation, scripts, and fixtures stay inside this package folder.
7. Multi-target expansion is allowed only if all targets stay inside this package folder.
8. Cross-package composition belongs to optional integration helpers, not this root package.

## DocC ownership

DocC documentation is source-owned:

```text
Sources/AppStateMachine/Documentation.docc/AppStateMachine.md
```

Root-level DocC catalogs are not allowed.

## Execution and side-effect boundaries

`AppStateMachine` is a state transition mechanism. It does not hide blocking file I/O, database I/O, network calls, analytics, notifications, or telemetry inside its root logic.

Host apps provide side effects through explicit boundaries:

- `StateMachineStore` for durable snapshot persistence;
- `StateTransitionGuard` for host-owned checks;
- `StateTransitionAction` for host-owned transition effects;
- `StateMachineClock` for time source replacement.

The built-in `InMemoryStateMachineStore` is an actor and is intended for standalone runtime use, tests, previews, and host apps that do not need durable persistence.

`StateMachineStore` operations must be throwing. Durable storage failures must propagate to host code; the root package must not convert persistence failure into a normal rejected transition.

`AppStateMachine` must serialize transition execution across awaiting guards and actions. Swift actor reentrancy alone is not enough for state-machine correctness because multiple concurrent events must not evaluate from the same persisted snapshot.

Transition actions execute before the next snapshot is saved. Host actions must be idempotent or compensatable when durable snapshot persistence can fail after the action succeeds.

## Privacy and diagnostics

By default:

- state machine identifiers are not exposed by `description` or `debugDescription`;
- state identifiers are not exposed by `description` or `debugDescription`;
- event identifiers are not exposed by `description` or `debugDescription`;
- guard and action identifiers are not exposed by `description` or `debugDescription`;
- metadata values are not exposed by `description` or `debugDescription`;
- action failures are reported without copying backend, system, or host error text.

## Verifier contract

`Scripts/verify_package.sh` must be executable and fail fast.

The verifier must use a worktree-local scratch path outside the package folder:

```text
WorktreeScratch/AppStateMachine
```

It must clean that scratch path after verification and must not leave `.build`, `.swiftpm`, `Package.resolved`, `.DS_Store`, `__MACOSX`, or `xcuserdata` inside the package folder.

Required checks include:

- package structure;
- package name and target name consistency;
- source-owned DocC path;
- no sibling path dependencies;
- no remote package dependencies;
- no sibling SDK imports;
- no package-local build or archive artifacts;
- no unresolved placeholders;
- forbidden privacy, security, and concurrency patterns in Sources;
- `swift test`;
- `swift test -Xswiftc -strict-concurrency=complete`.
- no `warning:` or `error:` output from SwiftPM verification.
