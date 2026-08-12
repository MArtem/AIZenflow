# iOS PR Review Template

## Scope
- What changed:
- User-visible behavior:
- Out of scope:

## Risk Card (complete before implementation)
- Primary risk class: UI/accessibility | state/concurrency | persistence/import/export | external input | dependency | build graph/workflow | other:
- Required invariant and explicitly unchanged behavior:
- State ordering to preserve (success / empty / error / cancellation / retry / concurrent action):
- Authority and data-safety boundary (trusted input, untrusted input, or data that must not be lost):
- Affected producers, consumers, callers, schemas, configuration, and claims:
- Smallest sufficient evidence and intentionally omitted evidence:
- Residual risk or user decision still required:

Use one primary high-risk class per PR. Combine two only when they are inseparable; explain the
dependency above and select evidence for both. This is a scoping aid, not a reason to split a
correct atomic fix.

## Required Checks
- [ ] Product requirements and states are clear.
- [ ] Architecture/state/data ownership is correct.
- [ ] UI hot paths are clean.
- [ ] Concurrency/lifecycle/cancellation are safe.
- [ ] Persistence/network/offline behavior is correct where applicable.
- [ ] Security/privacy/logging are safe.
- [ ] Accessibility/localization are covered.
- [ ] Errors/retry/empty/loading/offline states are covered.
- [ ] Memory/cache/media behavior is bounded where applicable.
- [ ] Observability is sufficient.
- [ ] Verification evidence is attached.
- [ ] Risks/debt/exceptions are recorded.

## Reviewer Output
- Blocking findings:
- Non-blocking findings:
- Remaining risks:
- Required follow-up:
- Approval condition:

## Review Receipt
- Trusted base SHA → reviewed HEAD SHA:
- Self-review: proposed diff / exact committed SHA:
- Relevant checks and results:
- External review recommendation/result:
- Escaped finding feedback record, if any:
