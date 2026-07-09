# AppIntentSupport

`AppIntentSupport` is a product-independent Swift package for small reusable App Intents helpers.

It is a mechanism package. It does not own app-specific intents, shortcut phrases, product entities, persistence, routing, Siri copy, analytics, or authorization policy.

## What belongs here

- simple reusable input normalization for App Intent parameters;
- stable validation failures that host apps can map or surface;
- App Intents package marker types for future composition;
- package-safe helpers that do not depend on a product domain model.

## What does not belong here

- concrete `AppIntent` actions for a product;
- `AppShortcutsProvider` declarations;
- product phrases, copy, entities, or shortcuts;
- database, sync, app-group, or routing policy;
- app-specific card/feed behavior.

## TchopApp integration

`TchopApp` keeps concrete App Shortcut-facing intents in the app target. The current test intent uses this package only for generic text validation, then writes a product-specific feed card through the existing app-owned shared-card import path.

## Verification

Run from the package folder:

```bash
./Scripts/verify_package.sh
```

The script uses a sandbox-local build path under `/Users/Artem/.zenflow/worktrees/.package-build-cache` and must not leave `.build`, `.swiftpm`, logs, or `Package.resolved` inside the package folder.

## Tests

No package-owned tests were added in the initial TchopApp adoption block because the active task rules currently prohibit creating or modifying test files without explicit permission. Add tests in a dedicated test-approved block.
