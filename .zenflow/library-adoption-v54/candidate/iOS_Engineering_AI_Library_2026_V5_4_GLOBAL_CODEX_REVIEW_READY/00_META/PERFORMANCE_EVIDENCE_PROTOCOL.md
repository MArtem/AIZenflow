# Performance Evidence Protocol

1. Define user-visible metric: launch, hitch ratio, frame stall, CPU, memory peak, network latency, energy, DB query time.
2. Capture baseline with stable workload.
3. Add signpost/state labeling if attribution is weak.
4. Profile the bottleneck; do not infer from source aesthetics.
5. Change one dominant factor.
6. Measure after with same device/build/workload.
7. Record trade-offs (memory vs CPU, latency vs battery, caching vs staleness).
8. Add regression guard when practical.

In iOS 27+ projects evaluate the modern MetricKit `MetricManager` async-sequence APIs and StateReporting where they fit; keep older `MXMetricManager` paths when deployment targets require them.
