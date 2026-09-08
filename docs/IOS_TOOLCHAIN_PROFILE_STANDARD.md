# iOS Toolchain and Availability Profile Standard

<!-- Rule ID: QC.TOOLCHAIN.PROFILE v1.0 -->

## Purpose

Keep compiler, language mode, SDK, deployment, isolation, availability and platform assumptions
explicit for each project. This is a profile contract, not an instruction to upgrade an app or
raise its minimum OS.

## Required project profile

Record these fields per repository and target family before applying toolchain-sensitive guidance:

| Field | Required value |
| --- | --- |
| Xcode/toolchain | exact Xcode and compiler identity, including the source of the value |
| Swift language mode | target mode, for example Swift 5 or Swift 6; do not infer it from compiler version |
| SDK | exact iOS/iPadOS SDK used for the check or build |
| Deployment target | minimum OS per app, extension and package target; preserve it unless an app owner changes it |
| Targets/extensions | app, framework, widget, share extension, tests and other target membership |
| Strict concurrency | diagnostic level and any target-specific setting |
| Default actor isolation | explicit setting or `unspecified`; record whether MainActor default is enabled |
| Upcoming features | each enabled feature, source proposal/release and stability (`stable`, `beta`, or experimental) |
| Observation | legacy `ObservableObject`, Observation, or mixed bridge, with availability constraints |
| UIKit/SwiftUI boundary | controllers, delegates, representables, scene/window ownership and callback isolation |
| Availability matrix | API availability, fallback path, entitlement, hardware, region and permission prerequisites |
| iPhone/iPad/window scope | supported idioms, size classes, multitasking/windows, keyboard/pointer and orientation assumptions |
| Verification route | Swift Testing/XCTest/manual/device choice allowed by the current permission contract |

An absent field is `unknown`, not a guessed default. A project profile is app-owned; reusable rules
may define the field contract but must not fill in product values.

## Current toolchain interpretation

- Compiler version, Swift language mode, SDK version and deployment target are separate dimensions.
  A newer compiler may compile an older language mode and deployment target.
- Swift 6.2 provides an opt-in default MainActor isolation mode and `@concurrent` for code that
  explicitly needs concurrent execution. Record the setting; do not treat either behavior as a
  universal app default. `async` alone does not prove a background thread or UI safety.
- Swift 6.3 changes Swift Testing capabilities, including warning issues, test cancellation and
  image attachments. This does not replace XCTest everywhere: choose the framework supported by the
  target, existing suite and approved verification scope.
- Observation is a capability and migration option, not a mandatory replacement for every
  `ObservableObject`. Select it when the target's deployment/toolchain and state ownership make it
  appropriate, and document any mixed UIKit/SwiftUI bridge.
- iPad and windowed layouts must use the app's supported scope. UIKit trait/window guidance and
  SwiftUI adaptivity are evidence inputs; an iPhone screenshot does not prove iPad, keyboard,
  pointer, Dynamic Type or multiple-window behavior.
- `@MainActor` is correct for UI-facing state when ownership requires it. A synchronous worker API
  is not declared a UI freeze without a call-site and workload path; a CPU-bound operation and an
  asynchronous wait need different evidence.
- Strict memory-safety or upcoming-feature settings are adopted per profile and supported
  toolchain. Do not apply an optional feature mechanically to every target or use beta API in the
  stable reusable baseline.

## Availability and migration contract

For every API or language feature whose availability matters, record:

1. minimum target and SDK/compiler requirement;
2. runtime availability guard and fallback behavior;
3. entitlement, hardware, region, account and permission prerequisites;
4. affected targets/extensions and whether generated/third-party code participates;
5. migration/rollback path if the feature is disabled or the deployment target is unchanged;
6. the exact evidence mode used (static, build, runtime, device, release or manual).

Do not raise deployment targets, rewrite state management, or add cloud/SDK infrastructure as a
side effect of recording this profile. Such changes require an app-owned decision and a separate
implementation block.

## Primary references and review date

Review current primary sources before a toolchain-sensitive change:

- Swift 6.2 release notes and concurrency model: <https://www.swift.org/blog/swift-6.2-released/>
- Swift 6.3 release notes and Swift Testing changes: <https://www.swift.org/blog/swift-6.3-released/>
- Observation framework: <https://developer.apple.com/documentation/observation>
- iPadOS multitasking and adaptive windows: <https://developer.apple.com/documentation/uikit/multitasking-on-ipad-mac-and-apple-vision-pro>
- UIKit layout/adaptivity: <https://developer.apple.com/documentation/uikit/view-layout>

Last reviewed: 2026-09-08. Revisit after an Xcode/Swift/SDK release, a deployment-target change,
new default-isolation or Observation behavior, an availability incident, or a rejected build.

## Evidence boundary

This standard defines the profile and interpretation contract. It does not claim that a consuming
project has a current toolchain receipt, successful build, runtime proof, device matrix or release
readiness until that evidence is collected under the project's permissions.
