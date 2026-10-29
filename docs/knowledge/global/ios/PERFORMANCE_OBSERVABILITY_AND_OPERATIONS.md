# Performance, Observability, And Operations

## Load When
Use for performance budgets, Instruments, launch, hangs, scrolling, memory, energy, network cost, MetricKit, logging, analytics, crash reporting, rollout, incidents, or production health.

## Measure From User Impact
Define the user-visible operation, environment, data size, percentile, device class, OS/build, and budget. Averages hide tail latency. Debug builds and a single Simulator are diagnostic inputs, not production performance evidence.

Select a diagnostic from the symptom and available toolchain: Time Profiler for sampled CPU work,
Allocations for allocation behavior, ownership/Memory Graph or Leaks evidence for a lifetime
hypothesis, and network or SwiftUI/animation traces for the corresponding path. A tool name or
source pattern is not evidence of the actual bottleneck. These are permission-bounded proposals.

## Feature-Driven Runtime Audit

Identify real app targets, navigation and user journeys from requirements and consumers. Choose a
small order using user impact, known frequency, harm and reversibility, recent changes or symptoms,
uncertainty and cost of useful evidence. Unknown facts remain unknown. Planning priority is separate
from finding severity. Include relevant happy, failure/recovery and ordering transitions; pairwise
combinations do not prove critical ordering. Keep important blocked journeys visible.

For a bounded feature, screen or module audit, use user actions as workloads to investigate applicable performance domains and report measured signals, coverage and gaps. Keep discovery distinct from subsequent cause localization and fix planning, then verify any implemented fix with comparable before/after evidence; do not turn functional interaction accuracy into the sole audit goal.

## Readiness Gate And Profile-to-Fix Stages

Before capture, record a compact readiness matrix for the selected target and scope: source/build
revision and configuration; OS, SDK, Xcode/Instruments and runtime compatibility; installed app or
authorized build availability; supported metric/template and export path; driver and app-process
attachment path; fixture/reset/backend prerequisites; output location and privacy boundary. Record
availability and permission separately, and express gaps with the active task's status vocabulary;
do not invent a readiness pass/fail verdict. Capability and permission are separate: available does
not mean authorized, and missing access does not mean the metric is zero. Distinguish Simulator
GUI availability from command-line `simctl`; one does not establish the other. Keep readiness checks
non-invasive unless the corresponding build, launch, UI, Instruments, fixture, or service action is
explicitly permitted. Never install tools as a readiness shortcut.

Keep the investigation in three reviewable stages; a user may authorize them together, but the
evidence and exit decision for each stage remain distinct:

1. **Discovery:** review authorized existing evidence or, when permitted, execute the prioritized
   user journeys as workloads and collect every applicable authorized metric domain. Deliver actual
   branch outcomes when observed, per-domain measured/invalid/unsupported/omitted/unmeasured status,
   raw evidence references, observations and limitations, plus ranked candidate signals. If capture
   is unavailable or unauthorized, report readiness and planned measurements as gaps; do not infer
   outcomes or metrics. Do not promote correlation or a hotspot into a root cause or start fixes
   before the discovery report is reviewable.
2. **Cause localization and fix plan:** consume the reviewed discovery bundle, inspect the implicated
   source paths/callers/ownership and correlate them with traces. A stronger model or reviewer may be
   useful under the active model route; do not create a handoff or imply independent validation without
   authorization. Deliver confirmed causes vs hypotheses, code locations, causal evidence/confidence,
   smallest proposed changes, regression/guardrail checks, and any permission or capture prerequisites.
3. **Authorized repair and re-profile:** change only the approved block. Repeat the same scenario,
   fixture/data envelope, relevant cache/network state, build/runtime, tool and interval. Report
   before/after observations and variance. A fix is not verified when the capture is invalid, expected
   metric data is unusable, or conditions materially differ. If valid comparable data no longer shows
   the target symptom, report that as evidence for the fix with its remaining limits and guardrails.

For a phase handoff, preserve a compact evidence bundle: task/project identity and scope; source
revision/configuration and runtime/toolchain; readiness matrix and permissions; scenario IDs, fixture
envelopes, actual outcomes and resets; metric names/units/process/intervals/sample counts and
limitations; candidate finding, severity, status and confidence; observed values and unresolved questions.
In this `.zenflow` workspace, store full
profiling reports, scenario matrices, structured metric exports, and retained raw outputs under
`/Users/Artem/.zenflow/profiling-results/<ProjectSlug>/<TaskId>/`; put traces, result bundles, logs,
and attachments in `artifacts/`, and metric exports in `metrics/`. Keep only active `plan.md` and a
compact `handoff.md` in the project task directory as task state; link them to the central report and
manifest instead of duplicating full reports. Maintain a per-task `manifest.md` and root `README.md`
and `INDEX.md`. The shared evidence root is local and outside Git/the documentation vault. In other
environments, use a task-approved private path rather than assuming this host path. Link artifacts
instead of embedding private content, and label assumptions and unavailable data. This bundle should let the next reviewer
continue cause localization without repeating valid discovery; it is not a new metric schema or
permission grant.

Discovery coverage accounting is complete only after every identified journey has an observed
outcome or an explicit not-run reason/status, every applicable metric domain has a result or stated
gap, and no high-priority path is silently omitted. This accounts for declared scope; it does not
mean every item was measured. When access, support, time or evidence quality leaves items unresolved,
state that the report has gaps and list them. Report completion is not proof that all defects were
found or a clean performance verdict.

For each scenario record an ID, feature/route, user goal, initial state and fixture/version, actions,
observable end condition or invariant, driver, question/metric and method, bounded repetitions and
duration, reset/cleanup authority and evidence gaps. A safe backend/account is needed only when
applicable. An authorized manual driver can exercise a journey without XCUITest; no account, backend
or new harness is universally required. Separate permissions for builds, test creation/modification/
execution, UI/Simulator, profiling, fault injection and external effects. Planning grants none.

For randomized or otherwise variable outcomes, record a controllable seed or the actual branch/result
for each iteration. A passing run covers only the outcomes observed; do not infer hit, miss, success,
failure or recovery branches from a generic terminal pass. Preserve result labels or lightweight
attachments outside the measured interval where possible. Assert stable state invariants across valid
status variants, unless exact wording is itself a product contract.

| Journey / question | Candidate method and signal | Interpretation limit |
| --- | --- | --- |
| Image list/search scroll | UI journey, hitch or SwiftUI tracks, Time Profiler; Allocations for decode/cache | Body count is not a hitch; alpha is not GPU cost; compressed size is not decoded memory. |
| Navigation and memory after exit | Repeated enter/exit and quiescence; Allocations, Memory Graph or Leaks | RSS growth or no Leaks report does not prove a retain cycle or its absence. |
| Search, loading, cancellation or retries | Controlled request ordering/events and UI state; available concurrency or CPU/hang tracks | Cancellation is not completion or server rollback; a task may have a legitimate longer-lived owner. |
| Launch, first usable content and resume | Launch metric and distinct ready interval; available App Launch/Time Profiler | First frame is not business readiness; resume is not cold launch. |
| Save/reopen, data access or network retry | Durable functional invariant plus scoped I/O, CPU or network timing/correlation | Fast work may lose data; client timeout does not prove server rollback. |
| Media start/stop/teardown | Playback state, CPU/allocations and session lifetime in permitted Simulator | Simulator cannot establish hardware energy, GPU, audio or thermal behavior. |

Before permitted capture establish target, safe fixture, driver, supported tool, baseline and output
privacy. Verify build, process identity, session and capture readiness before actions; correlate their
interval with the terminal capture and actual exported data or assertions. A UI test's `app.launch()`
can replace an attached process; a trace of the old PID does not cover the new one. Separate UI and
trace runs remain separate evidence. A trace or table of contents alone is not an interpreted metric
or diagnosis. Failed, partial or unavailable capture stays a gap. Apply `EVIDENCE_BASED_ENGINEERING_RULES.md`
and `SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md` for retention and privacy.

Verify that each requested metric actually appears with usable samples; a passing test does not prove every metric was collected. Keep independently supported metrics available when another metric is unavailable. Inspect both raw data tables and available view-level details when interpreting a trace; a table-of-contents entry is not proof of usable data.

When SwiftUI trace data is unavailable, authorized temporary Debug change logging can provide qualitative evidence of view-body updates and their reported triggers. Logging changes the workload; messages do not establish rendering cost, visual frame count, or a performance defect. Remove temporary instrumentation after capture and apply the normal privacy and retention rules to logs.

When automation may perturb a result, compare a bounded, as-nearly-matched control with fewer queries or another permitted driver. Record differences in actions and state; a changed workload or a missing signal does not prove causation or the absence of defects. Allocation totals describe cumulative activity, not resident memory or a leak.

Record actual metric name, unit, process, interval, origin and raw samples, source/build revision,
configuration, toolchain/runtime/host, debugger/diagnostics, fixture, cache/network state, repetitions,
reset, warmup and failed runs. Before/after revisions may differ, but their identities and conditions
must be known and comparable. Invalid numbers, missing units or incompatible conditions are
inconclusive. Without an approved budget, valid numbers remain observations without a budget verdict.
Keep peak, growth and retained-object evidence distinct; median and MAD describe samples but do not
establish statistical significance. Do not invent universal sample counts, percentile confidence or
budgets. A cold launch observation is not a warmup to discard; define process/cache state, since
relaunch alone does not prove cold system caches. Account for instrumentation when comparing timing.

Examples are plans, not executed results. For an image list, select a real scroll route and fixture,
then correlate a hitch interval with available UI/CPU tracks and allocation evidence. For search,
start requests A and B, complete B and observe it, then complete A and wait until the old completion
is handled before checking that B remains authoritative. Cancellation, stale-result suppression and
server-side effects are separate claims.

## Metric Selection And Code Attribution

Use the requested user-visible symptom and actual feature architecture to choose applicable tools.
The table is a selection aid, not a requirement to run every instrument or a promise that every
instrument works for each Simulator/runtime:

| Question | Candidate capture | What must be verified and what it does not prove |
| --- | --- | --- |
| App CPU and action latency | `XCTCPUMetric(application:)`, `XCTClockMetric`, `XCTOSSignpostMetric`; Time Profiler; CPU Counters after a hotspot is known | Confirm app target, unit, measured interval and usable samples. XCTest can cause work in the app; sampled stack count is not wall latency or a universal budget. |
| Main-thread stalls and scheduling | Hangs/Time Profiler and System Trace; signposts for action/task boundaries | A hang threshold misses shorter stalls; waiting/blocked samples, CPU use and thread ownership are different signals. |
| Launch and first usable state | `XCTApplicationLaunchMetric`, App Launch and a separate signposted readiness point | App process launch is not necessarily first frame or product-ready content. |
| SwiftUI updates and visual hitches | SwiftUI Instruments, `XCTHitchMetric` or available Animation Hitches/frame tracks | Check that update/hitch/frame tables contain data. Body evaluations are not equivalent to frames, visual defects, or user-perceived latency. |
| Memory peak, growth and retention | `XCTMemoryMetric(application:)`, Allocations with generation marks, Leaks and Memory Graph | Separate transient allocations, resident/physical peak or delta, retained objects and ownership. Allocation totals and RSS drift alone are not proof of a leak. |
| Concurrency and async work | System Trace, thread/actor tracks where available, signposted task lifetime and cancellation | A task's presence does not prove useful parallelism, contention, correct ownership, or cancellation semantics. |
| Network, file, storage or media path | Network/File Activity/XCTStorage metrics and CPU/allocation tracks for the actual consumer | Include request/data size, cache, retries and response ordering. Client latency does not prove server completion or rollback. |
| Energy and thermal behavior | Energy Log/Power Profiler and relevant timer, wakeup, CPU, GPU, location or network activity | Simulator is a diagnostic proxy, not physical battery-life or hardware/thermal evidence. Respect device exclusions. |

Use `OSSignposter` intervals/events at app-owned action or subsystem boundaries and
`XCTOSSignpostMetric` where performance tests can consume them. Prefer stable low-cardinality names
and non-sensitive metadata. Do not signpost every repeated cell/view by default: high-volume
instrumentation changes cost and can drown the causal interval. If needed, gate detailed diagnostic
signposts and state the build/launch condition used. Place terminal assertions, attachments and
expensive accessibility queries outside the timed block where the scenario permits.

For each suspected defect, build an evidence chain: user action/outcome → valid interval and metric
→ app-owned stack/signpost/view/retention evidence → source owner/call sites/state transition →
reproduction or a controlled comparison. Static inspection narrows the search and can prove a code
contract defect; it cannot substitute for dynamic evidence of a cost, leak, hitch or regression.
Conversely, a profiler signal without source attribution identifies a symptom, not its code cause.
Keep confidence, severity, and measurement status separate. If a table is empty, process identity is
wrong, symbolication failed, random outcome differs, or the interval missed the action, record an
invalid/partial capture and its gap rather than a negative finding.

### Finding Plans And Closure

Treat every plausible code-error signal as work to disposition, not merely as an observation. Give
each confirmed defect or hypothesis its own record with evidence, confidence, user impact/severity,
scenario and source owner. State a concrete per-finding plan: the next diagnostic step, how to confirm
or reject the code cause, the smallest correction if confirmed, and the checks/re-profile needed under
current permissions. Continue through all authorized corrections; if evidence, scope or authority
blocks an item, preserve its actionable plan and exact blocker. Do not make speculative performance
changes from an unconfirmed signal. In the final report state whether each correction is verified,
runtime verification remains outstanding, work is blocked with a concrete plan, or the signal was
rejected with evidence. Use the project's existing finding/task status vocabulary; these reporting
outcomes do not define a new status enum. Record an explicit decision on whether re-profiling is
needed and why; no performance improvement is established without comparable measurements.

For before/after assessment preserve the same journey, data envelope, target process, relevant
cache/network state, build configuration, OS/runtime and instrument settings. Keep raw observations
and repetitions so variance and branch coverage can be reviewed; use a robust summary only when the
sample population supports it. Establish a budget from product needs and stable evidence, not from a
single capture or an arbitrary tool default. After a code change, re-run the same scenario and
inspect both expected improvement and correctness/resource guardrails.

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
1. Reproduce a representative path when execution is authorized.
2. Capture an appropriate baseline and existing signpost interval when available and permitted.
3. Identify the dominant measured cost from valid evidence.
4. Change one ownership/algorithm/data-flow cause only within the approved scope.
5. Re-run under comparable conditions when authorized.
6. Check correctness, memory, energy and accessibility within current verification permissions; excluded device checks remain omitted.

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

For an authorized metric rename/schema transition, record the old-to-new metric mapping,
compatibility window and affected dashboards, alerts and consumers. Keep populations/units
comparable and prevent dual-emitted events from being counted twice; name the criterion for retiring
the old metric. A rename alone does not establish improvement.

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

## Measured-Cause And Telemetry Example
A list appears to hitch after a refresh. One hypothesis is expensive body work; another is a
high frequency of individually short updates. Apple SwiftUI Instruments separates those cases.
Under permitted profiling, identify the causal path before selecting off-render computation,
narrower observation or a bounded cache. Starting a Task alone does not prove heavy work left
the main actor. Recompare the same workload and preserve data freshness/cancellation behavior.

For a rollout metric rename, duplicate emission can double a success count without improving
any user journey. Keep one semantic population, map old/new dashboard consumers and separate
missing/duplicate/cancelled observations. A static schema review supports consistency, while
an improvement claim needs comparable observations. These are diagnostic/evidence examples,
not a recorded trace, production metric or authorized rollout.
Primary theory: [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance).

## Evidence
Apply `CURRENT_USER_OVERRIDES.md` before selecting or proposing evidence. Omit iPad, physical-device and actual VoiceOver checks from plans and acceptance; preserve historical observations and mark excluded coverage `OMITTED_BY_USER`, never PASS. Execute profiling or other runtime checks only with current explicit permission. Simulator results do not establish hardware or real-user performance; report that limitation without restoring excluded prerequisites.

- Before/after traces and budget comparison.
- Representative permitted environment and realistic data; record the actual environment and coverage limits.
- Memory warning, background/foreground, long session, repeated navigation, and network degradation.
- Evidence appropriate to the exact production claim within current permissions; missing or excluded evidence leaves that claim unverified.
- Log/privacy review, schema validation, offline/duplicate telemetry behavior, and crash symbolication.
- Rollout and rollback exercise for high-risk features.

## Primary Sources
- [Instruments](https://developer.apple.com/documentation/xcode/instruments)
- [Writing and running performance tests](https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests)
- [Recording performance data with signposts](https://developer.apple.com/documentation/os/recording-performance-data)
- [Xcode performance and metrics](https://developer.apple.com/documentation/xcode/performance-and-metrics)
- [MetricKit](https://developer.apple.com/documentation/metrickit)
- [Unified logging](https://developer.apple.com/documentation/os/logging)
- [Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
