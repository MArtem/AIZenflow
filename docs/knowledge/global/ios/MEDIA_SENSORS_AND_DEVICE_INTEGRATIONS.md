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

## Audio, Video, And Speech
- Select audio session category/mode/options from recording, playback, mixing, Bluetooth, AirPlay, and background requirements.
- Handle interruptions, route changes, media services reset, other-audio policy, remote controls, and Now Playing state.
- Stream large media, observe player/item state, cancel observations, and release assets on eviction/dismissal.
- Define buffering and seek cancellation, KVO/async observer lifetime, and interruption/background
  behavior. Where supported and required, include PiP restoration and available captions/subtitles
  with the actual media selection and accessibility contract.
- Recording requires durable temporary-file cleanup and honest interruption/failure state.
- Speech recognition may be on-device or service-dependent; expose availability and privacy behavior accurately.

## Location And Maps
- Choose approximate/precise and when-in-use/always authorization from the minimum product need.
- Define desired accuracy, distance filter, background indicator/mode, pauses, battery budget, and stale location handling.
- Do not treat one coordinate as permanently accurate.
- Geocoding, directions, search, and tiles are network/service operations with throttling and terms.
- Validate map camera, annotations, clustering, accessibility, and location-denied workflows.

For geofencing, inspect the actual supported monitoring limits, authorization/precision, lifecycle
and energy/privacy contract before relying on region events. Do not substitute a source estimate
for observed location or background behavior; excluded physical checks remain unverified.

## Bluetooth, NFC, And Nearby
- Model discovery, permission, state restoration, connection, service/characteristic negotiation, timeout, retry, disconnect, and firmware/protocol version.
- Bound scan duration and duplicate processing; do not equate discovery with authorization or identity.
- Parse peripheral/tag payloads defensively and enforce length/type/state constraints.
- Background Bluetooth/NFC behavior is capability- and device-dependent.
- Nearby Interaction and UWB require compatible hardware/accessories and entitlement/protocol setup.

Nearby Interaction review includes discovery-token exchange/trust, session interruption and
precision availability with privacy-safe fallback; a discovery token or available hardware alone
does not establish peer authorization or a usable precision result.

## Health, Contacts, Calendars, And Sensitive Stores
- Request only data types required for a concrete feature.
- Separate read and write authorization and handle partial grants.
- Minimize retention and prevent sensitive values from entering logs/analytics.
- HealthKit query/update semantics, background delivery, source attribution, deletion, and clinical claims require dedicated product/compliance review.
- Contacts/calendar identifiers and records can change; do not assume permanent local identity.

## Simulator Versus Device
Simulator fixtures are useful for parsing, mapping, state machines, imported media, route logic, and permission-independent UI. They do not prove capture quality, microphone routes, sensor accuracy, Bluetooth/NFC/UWB, HealthKit device behavior, background execution, thermal pressure, or locked-device access.

## Performance And Privacy
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
