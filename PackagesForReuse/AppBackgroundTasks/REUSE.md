# AppBackgroundTasks Reuse Note

`AppBackgroundTasks` is preserved as a vault-only package in this worktree.

## Current TchopApp state

`TchopApp` does not currently register or submit native background tasks, and adding background refresh/processing jobs would require product decisions, entitlements, Info.plist identifiers, scheduling policy, failure policy, and manual QA.

## Adopt when needed

Copy this package into `./PackagesInUse` or connect it through SwiftPM only when a host app has a concrete background job requirement. Keep native `BGTaskScheduler` registration/submission in host app or an explicit integration helper because it depends on entitlements and app lifecycle policy.
