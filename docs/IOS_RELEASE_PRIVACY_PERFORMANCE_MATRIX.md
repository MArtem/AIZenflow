# iOS Release, Privacy, Performance, And Platform Matrix

<!-- Rule ID: QC.RELEASE.PROFILE v1.0 -->

## Purpose and ownership

This is a project-owned matrix contract for release, privacy, performance, accessibility, platform
adaptation and experimental capability claims. It gives each claim one row, one owner and one
evidence state. The specialist documents remain normative for their individual checks; this matrix
does not replace them and does not invent product values.

An absent value is `unknown`, not a guessed default. A reusable rule may define a field or evidence
class, but the consuming app records its supported devices, targets, data flows, budgets, owners and
exceptions.

## Required row schema

| Field | Required meaning |
| --- | --- |
| Axis and claim | release, privacy, performance, accessibility/platform, or experimental capability; exact claim being made |
| Target and scope | repository, app/extension/framework, configuration, candidate SHA and target family |
| Profile identity | toolchain/profile revision, Xcode/compiler, SDK, deployment target and relevant capability profile |
| Owner and authority | accountable app owner plus the single normative source and source revision/date |
| Applicability | `applicable`, `not_applicable`, or `unknown` with a project fact for `not_applicable` |
| Budget or requirement | measurable target, current Apple requirement, data-lifecycle rule, or explicit qualitative criterion |
| Evidence route | static, archive/artifact, build, runtime, device, Instruments/MetricKit, manual, release or legal review |
| Evidence state | `fresh`, `stale`, `partial`, `not_run`, `denied`, `unavailable`, `malformed`, or `skipped` |
| Fallback and rollback | availability fallback, data-preserving failure path, feature disablement, release rollback or owner decision |
| Decision | `PASS`, `NOT_READY`, `READY_WITH_ACCEPTED_RISK`, `BLOCKED`, or `NOT_APPLICABLE` under the shared verdict contract |

## Release and distribution

- Record the current App Store Connect upload floor as an exact Xcode/SDK requirement with the
  Apple source URL and review date. This floor is a distribution requirement and is separate from
  each target's minimum deployment OS.
- Record deployment targets independently for the app, extensions, frameworks and packages. Do
  not raise them merely to satisfy an upload floor; an app-owned change must define availability
  guards, fallback and migration impact.
- Bind signing, entitlements, bundle membership, privacy files, embedded SDKs, dSYMs, export
  compliance and artifact identity to the candidate SHA. Archive success alone is not App Store
  compliance or release readiness.
- Reconcile distributed artifact, privacy manifests, required-reason API declarations, App Store
  privacy answers, permission strings and actual runtime behavior. A structural manifest check is
  evidence of structure only; it is not an App Review or privacy-compliance PASS.

## Privacy and data lifecycle

For each sensitive data or permission row, record the actual API/SDK/source, purpose, destination,
linkage/tracking status, permission string, manifest declaration/reason, retention, logout cleanup,
account deletion/local deletion, export or support path, and owner. Include third-party SDKs and
generated code when they participate in the distributed target.

Permission denial, restricted state, revoked access, expired session and unavailable service need an
explicit user-facing fallback. Do not add cloud processing, telemetry, remote model access or new
infrastructure as a side effect of filling out the matrix.

## Performance and responsiveness

Record one row per scenario and target device class for cold launch, warm launch, foreground resume,
critical interaction latency, frame time/hitches, main-thread work, peak/retained memory and any
energy or network budget that the product actually owns. State the configuration, device or
simulator, build configuration, tool and observed metric.

Budgets are workload- and profile-specific; they are not universal values copied between apps. A
250 ms hang signal used by diagnostic tools is not a responsiveness target. Use a project budget for
the interaction and frame scenario, then collect the permitted evidence that can prove it. A
screenshot or static inspection does not prove runtime performance, memory, frame pacing or launch
behavior.

## Platform and accessibility matrix

For each supported platform row, record iPhone/iPad idiom, size classes, orientation, resizing or
multiple windows, keyboard/pointer, VoiceOver, Dynamic Type, contrast, Reduce Motion, RTL and any
hardware/region prerequisite. A single iPhone screenshot does not prove iPad, window, keyboard,
VoiceOver, Dynamic Type, RTL or Reduce Motion behavior. Missing device or runtime evidence remains
visible as `partial`, `not_run` or `unavailable`.

## Experimental AI and new platform capabilities

Keep Core AI, Foundation Models and other newly introduced capabilities on a separate experimental
availability track until the consuming profile and release policy explicitly adopt them. Each row
records framework/API, minimum OS and SDK, device and region eligibility, model readiness, on-device
versus Private Cloud Compute or external-provider data flow, privacy/security review, permission or
entitlement, fallback when unavailable, feature flag/kill switch, rollback and evidence state.

Do not infer model availability from compilation. Check availability at runtime where permitted and
provide a product-correct fallback. Do not introduce a cloud provider, backend, account, secret or
paid service merely to exercise this matrix.

## Verdict and review contract

The shared readiness contract applies independently at local, merge and release levels. Missing,
stale, denied, unavailable or user-skipped evidence cannot become a normal `PASS`; an approved,
scoped and expiring exception may produce `READY_WITH_ACCEPTED_RISK` without clearing a P0–P2 risk.
Each row keeps its evidence state even when the aggregate decision is blocked by another row.

## Primary references and review date

- App Store Connect upload requirements: <https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/> and <https://developer.apple.com/news/upcoming-requirements/>
- Privacy manifests and app privacy: <https://developer.apple.com/documentation/bundleresources/privacy-manifest-files> and <https://developer.apple.com/app-store/app-privacy-details/>
- Responsiveness and performance evidence: <https://developer.apple.com/documentation/xcode/improving-app-responsiveness>, <https://developer.apple.com/documentation/xcode/performance-and-metrics>, and <https://developer.apple.com/documentation/metrickit>
- Foundation Models availability and fallback: <https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models>

Last reviewed: 2026-09-08. Revisit after an App Store Connect/Xcode/SDK requirement, privacy
manifest/API, platform capability, accessibility, performance incident, or model-availability
change.

## Evidence boundary

This matrix defines claim fields and interpretation. It does not claim that a consuming project has
passed release, privacy, accessibility, performance, App Review or experimental-capability checks
until the project-owned rows contain permitted current evidence.
