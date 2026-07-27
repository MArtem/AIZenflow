# Identity, Authentication, And App Security

## Load When
Use for sign-in, account lifecycle, OAuth/OIDC, passkeys, Sign in with Apple, sessions, biometrics, Keychain, cryptography, app integrity, authorization, sensitive actions, or threat modeling.

## Security Model
Authentication establishes or refreshes identity. Authorization decides whether that identity may perform an action. Local device-owner authentication confirms user presence or device ownership; it does not by itself authenticate an account to a remote service.

An iOS client is not a trusted enforcement boundary. Attackers can inspect binaries, alter local state, replay requests, or run a modified client. Server-authoritative products must enforce permissions, entitlements, balances, and integrity-sensitive decisions on the server.

## Threat Model Intake
Before choosing an authentication mechanism, identify assets, actors, entry points, trust boundaries, attacker capabilities, abuse cases, recovery paths, and business impact. Include lost/stolen devices, compromised accounts, replay, phishing, malicious deep links, hostile web content, leaked logs, backups, and local data extraction.

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

## Cryptography
- Prefer CryptoKit and platform protocols; do not invent algorithms or wire formats.
- Define confidentiality, integrity, authenticity, key agreement, and password-derivation needs separately.
- Use authenticated encryption for confidential application data.
- Use cryptographically secure randomness and unique nonces as required by the algorithm.
- Design key generation, storage, rotation, versioning, backup, revocation, and loss recovery before encrypting durable data.
- Secure Enclave keys are useful only when their availability, algorithm, backup, and recovery constraints fit the product.

## App Attest And DeviceCheck
These are server-assisted risk signals, not local-only security features and not absolute jailbreak detection. App Attest requires server challenges and server-side attestation/assertion validation. Design unsupported-device fallback, retry, key loss, reinstall, environment separation, and gradual rollout.

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
- Physical-device verification for biometrics, Secure Enclave, locked-device behavior, passkeys, and App Attest where required.

## Primary Sources
- [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices)
- [Supporting passkeys](https://developer.apple.com/documentation/authenticationservices/supporting-passkeys)
- [LocalAuthentication](https://developer.apple.com/documentation/localauthentication)
- [Establishing app integrity with App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
- [Apple Platform Security](https://support.apple.com/guide/security/welcome/web)
- Provider OIDC metadata, OAuth specifications, and W3C WebAuthn for the adopted flow.
