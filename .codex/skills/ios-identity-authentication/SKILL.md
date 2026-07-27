---
name: ios-identity-authentication
description: Use for iOS login, OAuth/OIDC/PKCE, passkeys, Sign in with Apple, session refresh, logout, account switching, LocalAuthentication, Keychain access control, authorization, App Attest, or DeviceCheck. Trigger whenever identity or access decisions are designed, implemented, or reviewed.
---

# iOS Identity And Authentication

## Required Context
Read:

- `./docs/IOS_SECURITY_PRIVACY_GATE.md`
- `./docs/knowledge/global/ios/IDENTITY_AUTHENTICATION_AND_APP_SECURITY.md`
- API/backend contracts when remote identity or App Attest is involved

## Workflow
1. Separate identity, remote authentication, local user-presence authentication, authorization, and fraud signals.
2. Identify authoritative server/client boundaries and required backend components.
3. Threat-model callback, token, replay, phishing, account recovery, logout, and lost-device paths.
4. Define credential storage, refresh concurrency, revocation, account switching, deletion, and offline behavior.
5. Compare provider/system flows and explain security, UX, backend, recovery, and platform tradeoffs.
6. Select simulator, physical-device, server, entitlement, and security evidence explicitly.

## Guardrails
- A client secret cannot remain secret in an app binary.
- LocalAuthentication does not authenticate a remote account.
- App Attest requires server validation and is not useful as a local-only claim.
- Never log tokens, authorization codes, assertions, cookies, or sensitive account data.
- Do not guess provider behavior or App Review requirements.

## Output
Report threat model, trust boundaries, selected flow, alternatives, session lifecycle, data handling, failure/recovery states, prerequisites, and evidence gaps.
