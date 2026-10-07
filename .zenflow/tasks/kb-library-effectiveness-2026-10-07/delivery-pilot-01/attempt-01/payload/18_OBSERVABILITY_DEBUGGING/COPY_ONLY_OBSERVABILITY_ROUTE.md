# Observability and incident readiness — copy-only reference route

Use for a production-sensitive change, diagnostic question, crash/hang investigation or new
telemetry. Apply local incident, flag, rollout and product-health rules first. This route asks
whether the claimed failure could be detected and acted on; it does not read private production
systems, enable analytics, change flags or authorize a release.

1. Name the user-impact question and an owner. Connect a stable event/state taxonomy to the
   affected path, build/release identity and time window. For a crash or hang, preserve signal,
   exception/signal/watchdog class, symbolication and build UUID context, relevant frames and
   thread/lifetime/isolation evidence; do not infer a root cause from a single top frame or
   aggregate count. Record the symptom and environment, compare a few falsifiable hypotheses,
   and identify the cheapest discriminating evidence before recommending a speculative fix.
   For hangs, trace relevant thread stacks, main-actor work, locks, I/O and layout rather than
   interpreting the visible frozen screen as the cause. For races or network/data failures,
   correlate ordering, request/cache/decoding state and store history with the actual failure class.
2. Check that logs, metrics and signposts answer the question without source bodies, secrets or
   personal data. Bound sampling and cardinality; a high-cardinality identifier can be both a
   cost and privacy problem. Correlation should be useful without becoming covert tracking.
   Separate success, failure, cancellation and latency populations; inspect aggregation/window
   assumptions and missing events. Keep instrumentation narrow and assess its behavioral cost.
3. Define a threshold or symptom that prompts action and the smallest plausible containment:
   flag, server mitigation, staged pause, rollback or hotfix, only if it can actually contain
   the failure. A code rollback cannot undo irreversible data or server-side effects.
4. Report observed telemetry separately from desired instrumentation. For severe incidents,
   name the missing evidence, decision owner, recovery verification and postmortem need; do not
   silently accept a blocking risk or create a risk-register entry without user authority.
   After a supported root-cause finding, identify a regression detector or reproduction path;
   if neither is observed, keep the diagnosis provisional.
   A useful reproduction records initial state, clock/random/network/storage controls and the
   regression range. For suspected corruption, recommend bounded write containment and evidence
   preservation before recovery; do not perform destructive recovery or stop live services without
   authority. Across a migration, map old/new event meanings so a renamed metric cannot fake a gain.
   A warranted postmortem separates evidence-backed timeline, root cause, contributors and detection
   gaps; recommendations need an owner, due/revisit criterion and recurrence verification. Do not
   substitute blame or an unowned action list for the missing evidence and recovery decision.

`AUTO` can inspect already-authorized code/config/evidence; `ADVISORY` proposes the lowest-cost
measurement or operational check. No profile grants dashboard, network, analytics, rollout or
Git authority. This retains useful `ioslib-observability`/incident criteria without a runtime.
