---
name: ios-performance-profiler
description: Use this skill for iOS performance investigations, scroll jank, launch slowness, memory growth, SwiftUI hot paths, Instruments traces, hitches, hangs, media decoding, caching, and comparing before/after metrics. Trigger whenever the user mentions profiler, Instruments, lag, jank, FPS, memory, launch time, or performance metrics.
---

# iOS Performance Profiler

## Workflow
1. Define the scenario and expected user interaction.
2. Check source for known hot-path violations before profiling.
3. Select only currently authorized static review, iPhone Simulator profiling, or manual QA. Profiling requires explicit execution permission.
4. Apply `CURRENT_USER_OVERRIDES.md`: omit iPad, physical-device and actual VoiceOver checks from plans and acceptance; retain historical results as history and mark excluded coverage `OMITTED_BY_USER`, never PASS. Do not infer hardware performance from Simulator evidence.
5. Compare permitted before/after evidence using the same scenario and environment; missing measurements remain unverified.
6. Report failed captures honestly; do not infer metrics from invalid traces.

## Review Areas
- SwiftUI body and repeated rows.
- Lazy list structure and identity.
- Scroll callbacks and state updates.
- Main-thread media/file/db/network work.
- Memory/cache bounds.
- Heavy rendering effects.

## Output
- Scenario.
- Tool/device.
- Metrics/evidence.
- Findings P0-P3.
- Next measurements.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_PERFORMANCE_BUDGETS.md`
- `DOC:PRODUCTION_CODE_REVIEW_CHECKLIST.md`
