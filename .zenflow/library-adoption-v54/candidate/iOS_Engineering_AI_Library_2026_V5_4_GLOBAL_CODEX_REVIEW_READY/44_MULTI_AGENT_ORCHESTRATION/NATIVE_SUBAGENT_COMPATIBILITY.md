# Native Subagent Compatibility — September 2026

V5 is orchestration-policy-first, runtime-second.

When a native subagent primitive is available, use its actual exposed schema rather than assuming fields such as role/model overrides exist. Spawned agents should normally inherit the parent model/effort; override only when the user asks or the runtime explicitly exposes and the task benefits.

Prefer independent tasks in parallel; avoid reflexive waiting and duplicate coordinator work. When scoped-history controls are available, send the minimum sufficient context packet.

If native delegation is unavailable or a desired custom role cannot be selected, execute the same role contract sequentially in the root context. Label the result **sequential role pass**, not independent review.

Do not encode undocumented CLI/config flags as hard requirements. Feature-detect capabilities at execution time.
