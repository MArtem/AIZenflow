# Performance, Observability, And Operations

## Load When
Use for performance budgets, Instruments, launch, hangs, scrolling, memory, energy, network cost, MetricKit, logging, analytics, crash reporting, rollout, incidents, or production health.

## Measure From User Impact
Define the user-visible operation, environment, data size, percentile, device class, OS/build, and budget. Averages hide tail latency. Debug builds and a single Simulator are diagnostic inputs, not production performance evidence.

## Performance Domains
- Launch: pre-main work, static initialization, dependency setup, restoration, first frame, first usable content.
- Responsiveness: main-thread blocking, actor/queue contention, synchronous I/O, hangs, animation hitches.
- Rendering: invalidation breadth, body/layout cost, overdraw, offscreen rendering, image decode, list identity.
- CPU: algorithms, parsing, serialization, compression, crypto, background work.
- Memory: peak, steady state, retained graphs, caches, decoded media, mapped files, jetsam risk.
- Storage/network: I/O volume, transaction size, downloads, retries, radio wakeups.
- Energy/thermal: timers, location, sensors, background execution, GPU and network activity.

## Optimization Workflow
1. Reproduce a representative path.
2. Capture a baseline trace and signpost interval.
3. Identify the dominant measured cost.
4. Change one ownership/algorithm/data-flow cause.
5. Re-run under comparable conditions.
6. Check correctness, memory, energy, accessibility, and older-device regressions.

Do not replace a measured problem with unbounded caching, stale data, unsafe concurrency, or reduced accessibility.

## Observability
Use structured logs with stable subsystem/category, privacy annotations, bounded metadata, and actionable levels. Add signposts around important intervals. Analytics describes product events; operational telemetry describes health. Crash reports, hangs, MetricKit payloads, and support diagnostics have separate privacy and retention concerns.

Never record secrets, credentials, full request/response bodies, user-authored sensitive content, precise location, or identifiers without explicit approved need and minimization.

## Metric Design
- Define event/metric owner, purpose, schema, units, dimensions, sampling, retention, and deletion.
- Keep cardinality bounded.
- Version semantic changes rather than silently reusing an event name.
- Pair success metrics with guardrails such as errors, latency, crashes, energy, or opt-out.
- Client telemetry can be delayed, sampled, disabled, duplicated, or offline; do not use it as authoritative transaction state.

## Runtime Operations
- Feature flags need owner, default, targeting, expiry, dependency, offline behavior, and kill-switch semantics.
- Staged rollout needs abort thresholds and rollback instructions.
- Incident response preserves evidence, protects users, assigns severity/owner, and records timeline and remediation.
- SLOs should represent user journeys and include actionable error budgets.
- Crash-free percentage alone can hide hangs, data loss, and broken workflows.

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
