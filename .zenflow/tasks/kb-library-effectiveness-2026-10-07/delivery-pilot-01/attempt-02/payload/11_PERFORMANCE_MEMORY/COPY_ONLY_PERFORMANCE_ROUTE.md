# Performance and memory — copy-only reference route

Use for an observed launch, scrolling, rendering, CPU, memory, I/O, energy or latency concern,
or when a changed path credibly affects one. Apply project-local performance rules first. This
route adds an independent hypothesis/evidence pass; it does not authorize Instruments, builds,
tests, device work or a broad optimization refactor.

1. Name the user-visible outcome, representative device/OS/data size and the path or target
   involved. Separate measured baseline from a suspected hotspot. If no baseline exists,
   label the performance claim unverified and recommend the smallest useful measurement.
   Record cold/warm path, build configuration and relevant thermal/battery/cache conditions so
   before/after evidence is comparable. Recommend the instrument that distinguishes the actual
   symptom, not a blanket profiling session; existing production metrics can corroborate an
   authorized local observation but are not interchangeable evidence.
   A debug or Simulator timing alone is not a production win. Check relevant tail latency,
   responsiveness and energy as well as averages; unavailable diagnostics must not become the
   only acceptance signal for an older supported environment.
2. Trace producer, consumer, thread/actor and lifetime. Inspect repeated allocations,
   quadratic work, main-thread synchronous I/O, excessive copying, image decode/retention,
   unbounded caches and cancellation/reuse failures where relevant. A pattern hit alone is not
   proof of a regression.
   For launch, separate pre-main/post-main, synchronous initialization, dependency setup, I/O
   and first-frame work. For scrolling, trace identity/reuse, prefetch cancellation, image decode,
   layout/invalidation churn and diff application against actual hitch evidence.
   For images/caches, inspect downsampling, decode location, request deduplication, cache keys,
   freshness/invalidation and memory/disk limits. For energy, trace polling, timers, background
   work and network wakeups; moving work off the UI actor must not create unbounded fan-out.
   For database/network cost, connect fetch/index/N+1 or payload/serialization/connection work
   to the observed latency and resource budget rather than assuming a smaller payload is faster.
   Distinguish transient allocation peaks and resident growth from a retained-object leak; include
   memory-pressure/termination risk and explicit CPU/memory trade-offs in the measurement proposal.
   For suspected retained objects, draw the ownership path through closures, delegates, tasks,
   subscriptions, timers and observers; identify release/teardown and cache bounds. Recommend
   deinit or Memory Graph evidence when it would resolve a lifetime hypothesis, and Instruments
   or signposts when they would distinguish a measured hotspot. These observations need permission.
   Delayed teardown or intentional cache/task/framework ownership is not automatically a retain
   cycle. Inspect retention across suspension, including a weak reference promoted before await;
   do not add weak ownership mechanically and risk premature deallocation.
   For capture, decode or rendering pipelines, map maximum in-flight buffers and queue growth,
   the chosen backpressure behavior (pause, drop or coalesce), ownership on interruption and
   cancellation, and when buffers or sessions are released. Compare any claimed rendering
   budget with an observed representative scenario, not a source-only estimate.
   For media export or transcoding, bound input/output buffering and temporary disk use; inspect
   cancellation and low-storage cleanup, thermal/background constraints and a representative
   codec/color-space output. A small compressed file is not evidence of bounded decoded memory.
   For real-time audio/rendering, examine locks, blocking calls and allocation pressure at the
   callback boundary; identify format conversion, safe context/pipeline reuse, GPU/CPU trade-offs,
   frame pacing and thermal limits. Golden media/output comparisons are useful only under a defined
   compatibility contract and permission; hardware behavior cannot be inferred from source alone.
3. Before recommending a change, explain its effect on correctness, memory, energy, accessibility
   and failure behavior. Prefer a bounded fix at the actual hotspot; avoid speculative caches,
   concurrency changes or new layers. Preserve behavior for low-memory, cancellation and
   repeated-use paths.
4. For an authorized change, compare before/after in the same representative scenario and name
   a regression guard. If measurement is not authorized or available, provide a static-risk
   finding and a measurement proposal, not a speedup claim. Review the complete affected diff.

In `AUTO`, perform the in-scope static trace and evidence appraisal. In `ADVISORY`, give the
measurement and correction options with cost/risk. Profiling or device work in either profile
requires separate authority. This distills useful checks from the former `ioslib-performance`
checklist and performance review source; their installed-runtime references are not active.
