# Evidence and verification for copy-only reference

Evidence describes what was actually observed, not what the library asked the agent to do:

| Level | Meaning | Permitted claim |
| --- | --- | --- |
| E0 | Hypothesis or uninspected assumption | Possible risk only |
| E1 | Inspected source, configuration, documentation or static diff | Static contract or reasoned finding |
| E2 | Relevant target compiled in the declared configuration | That target compiled there |
| E3 | Relevant automated test passed | Tested behavior under that test's conditions |
| E4 | Reproduced runtime, device, simulator or instrument observation | Observed runtime behavior in that environment |
| E5 | Production telemetry or rollout observation | Observed production outcome for that cohort/time |

Do not infer a higher level from a lower one. In particular, `git diff --check`, a document
review, or a passing test does not prove that every affected app/extension target builds, that a
screen matches a design, or that there is no race or memory leak. Negative and failure paths need
their own evidence. State omitted checks and why they were omitted.

Status vocabulary:

- `QUALITY_REVIEWED`: task-appropriate local and, when ON, reference review completed for the
  current complete candidate; all findings and missing evidence are reported.
- `RUNTIME_VERIFIED`: the stated runtime scenarios were actually observed; this is scoped to
  those scenarios, not a universal safety claim.
- `READY_FOR_USER_REVIEW`: no unresolved blocking finding in the current candidate; the user can
  inspect its complete diff and evidence limits.
- `READY_FOR_PR`: only when the applicable project gates and authorized build/test/release
  evidence are satisfied; PR creation remains a separate user decision.
- `INSUFFICIENT_EVIDENCE`: a required observation is missing, partial, stale or not authorized;
  never translate this into PASS.

Changing any reviewed artifact invalidates its final whole-diff review receipt. Permission to
write tests or run verification is not implied by this document or by reference `ON`.
