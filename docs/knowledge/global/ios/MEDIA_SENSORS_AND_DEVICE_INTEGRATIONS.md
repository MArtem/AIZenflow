# Media, Sensors, And Device Integrations

## Load When
Use for camera, photos, microphone, audio/video playback or capture, speech, location/maps, motion, Bluetooth, NFC, nearby interaction, HealthKit, contacts, calendars, or other hardware/user-data frameworks.

## Permission Model
- Request permission at the moment a clear user action needs it.
- Explain the benefit before the system prompt when context is not obvious.
- Handle not determined, limited, authorized, denied, restricted, unavailable, and changed settings.
- Never require unrelated permission for basic app access.
- Purpose strings must match actual use and data lifecycle.
- Permission is not proof that hardware, data, connectivity, or the requested mode is available.

## Runtime Ownership
Sessions, delegates, observers, routes, captures, streams, and hardware connections need one lifecycle owner. Define setup, start, interruption, background transition, route/device change, cancellation, teardown, retry, and resource release. Avoid starting hardware in a SwiftUI view initializer or leaving it owned by a transient cell.

## Camera And Photos
- Configure capture sessions off the main thread while respecting framework serialization requirements.
- Handle authorization, unavailable input, interruptions, runtime errors, orientation, mirroring, pressure, thermal state, and app lifecycle.
- Process pixel buffers with bounded queues and avoid retaining full-resolution frames unnecessarily.
- Use Photos picker for user-selected media when broad library access is unnecessary.
- Respect limited-library state and security-scoped/file-backed representations.
- Preserve metadata only when product/privacy requirements justify it.

PhotoKit review traces fetched asset identity and change-observer ownership through limited-library
or authorization changes. Define cloud-backed asset loading/progress, unavailable/offline results,
request cancellation and memory bounds; permission does not establish local asset availability.

## Photo Access And Asset Lifetime Example
Picker selection and full/limited PhotoKit library authorization are different grants.
Use access-level-aware authorization APIs when limited-library behavior matters, and react
to selection/permission changes. An asset identifier and permission do not prove that its
full content is already local. A cloud-backed image request may require separately allowed
network access and expose progress/unavailable states.

For example, an asset visible in a limited selection is removed from that selection while a
consumer is loading it. Treat the changed authorization and late completion under the actual
request/owner identity; a cached thumbnail is not continuing authority to fetch all content.
Keep imported provider-file lifetime, durable copy/cleanup and memory bounds separate from
library permission. Source/fixture review does not prove Photos service or hardware behavior.
Primary theory: [Limited Photos library](https://developer.apple.com/documentation/photokit/delivering-an-enhanced-privacy-experience-in-your-photos-app)
and [cloud image access](https://developer.apple.com/documentation/photos/phimagerequestoptions/isnetworkaccessallowed).

## Audio, Video, And Speech

For a real audio-graph consumer, inspect graph construction and node/resource ownership,
input/output format conversion, start/stop ordering, interruption recovery and callback latency.
Keep real-time callbacks within their allocation/blocking contract; do not add an engine or graph
solely to satisfy this reference.

- Select audio session category/mode/options from recording, playback, mixing, Bluetooth, AirPlay, and background requirements.
- Handle interruptions, route changes, media services reset, other-audio policy, remote controls, and Now Playing state.
- Stream large media, observe player/item state, cancel observations, and release assets on eviction/dismissal.
- Define buffering and seek cancellation, KVO/async observer lifetime, and interruption/background
  behavior. Where supported and required, include PiP restoration and available captions/subtitles
  with the actual media selection and accessibility contract.
- Recording requires durable temporary-file cleanup and honest interruption/failure state.
- Speech recognition may be on-device or service-dependent; expose availability and privacy behavior accurately.

## Audio Interruption Compatibility Example
Apple's iOS 27 guidance uses audio-session activation/inactivation and resumption-recommendation
notifications; earlier deployments use the legacy interruption notification. Check actual SDK
availability and keep an older-OS path when required. A recommendation to resume is not the
user's playback intent or proof that activation succeeded.

For example, a system interruption pauses playback, then the person presses Stop before the
system recommends resumption. The owner must keep the stopped state rather than restart audio.
Map system/session state and user intent separately, handle unavailable end/resumption events,
and release observers at the owning lifetime boundary. Compare the permitted state trace on
each supported API path; neither source review nor an injected notification proves hardware
behavior. Current physical-device exclusions remain OMITTED_BY_USER.

Primary theory: [Handling audio interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions).

## Location And Maps
- Choose approximate/precise and when-in-use/always authorization from the minimum product need.
- Define desired accuracy, distance filter, background indicator/mode, pauses, battery budget, and stale location handling.
- Do not treat one coordinate as permanently accurate.
- Geocoding, directions, search, and tiles are network/service operations with throttling and terms.
- Validate map camera, annotations, clustering, accessibility, and location-denied workflows.

For geofencing, inspect the actual supported monitoring limits, authorization/precision, lifecycle
and energy/privacy contract before relying on region events. Do not substitute a source estimate
for observed location or background behavior; excluded physical checks remain unverified.

### Location Decision And Failure Trace
Choose a user-entered place or selected map destination when the feature needs a destination,
not continuous device tracking. When actual location is necessary, request the minimum access
at the feature boundary. When-in-use and Always differ in delivery/relaunch conditions; neither
is a promise of continuous execution. Keep authorization, precision, timestamp/accuracy and
service availability separate.

For example, directions start using a recent coordinate, then authorization changes while a
request is outstanding. Bind the result to the route owner and location snapshot; recheck the
current permission and freshness before presenting it as the person's current position. Offer
manual destination entry when product policy permits, rather than repeatedly prompting or
quietly increasing privilege. Map service failure must preserve the selected destination.
Primary theory: [Location authorization and delivery boundaries](https://developer.apple.com/documentation/corelocation/requesting-authorization-to-use-location-services).
This is an unexecuted failure trace, not location or background-delivery evidence.

## Bluetooth, NFC, And Nearby

For NFC, distinguish polling/discovery, tag reading and tag writing under the actual tag/protocol
and session contract. Review the existing NFC entitlement, capability, user-prompt, input-validation
and read/write error behavior separately from Nearby/UWB configuration; discovery is not successful
read/write or trusted identity. Unsupported or excluded hardware evidence stays unverified, without
requesting a physical-device check.

- Model discovery, permission, state restoration, connection, service/characteristic negotiation, timeout, retry, disconnect, and firmware/protocol version.
- Bound scan duration and duplicate processing; do not equate discovery with authorization or identity.
- Parse peripheral/tag payloads defensively and enforce length/type/state constraints.
- Background Bluetooth/NFC behavior is capability- and device-dependent.
- Nearby Interaction and UWB require compatible hardware/accessories and entitlement/protocol setup.

Nearby Interaction review includes discovery-token exchange/trust, session interruption and
precision availability with privacy-safe fallback; a discovery token or available hardware alone
does not establish peer authorization or a usable precision result.

### Radio Session Decision And Failure Trace
Bluetooth restoration resumes only eligible pending work under actual OS/user/device state;
it is not a general-purpose persistent worker. Retain protocol/session identity separately
from transport discovery. An NFC reader session that becomes invalid cannot be reused;
reading, writing and one-tag versus multi-tag handling have different session lifetimes.
A Nearby Interaction session represents one nearby-object interaction; separate peer/session
ownership is needed when there are several objects.

For example, a write intent remains pending after an NFC session ends. Do not announce a
successful write because the tag was discovered. Preserve the intent, classify cancellation
versus read/write failure, and create a new user-authorized session if retry is appropriate.
For an accessory disconnect, reconnect/reconcile its acknowledged protocol state rather than
blindly replaying a non-idempotent command. A manual or QR workflow may satisfy the product
when a radio capability is absent; transport discovery must never become trusted identity.
Primary theory: [Bluetooth restoration conditions](https://developer.apple.com/documentation/technotes/tn3115-bluetooth-state-restoration-app-relaunch-rules),
[NFC session lifecycle](https://developer.apple.com/documentation/corenfc/building-an-nfc-tag-reader-app),
and [Nearby session ownership](https://developer.apple.com/documentation/nearbyinteraction/nisession).
No sample was downloaded or run; hardware outcomes remain unverified.

## Health, Contacts, Calendars, And Sensitive Stores
- Request only data types required for a concrete feature.
- Separate read and write authorization and handle partial grants.
- Minimize retention and prevent sensitive values from entering logs/analytics.
- HealthKit query/update semantics, background delivery, source attribution, deletion, and clinical claims require dedicated product/compliance review.
- Contacts/calendar identifiers and records can change; do not assume permanent local identity.

### Sensitive Store Decision And Failure Trace
HealthKit read authorization is intentionally not fully observable: an empty/partial query
cannot prove that data does not exist or that a person denied access. Current authorization
may expose only a recent time window. Keep write authorization separate. Contacts may grant
a changing selected subset; a picker callback listing additions is not a complete removal
ledger. Requery authorized data under the actual store owner.

EventKit write-only event access does not allow reading back even app-created events; it is
not read/write access. If the feature only lets someone create/edit an event through system
UI, consider EventKit UI instead of requesting full database access. Full access to events or
reminders and the corresponding usage descriptions are separate from that UI-mediated choice.

For example, a health history query becomes shorter after permission changes. Preserve the
uncertainty instead of recording missing samples as zero or deleting previously owned work.
If a contact disappears from the permitted subset, revoke the consumer's assumption of access
without treating it as proof that the contact was deleted. An empty write-only calendar query
cannot verify that a previous save failed; use its actual completion/error and owned identity.
Primary theory: [Health data authorization](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data),
[Contacts access](https://developer.apple.com/documentation/contacts/accessing-the-contact-store),
and [Event store access](https://developer.apple.com/documentation/eventkit/accessing-the-event-store).
These alternatives and failure traces are static design evidence, not access to personal stores.

## Motion And Haptics
For actual motion consumers, define sampling/update frequency, reference frame, filtering and
calibration, queue/resource bounds, sensor absence, background behavior, privacy and energy cost.
For haptics, own engine/pattern/resource lifetime, capability, interruption/reset recovery and
latency; preserve meaningful sensory alternatives and applicable motion/accessibility preferences.
Neither requested sampling nor engine availability proves observed sensor or haptic behavior.

### Motion And Haptic Recovery Trace
Choose processed device-motion values when gravity-separated acceleration or attitude is the
actual input; raw accelerometer values include gravity and require a deliberate processing
model. Choose a consistent reference frame and timestamp policy. Pull the latest sample when
needed or own a bounded update stream; stop collection when the feature no longer needs it.
A requested update rate does not establish actual hardware delivery frequency.

For example, a feature leaves the foreground while queued motion callbacks still arrive.
Cancel collection and reject callbacks from the old owner rather than updating a new screen.
If the haptic engine resets, previous players/custom resources require recreation or
registration under the recovered engine; restarting can still fail. Preserve a visual/audio
alternative and current user intent rather than replaying an obsolete success cue after reset.
A simpler system feedback mechanism may be sufficient when no custom pattern is required.
Primary theory: [Processed motion and ownership](https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data)
and [Haptic capability, stop and reset lifecycle](https://developer.apple.com/documentation/corehaptics/preparing-your-app-to-play-haptics).
No sensor sampling, haptic playback or physical-device verification was performed.

## Simulator Versus Device
Simulator fixtures are useful for parsing, mapping, state machines, imported media, route logic, and permission-independent UI. They do not prove capture quality, microphone routes, sensor accuracy, Bluetooth/NFC/UWB, HealthKit device behavior, background execution, thermal pressure, or locked-device access.

## Performance And Privacy

For export, distinguish approximate progress from verified completion and the final validated
output. Keep progress/error/cancellation tied to the current export identity; temporary output or a
progress value is not successful publication. For path drawing, inspect path construction/mutation,
fill/stroke/clipping, scale/transforms and the actual render-thread/resource owner alongside
meaningful accessible alternatives. These are review axes for existing consumers, not new capture,
export or custom-renderer scope.

Bound frame/sample rate, buffers, decoded media, cache size, observation lifetime, and background work. Classify captured metadata and derived inferences as user data. Provide deletion/export behavior consistent with product promises.

For capture/decode/rendering pipelines, record maximum in-flight buffers and queue growth,
backpressure behavior (pause, drop or coalesce), ownership on interruption/cancellation and
release of buffers/sessions. Compare a rendering budget with a representative observed scenario.
For export/transcoding, bound input/output buffering and temporary disk use; preserve cleanup
on cancellation or low storage and account for thermal/background constraints and representative
codec/container and HDR/color-space output. Compressed file size does not establish decoded-memory bounds.

At real-time audio/rendering callback boundaries, inspect locks, blocking work and allocation
pressure under the actual framework contract; review format conversion, safe context/pipeline
reuse, GPU/CPU trade-offs, frame pacing and thermal limits. Golden output comparisons need a
defined compatibility contract and permitted verification. Source inspection cannot establish
hardware behavior. Recommendations grant no capture/export/test/profiling execution.

For Core Image/Graphics, define render extent, scale, coordinate transforms, orientation, clipping
and working/output color spaces. Reuse owned contexts safely; context reuse does not make mutable
filters safe for concurrent mutation. Keep drawing work within the actual framework/UI thread
contract and preserve accessible alternatives for meaningful custom graphics.
For Metal, trace command/resource lifetime, read/write hazards and CPU/GPU synchronization under
the actual queue/storage/heap contract; pipeline caching or hardware support alone proves no
ordering, frame pacing or safe fallback.
For PDFs, bound loading/page rendering/search and annotation memory, cancellation and untrusted
input handling; preserve accessible/searchable content under the actual document contract.

For approved ARKit/RealityKit consumers, define configuration/support, tracking quality, world
mapping, interruption/relocalization/recovery and camera/sensor permissions. Own entity/component
and async-asset lifetime, collision/physics steps and GPU/memory/thermal bounds. Tracking or
mapping availability is not guaranteed recovery; unsupported states need the actual fallback.

## Evidence
- Permission matrix and settings changes.
- Interruption, route/device change, background/foreground, unavailable hardware, low storage, memory warning, thermal state, and cancellation.
- Representative large/long media and malformed input.
- Hardware-dependent claims remain unverified when evidence is unavailable or excluded by current
  user scope; excluded checks are OMITTED_BY_USER, never PASS.
- Privacy manifest, purpose strings, data lifecycle, and App Review disclosure consistency.

## Primary Sources
- [AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [PhotosUI](https://developer.apple.com/documentation/photosui)
- [Core Location](https://developer.apple.com/documentation/corelocation)
- [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth)
- [Core NFC](https://developer.apple.com/documentation/corenfc)
- [HealthKit](https://developer.apple.com/documentation/healthkit)
