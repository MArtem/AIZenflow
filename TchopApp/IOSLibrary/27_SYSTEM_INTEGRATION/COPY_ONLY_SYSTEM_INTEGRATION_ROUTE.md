# System integration and extensions — copy-only reference route

Use for an iOS system capability, hardware/session API, extension or background delivery path.
First apply project-local capabilities, privacy and lifecycle rules. Establish the exact target,
supported device/OS, entitlements, permission state, data owner and expected user outcome;
verify API/availability details from current official documentation when consequential.

Describe the state machine for launch, denial/restriction, interruption, background suspension,
timeout, reconnection and teardown as relevant. Treat callbacks and background delivery as
potentially delayed, duplicated or absent unless project evidence proves a narrower contract.
Trace app/extension boundaries, version skew, retained resources, privacy/redaction and a
fallback when hardware or service is unavailable. Avoid a new abstraction or third-party SDK
without demonstrated ownership or compatibility benefit.

Select only the applicable capability questions: widget timeline/placeholder relevance and
refresh budget; Live Activity stale/end/update ownership and exposed data; push token/account
lifecycle, category/action handling and validated destination; location precision, revocation,
background/energy budget; map camera/annotation/search identity and rendering cost; health-data
authorization granularity, query lifetime and minimization; limited photo access; Bluetooth
protocol/version/reconnect restoration. Do not apply unrelated framework traps merely because
they appeared in a historical playbook. Unsupported or unavailable data needs an honest UI state.

For cross-device cloud state, inspect account changes, conflicts, quota/offline behavior and
schema compatibility. For share/widget extensions, check time/memory budgets, extension-safe API
use and durable handoff under process death. For adaptive platforms, inspect resizing, window
and input ownership against the supported product contract, not a forced lowest-common-denominator UI.

For the selected integration, also inspect WebView process termination (security details use
the security route); App Clip invocation/data handoff and size budget; Spotlight stable indexing,
deletion/privacy and reindexing; Handoff serialization/eligibility and stale restoration;
NFC session/tag/timeouts; watch/peer delivery ordering, durable deduplication and transfer pressure;
nearby token trust/precision fallback; motion sampling/reference frame/calibration/energy;
haptic reset and sensory alternatives; home/accessory authorization/topology/commissioning;
CarPlay scene/template/interaction constraints and shared navigation. Specific platform limits
or policy claims require current official evidence; these prompts do not certify compliance.
For AR/spatial work, inspect tracking/permission/interruption/world-state recovery, entity/component
and async-asset lifetime, collision/physics and input/window/space semantics without assuming an
iPhone interaction model. Use the AI route only for an actual inference/quality concern and the
performance route for resource evidence; spatial UI alone does not imply generative AI or tools.

For background execution, additionally trace registration/scheduling, expiration and
cancellation, retry/duplicate delivery, persisted resumable work and the user-visible effect.
Do not assume a requested background task will run at a promised time. Check whether app and
extension consumers rely on shared durable state rather than app-process memory.
If a background URLSession or silent push is involved, identify the session/delegate and
completion owner across app relaunch, temporary-file ownership, duplicate or absent delivery,
retry/idempotency and telemetry for delayed or expired work. Do not promise a delivery time or
infer completion from scheduling alone; ask for device/OS evidence when behavior matters.

For capture or media export, trace permission, session/engine owner, interruption, route or
orientation changes, background limits and deterministic teardown. For export/transcode, also
identify the reader/writer and temporary-file owner, progress and cancellation semantics,
codec/container and color/HDR compatibility, disk-pressure failure and partial-output cleanup.
Do not claim device behavior, output parity or availability from a static path alone.
For audio/playback, inspect session activation/coexistence, route changes, engine formats and
real-time work, buffering/seek cancellation, observer lifetime, PiP/background and captions.
For photo-backed assets, include limited/revoked access, stable IDs, change observers and delayed
cloud retrieval. For graphics/document pipelines, inspect coordinates/scale/clipping, color/extent,
animation model/presentation and completion/cancellation, GPU synchronization/resource hazards,
large/untrusted document loading, annotations/search and an accessible alternative when needed.
Do not replace a correct existing pipeline merely to adopt a preferred framework.

For a bounded authorized change, review target membership, capabilities, lifecycle handlers,
all consumers and the complete diff. Propose deterministic seams and device/system checks
proportionate to risk; do not perform them without permission or claim runtime behavior from
static inspection. `AUTO` is in-scope reasoning, `ADVISORY` is prioritized advice. This is the
useful review content of former `ioslib-system-integrations`, not its installed mechanism.
