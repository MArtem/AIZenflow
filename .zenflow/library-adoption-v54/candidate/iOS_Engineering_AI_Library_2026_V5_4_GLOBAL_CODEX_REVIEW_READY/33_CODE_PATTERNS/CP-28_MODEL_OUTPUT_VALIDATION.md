# CP-28 — AI model output is untrusted input

For machine-consumed model output:
- prefer structured/guided generation where available;
- validate enum/range/identifier/business constraints;
- never let generated text directly authorize payments, account changes or privileged tool actions;
- enforce authorization/idempotency inside the tool/business layer;
- define retry/fallback for invalid output.

Prompt wording is not a security boundary.
