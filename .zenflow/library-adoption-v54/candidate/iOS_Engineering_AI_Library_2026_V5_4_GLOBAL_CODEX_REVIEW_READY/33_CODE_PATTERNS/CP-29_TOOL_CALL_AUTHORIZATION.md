# CP-29 — Tool calling: authorization stays in code

A model choosing to invoke a tool is only a request. The tool implementation must independently verify:
- current authenticated user/session;
- authorization for the target resource/action;
- argument validity;
- idempotency/duplicate-call behavior;
- consent/permission for sensitive system frameworks;
- audit/logging without sensitive payload.

Use narrow typed tool schemas. Avoid a generic "execute arbitrary action" tool.
