---
name: ios-performance-profiler
description: Investigate iOS performance or plan a runtime audit around app journeys; select relevant Simulator, Instruments or existing evidence for lag, FPS, launch, scrolling, hitches, hangs, memory, media and before/after comparisons. Not for an ordinary review without a performance question.
---

# iOS Performance Profiler

## Workflow
1. Identify actual app journeys from requirements, navigation and consumers. Rank a small set by user impact, known frequency, potential harm, symptoms or changes, uncertainty and measurement value. Keep blocked important paths visible; scenario order is not finding severity.
2. Define the user action, expected outcome and measurement question. Source hot paths are hypotheses or code findings, not runtime measurements.
3. Distinguish planning, interpretation of authorized existing evidence and new capture. Check separate permissions for builds, tests, UI/Simulator, Instruments, fixture changes and side effects. Planning does not run discovery tools. An authorized manual driver can provide scoped evidence without UI tests; do not create a harness without permission.
4. Apply `CURRENT_USER_OVERRIDES.md`: omit iPad, physical-device and actual VoiceOver checks from plans and acceptance; retain historical results as history and mark excluded coverage `OMITTED_BY_USER`, never PASS. Do not infer hardware performance from Simulator evidence.
5. Choose methods for the actual feature and record environment, fixture, action, interval, metric and evidence. Compare only compatible runs; missing or invalid captures remain unverified. Without permission return a plan and the gap, not a claim that the running app was audited.

## Review Areas
- SwiftUI body and repeated rows.
- Lazy list structure and identity.
- Scroll callbacks and state updates.
- Main-thread media/file/db/network work.
- Memory/cache bounds.
- Heavy rendering effects.

## Output
- Prioritized scenario and rationale, permitted method and tool/environment.
- Observed metrics and exact evidence versus source-based hypotheses; findings P0–P3.
- Blocked or unmeasured paths, limits and smallest useful next permitted measurement.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_PERFORMANCE_BUDGETS.md`
- `DOC:PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `DOC:knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` — runtime scenarios, capture and interpretation.
