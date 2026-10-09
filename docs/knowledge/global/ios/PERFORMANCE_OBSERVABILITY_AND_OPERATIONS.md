# Performance, Observability, And Operations

## Load When
Use for performance budgets, Instruments, launch, hangs, scrolling, memory, energy, network cost, MetricKit, logging, analytics, crash reporting, rollout, incidents, or production health.

## Measure From User Impact
Define the user-visible operation, environment, data size, percentile, device class, OS/build, and budget. Averages hide tail latency. Debug builds and a single Simulator are diagnostic inputs, not production performance evidence.

Select a diagnostic from the symptom and available toolchain: Time Profiler for sampled CPU work,
Allocations for allocation behavior, ownership/Memory Graph or Leaks evidence for a lifetime
hypothesis, and network or SwiftUI/animation traces for the corresponding path. A tool name or
source pattern is not evidence of the actual bottleneck. These are permission-bounded proposals.

## Performance Domains
- Launch: pre-main work, static initialization, dependency setup, restoration, first frame, first usable content.
- Responsiveness: main-thread blocking, actor/queue contention, synchronous I/O, hangs, animation hitches.
- Rendering: invalidation breadth, body/layout cost, overdraw, offscreen rendering, image decode, list identity.
- CPU: algorithms, parsing, serialization, compression, crypto, background work.
- Memory: peak, steady state, retained graphs, caches, decoded media, mapped files, jetsam risk.
- Storage/network: I/O volume, transaction size, downloads, retries, radio wakeups.
- Energy/thermal: timers, location, sensors, background execution, GPU and network activity.

Distinguish transient allocation peaks, resident growth and retained-object ownership. Inspect
large buffers, cache bounds and autorelease behavior where relevant; none alone proves a leak.
Review quadratic work, repeated allocations and excessive copying as hypotheses against the
actual workload, rather than declaring regressions from a source-pattern hit.
Connect database fetch limits, predicates/indexes, fault loading, batch work and N+1 patterns, or
network payload/compression/cache/connection/serialization work, to the observed latency and
resource envelope. A smaller payload or different fetch shape does not itself prove improvement.

Reconstruct expected lifetime and the actual ownership path through closures, tasks, delegates,
timers/display links, observation tokens, delegate strength, caches and ObjC bridges before
calling delayed deallocation a retain cycle. Intentional
cache/framework ownership or pending teardown can retain objects without a cycle. Inspect
retention across suspension, including a weak reference promoted to a strong local before
`await`; change the incorrect semantic owner rather than adding weak captures mechanically.
Repeat the same lifecycle for permitted ownership evidence and the smallest fix.

For image paths, inspect downsampling/decode location, request deduplication, stable cache keys,
freshness/invalidation, cancellation and both memory/disk limits against the actual reused consumer.

## Optimization Workflow
1. Reproduce a representative path.
2. Capture a baseline trace and signpost interval.
3. Identify the dominant measured cost.
4. Change one ownership/algorithm/data-flow cause.
5. Re-run under comparable conditions.
6. Check correctness, memory, energy, accessibility, and older-device regressions.

Record cold/warm path, cache warmup, thermal/battery and network conditions. Compare the same
scenario/configuration, including tail latency, responsiveness, energy and CPU/memory trade-offs.
Record sample size and variance with before/after values under those conditions; an aggregate
without its observation population does not establish a comparable improvement.
If measurement is denied or unavailable, report a static-risk finding and the smallest useful
measurement proposal, without a speedup claim. Existing production metrics can corroborate local
evidence but are not interchangeable with it. Unavailable diagnostics must not be the sole
acceptance signal on an older supported environment or a reason to raise deployment targets.

Do not replace a measured problem with unbounded caching, stale data, unsafe concurrency, or reduced accessibility.

## Observability
Use structured logs with stable subsystem/category, privacy annotations, bounded metadata, and actionable levels. Add signposts around important intervals. Analytics describes product events; operational telemetry describes health. Crash reports, hangs, MetricKit payloads, and support diagnostics have separate privacy and retention concerns.

Never record secrets, credentials, full request/response bodies, user-authored sensitive content, precise location, or identifiers without explicit approved need and minimization.

For analytics/crash SDKs, trace required consent before collection, event/schema owner, user-identity reset,
batching/retry retention, redaction and debug-versus-production routing. A wrapper or manifest
alone does not prove consent-gated collection; inspect the actual data flow and product contract.

Correlation must answer the operational question without becoming covert tracking.

## Metric Design
- Define event/metric owner, purpose, schema, units, dimensions, sampling, retention, and deletion.
- Keep cardinality bounded.
- Version semantic changes rather than silently reusing an event name.
- Pair success metrics with guardrails such as errors, latency, crashes, energy, or opt-out.
- Client telemetry can be delayed, sampled, disabled, duplicated, or offline; do not use it as authoritative transaction state.

Separate success, failure, cancellation and latency populations with explicit denominator,
aggregation/window and missing-event assumptions. Review sampling/cardinality and instrumentation
behavioral cost; a renamed event or shifted window is not an observed improvement. Connect
alert thresholds to an actionable user-impact question, owner and permitted containment.

## Runtime Operations
- Feature flags need owner, default, targeting, expiry, dependency, offline behavior, and kill-switch semantics.
- Staged rollout needs abort thresholds and rollback instructions.
- Incident response preserves evidence, protects users, assigns severity/owner, and records timeline and remediation.
- SLOs should represent user journeys and include actionable error budgets.
- Crash-free percentage alone can hide hangs, data loss, and broken workflows.

For remote configuration, define typed keys, cached value/version and TTL, stale/offline/default
behavior, targeting/experiment owner and cleanup. A successful fetch does not prove that all
consumers observed the intended version; a kill switch cannot undo already-persisted effects.
Select enabled/disabled evidence only within current permissions.

For hotfix review, connect the observed shipped symptom to the smallest authorized correction
and targeted regression question. Review the complete candidate delta against the affected
shipped version, including dependency/configuration/migration differences; commit selection or
cherry-pick shape alone does not prove safety. Record containment limits, recovery and postmortem
follow-up. Urgency grants no code/Git/test/shipping authority.

Report observed telemetry separately from desired instrumentation. A warranted postmortem
separates an evidence-backed timeline, root cause, contributors and detection gaps. Actions need
an owner, due/revisit criterion and recurrence verification; blame or an unowned list does not
resolve missing evidence or the recovery decision. Containment is a proposal until authorized;
code rollback cannot reverse irreversible data or server-side effects.

## Evidence
- Before/after traces and budget comparison.
- Representative low/mid device and realistic data where possible.
- Memory warning, background/foreground, long session, repeated navigation, and network degradation.
- Release-build/device evidence for production claims.
- Log/privacy review, schema validation, offline/duplicate telemetry behavior, and crash symbolication.
- Rollout and rollback exercise for high-risk features.

## Primary Sources
- [Instruments](https://developer.apple.com/documentation/xcode/instruments)
- [MetricKit](https://developer.apple.com/documentation/metrickit)
- [Unified logging](https://developer.apple.com/documentation/os/logging)
- [Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
