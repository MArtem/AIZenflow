# AppIntentSupport Package Contract

## Purpose

Provide reusable, product-neutral helpers for host apps that expose features through Apple's App Intents framework.

## Boundaries

### Package owns

- generic App Intent parameter normalization;
- generic validation failures;
- package marker types for future App Intents package composition;
- portable documentation and verification script.

### Host app owns

- concrete `AppIntent` declarations;
- `AppShortcutsProvider` declarations;
- shortcut phrases, titles, descriptions, and user-facing copy;
- product entities and parameter semantics;
- persistence, routing, authorization, analytics, and error presentation;
- manual QA with Shortcuts, Siri, Spotlight, and system surfaces.

## App Shortcut placement rule

For this worktree, App Shortcut-facing intent structs and the `AppShortcutsProvider` must compile into the app target. The reusable package must not hide product shortcuts behind a framework-only boundary.

## Concurrency

All public values are `Sendable`. The package owns no mutable global state.

## Privacy

The package does not log parameter values and does not store user content.
