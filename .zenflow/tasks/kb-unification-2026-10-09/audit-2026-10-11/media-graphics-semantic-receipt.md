# Media and graphics source family — 2026-10-15

LIB-0302–0313: twelve complete source bodies and 36 unit maps read. Twelve active dispositions and 24 archive dispositions adjudicated separately. Media/Sensors owner read completely; UI Layout And Rendering rechecked against its previously read complete body. This is textual preservation review, not capture/render/export or hardware evidence.

- 0302-U01: Media Runtime Ownership/Camera retain authorization, session serialization, interruption, orientation, device changes, bounded buffers, pressure and teardown. Configuration off main is qualified by framework serialization.
- 0303-U01: Audio/Video retains category/mode/options driven by actual recording/mixing/background/Bluetooth/AirPlay contract, interruption/reset and other-audio policy. No universally correct session configuration is asserted.
- 0304-U01: Performance And Privacy preserves real-time callback locks/blocking/allocation review, format conversion, owned context/pipeline reuse, pacing/latency and teardown through Runtime Ownership. Textual framework-contract requirements do not prove real-time safety.
- 0305-U01: Audio/Video explicitly preserves buffering, seek cancellation, KVO/async observation lifetime, conditional PiP restoration, captions and interruption/background behavior.
- 0306-U01: Performance And Privacy retains bounded export buffering/disk, low-storage and cancellation cleanup, thermal/background limits, codec/container and HDR/color compatibility. Compressed bytes are not decoded-memory evidence.
- 0307-U01: Core Image/Graphics paragraph preserves extent, color, orientation, context lifetime/thread contract and CPU/GPU tradeoffs; context reuse explicitly does not make mutable filters safe for concurrent mutation.
- 0308-U01: same paragraph preserves scale/transforms/clipping, output color, actual UI-thread contract and accessible alternatives. Drawing success cannot establish accessibility semantics.
- 0309-U01: UI Layout And Rendering explicitly distinguishes presentation and model target state, transactions/timing, cancellation/completion, rasterization/offscreen cost and Reduce Motion. Visual completion does not commit product state.
- 0310-U01: Media Metal paragraph retains command/resource lifetime, read/write hazards, CPU/GPU synchronization, actual storage/heap contract, pipeline caching and fallback limits. A GPU capture remains conditional permitted evidence, not required execution in this audit.
- 0311-U01: PDF paragraph retains bounded document/page/search/annotation memory, cancellation, untrusted input and accessible/searchable content. The source does not establish that arbitrary PDF loading is streaming; the owner correctly requires resource bounds under the actual document contract.
- 0312-U01: PhotoKit paragraph preserves fetched identity, observers, changing/limited authorization, cloud-backed progress/unavailability/cancellation and memory. Permission is not local asset availability.
- 0313-U01: combined owner retains permission/lifecycle/real-time/color/orientation/resource/privacy review and explicit limits on hardware evidence.

Common state/failure/interruption/recovery and resource requirements remain conditional. All U02 archive unconditional test/fixture/measurement/build wrappers; useful evidence selection stays permission-bound. All U03 archive retired mode/Library binding, without reviewing linked deep playbooks. No new confirmed defect. API freshness, actual code outcomes and migration chronology remain UNVERIFIED; excluded physical checks remain OMITTED_BY_USER.
