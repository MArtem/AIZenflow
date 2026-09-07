# 21 — Build Configuration, Entitlements, and Signing

## Build settings are code

Project/workspace/xcconfig/entitlement changes can alter security and release behavior even when Swift source is untouched.

## Human approval triggers

Explicit approval is required for intentional changes to:

- signing identity/team/provisioning behavior;
- entitlements;
- keychain access groups;
- App Groups;
- associated domains;
- push/background modes;
- ATS exceptions;
- deployment target;
- Swift language mode/default actor isolation;
- enabled capabilities;
- bundle identifiers;
- privacy-related Info.plist keys;
- release optimization/debug-symbol policy.

## MUST

- keep Debug/Release distinctions intentional;
- avoid secrets in build settings checked into source;
- preserve reproducible package resolution;
- inspect project-file diffs carefully because Xcode can create broad unrelated changes;
- do not disable diagnostics/sanitizers/warnings globally to fix one issue.

## Warnings

Modern projects SHOULD treat new warnings as failures; enabling `SWIFT_TREAT_WARNINGS_AS_ERRORS` is a project-level decision rather than an agent side effect.

## CI parity

Local gate commands SHOULD match CI scheme/configuration/test plans where possible. If local verification differs, report it.
