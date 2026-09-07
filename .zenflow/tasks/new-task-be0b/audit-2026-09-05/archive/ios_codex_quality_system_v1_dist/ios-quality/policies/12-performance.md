# 12 — Performance and Responsiveness

## Principle

Measure before optimizing, but prevent obvious main-thread blocking by design.

Apple responsiveness guidance treats roughly 100 ms synchronous main-thread response work as noticeable for discrete interactions, while smooth animation must fit within display refresh deadlines (often 16.7 ms at 60 Hz or 8.3 ms at 120 Hz). The system therefore treats main-thread CPU/blocking work as a high-value review area.

## MUST

- avoid network/disk/blocking waits on main thread;
- avoid substantial parsing, image processing, compression, crypto, sorting or large transforms on MainActor;
- prevent unbounded loops/allocations in UI update paths;
- verify performance claims with measurement, not intuition.

## SwiftUI

When SwiftUI updates are expensive/frequent, use the SwiftUI Instruments/Cause & Effect tooling where available to identify why bodies update and how long updates take.

## Instruments

Use the tool that matches the symptom:

- Time Profiler / CPU Profiler — CPU hot paths;
- Hangs/Hitches — responsiveness;
- SwiftUI instrument — view update causes/duration;
- Allocations/Leaks/Memory Graph — memory;
- Network instruments — request behavior;
- signposts — app-defined intervals.

## Performance tests

For important regressions, establish a baseline/threshold using performance tests or Instruments. Performance tests should approximate production conditions and generally use optimized/release-like builds when measuring real throughput.

## Device testing

Simulator is not authoritative for all performance characteristics. R4/R5 performance-sensitive changes SHOULD be checked on a representative physical device, including an older supported device when practical.

## No speculative complexity

Do not add caches, parallelism, custom allocators, unsafe memory, or elaborate batching unless a measured problem justifies the added complexity.
