# 19 — Background Work and App Lifecycle

## Principle

iOS controls background execution. Do not design as if arbitrary work can run indefinitely after the app leaves foreground.

## MUST

- use the platform mechanism appropriate to the task (`BGTaskScheduler`, background URLSession, continued-processing APIs where available, specific background modes/capabilities);
- register/schedule background tasks according to platform requirements;
- provide expiration/cancellation handling;
- make work resumable/idempotent where the OS can stop/relaunch it;
- persist only the minimum state needed to resume safely;
- avoid assuming exact execution time.

## Scene lifecycle

Modern UIKit apps should use scene-based lifecycle where required by the project SDK/deployment plan. Lifecycle work must handle multiple scenes if the app supports them.

## Foreground/background transitions

Review:

- active network/task ownership;
- sensitive UI snapshots;
- audio/location/background capability semantics;
- state save/restore;
- timers/display links;
- resource release/reacquisition.

## Long-running work

If foreground work must finish after transitioning to background, use the supported API rather than an unbounded ordinary task.

## Testing

Background behavior often requires device/OS scheduling and cannot be fully proven in unit tests. Report simulator-only limitations explicitly.
