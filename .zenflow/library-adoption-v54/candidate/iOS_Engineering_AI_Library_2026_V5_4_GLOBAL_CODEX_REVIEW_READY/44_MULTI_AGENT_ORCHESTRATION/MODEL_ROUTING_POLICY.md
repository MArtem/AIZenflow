# Model Routing Policy

Correctness and capability come before micro-optimizing model cost.

- Default: child agents inherit the parent model and reasoning effort.
- Do not override model/effort unless the runtime exposes the control and there is a material reason.
- Use cheaper/faster workers only for genuinely bounded low-risk extraction or mechanical checks when quality remains sufficient.
- Keep high-risk synthesis, architecture, concurrency/security arbitration and final integration on a sufficiently capable configuration.
- Never assume a model name implies support for custom-agent routing; use the tool schema actually exposed in the session.
