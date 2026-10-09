# Identity, Authentication, And App Security

## Load When
Use for sign-in, account lifecycle, OAuth/OIDC, passkeys, Sign in with Apple, sessions, biometrics, Keychain, cryptography, app integrity, authorization, sensitive actions, or threat modeling.

## Security Model
Authentication establishes or refreshes identity. Authorization decides whether that identity may perform an action. Local device-owner authentication confirms user presence or device ownership; it does not by itself authenticate an account to a remote service.

An iOS client is not a trusted enforcement boundary. Attackers can inspect binaries, alter local state, replay requests, or run a modified client. Server-authoritative products must enforce permissions, entitlements, balances, and integrity-sensitive decisions on the server.

## Threat Model Intake
Before choosing an authentication mechanism, identify assets, actors, entry points, trust boundaries, attacker capabilities, abuse cases, recovery paths, and business impact. Include lost/stolen devices, compromised accounts, replay, phishing, malicious deep links, hostile web content, leaked logs, backups, and local data extraction.

Using HTTPS or Keychain somewhere is insufficient evidence for a whole feature security claim.
Trace assets, attacker-controlled entry points, actual authorization guards and failure/recovery
paths. Follow sensitive values through creation, transit, persistence, app-group sharing, backups/
synchronization, logs/crash metadata, analytics and deletion; check access, minimization, retention
and redaction at each relevant hop. Keep real secrets out of generated diagnostics, examples,
AI-readable workspace and task context; recommendations grant no secret intake or auth mutation.

## OAuth And OIDC
- Use Authorization Code with PKCE for public native clients.
- Use the system authentication session rather than embedding general login pages in a custom web view.
- Validate `state`; validate OIDC nonce, issuer, audience, signature, expiry, and authorized-party claims where applicable.
- Match redirect scheme/host/path exactly and reject unexpected parameters or duplicate callbacks.
- Never embed a client secret that is expected to remain secret in an app binary.
- Exchange and validate authorization results through the provider's documented flow.
- Define cancellation, browser-session policy, account switching, and callback ownership.

## Passkeys And Sign In With Apple
- Passkeys require a relying party and associated-domain relationship; registration and assertion use server challenges.
- Store account mapping and public credentials server-side; the device retains private key material.
- Design recovery, credential replacement, revoked accounts, changed Apple relay email, and multi-device behavior.
- Sign in with Apple user identifiers are scoped; persist the stable identifier and do not rely on name/email being returned after the first authorization.
- Re-check credential state and account revocation where the product requires it.

## Session Lifecycle
Define access-token lifetime, refresh rotation, storage, concurrency, logout, revocation, account deletion, device change, clock skew, offline expiry, and multi-request refresh coordination.

- Keep access tokens short-lived when the backend supports it.
- Serialize refresh so concurrent failures do not create a refresh storm.
- Bind retried requests to idempotency rules.
- On terminal refresh failure, transition once to an explicit signed-out/recovery state.
- Logout must clear credentials, user-specific caches, queued work, cookies where owned, and sensitive UI state.
- Never log tokens, authorization codes, passkeys, cookies, or authentication assertions.

At most one application refresh is in flight per current credential/session. Bound replay and
waiter cancellation; separate URLSession HTTP/TLS challenges from application-token refresh.
Refresh rotation, expiry/clock assumptions and terminal-versus-transient failures follow the actual
backend contract. After logout, account switching or newer login, completion from the superseded
session must not restore old credentials or publish an old response/UI result. Preserve the
credential format and Keychain access policy during an authorized concurrency change; framework
APIs do not supply this contract.

A permitted fixture plan covers concurrent application-auth failures, one current-session refresh,
bounded replay, terminal recovery and stale completion after logout/new login; challenge handling
is a separate case. Background/cancellation paths follow the actual session lifecycle.

## LocalAuthentication
Use LocalAuthentication to gate access or confirm user presence, not as the sole source of remote account identity. Choose whether passcode fallback is allowed. Handle unavailable, not enrolled, lockout, user cancel, system cancel, app cancel, and changed biometric enrollment.

Protecting a Keychain item with access control is stronger than evaluating biometrics and then reading an unprotected secret. Localized reason strings must explain the action without revealing sensitive data on the lock screen.

## Keychain And Data Protection
- Choose accessibility class from the required background/locked-device behavior.
- Use `ThisDeviceOnly` where migration/backup would violate the security model.
- Scope access groups narrowly and review every target that receives them.
- Store only necessary secrets and identifiers; large application data belongs in protected files or databases.
- Define reinstall, restore, device migration, account change, and key-unavailable behavior.
- Keychain persistence across reinstall can surprise account-reset assumptions; test the intended lifecycle.

Review secure-storage deletion/migration, user-presence requirements and actual error semantics
without opening a live secret store. An unavailable or failed read is not evidence that a
credential is absent. A review finding grants no credential/access-policy/authentication mutation.

## Cryptography
- Prefer CryptoKit and platform protocols; do not invent algorithms or wire formats.
- Define confidentiality, integrity, authenticity, key agreement, and password-derivation needs separately.
- Use authenticated encryption for confidential application data.
- Use cryptographically secure randomness and unique nonces as required by the algorithm.
- Design key generation, storage, rotation, versioning, backup, revocation, and loss recovery before encrypting durable data.
- Secure Enclave keys are useful only when their availability, algorithm, backup, and recovery constraints fit the product.

Encryption at rest does not establish an end-to-end security contract; trace the actual endpoints,
trust boundaries and key ownership before making that claim.

## App Attest And DeviceCheck
These are server-assisted risk signals, not local-only security features and not absolute jailbreak detection. App Attest requires server challenges and server-side attestation/assertion validation. Design unsupported-device fallback, retry, key loss, reinstall, environment separation, and gradual rollout.

Bind attestation/assertion validation to the server challenge and replay policy, key lifecycle
and actual failure/fallback/anti-abuse limits. A validated app-integrity signal is not user
authorization; unavailable attestation must not silently become equivalent successful evidence.

Do not add App Attest to a backend-less app and claim security benefit; document it as unavailable until the server boundary exists.

## Authorization Rules
- Deny by default at authoritative boundaries.
- Separate role, ownership, subscription, consent, and local presentation decisions.
- Re-check authorization when state can change remotely.
- Do not hide a button as the only enforcement mechanism.
- Sensitive local actions may require recent user presence even after account authentication.

## Evidence
- Threat model and abuse cases reviewed.
- Success, cancel, replay, state/nonce mismatch, expired token, revoked credential, refresh race, and account-switch tests.
- Keychain accessibility verified across relaunch, lock, reinstall/migration assumptions, and target access groups.
- No secrets or personal data in logs, crash metadata, analytics, source, or bundles.
- Entitlements, associated domains, callback URLs, privacy declarations, and server validation inspected.
- Hardware-dependent claims remain unverified when evidence is unavailable or excluded by current
  user scope; excluded checks are OMITTED_BY_USER, never PASS.

For a material security finding, verify the claimed shipping-path reachability, attacker input
control, guard bypass and impact against the shown path. Inspect a relevant cross-component route
through extensions, shared storage, callbacks, redirects or diagnostics; merge duplicate symptoms
of one root cause. Remove unsupported severity claims while keeping confidence and impact
separate; an unverified premise remains UNKNOWN, never PASS. This is evidence appraisal within
the permitted review, not an additional mandatory Library pass or authority to run a scan.

## Primary Sources
- [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices)
- [Supporting passkeys](https://developer.apple.com/documentation/authenticationservices/supporting-passkeys)
- [LocalAuthentication](https://developer.apple.com/documentation/localauthentication)
- [Establishing app integrity with App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
- [Apple Platform Security](https://support.apple.com/guide/security/welcome/web)
- Provider OIDC metadata, OAuth specifications, and W3C WebAuthn for the adopted flow.
