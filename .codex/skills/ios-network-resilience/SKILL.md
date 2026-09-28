---
name: ios-network-resilience
description: Use this skill for iOS transport reliability: timeout, retry/backoff, cancellation, auth refresh, pagination under unreliable networks, uploads/downloads, and partial transport failure. Trigger when the task contains one of these reliability risks; generic API schema work belongs to ios-api-contracts.
---

# iOS Network Resilience

## Workflow
1. Map endpoint classes and mobile failure modes.
2. Check timeout, retry, backoff, cancellation, idempotency, and partial success.
3. Verify auth refresh/session expiration ownership.
4. Check DTO/domain/UI boundaries and logging redaction.
5. Report findings with remediation and verification.

## References
- `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`
- `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`
