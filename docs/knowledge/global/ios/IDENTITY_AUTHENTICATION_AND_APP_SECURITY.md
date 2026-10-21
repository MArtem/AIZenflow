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

Distinguish backend-defined authentication recovery from access refusal: HTTP 401 concerns invalid
credentials; HTTP 403 is refusal to fulfill the request and may be unrelated to credentials.
Do not turn every 403 into token refresh or replay; preserve the actual API error contract.

## Native OAuth And Storage Failure Example
For public native OAuth clients, use an external user-agent and PKCE. RFC 9700 requires
public-client refresh tokens to be sender-constrained or use rotation; review that backend
contract instead of assuming a long-lived bearer refresh token is protected by local storage.
A client review grants no server/credential migration. Unsupported server guarantees remain
an explicit security gap with the responsible owner.

For example, refresh starts for account A, then the person logs into B. A late success for A
must not restore its credentials, queued requests or UI. A Keychain read failing because of
accessibility is not an absent item and must not trigger plaintext fallback. `ThisDeviceOnly`
prevents migration to another device; it is not a blanket statement that no same-device backup
restore is possible. Select the actual accessibility/access-control contract and current
permitted evidence, without opening the live store.
Primary theory: [RFC 8252](https://www.rfc-editor.org/rfc/rfc8252.html),
[RFC 9700 section 2.2.2](https://www.rfc-editor.org/rfc/rfc9700.html#section-2.2.2), and
[Restricting keychain item accessibility](https://developer.apple.com/documentation/security/restricting-keychain-item-accessibility).

## LocalAuthentication
Use LocalAuthentication to gate access or confirm user presence, not as the sole source of remote account identity. Choose whether passcode fallback is allowed. Handle unavailable, not enrolled, lockout, user cancel, system cancel, app cancel, and changed biometric enrollment.

Protecting a Keychain item with access control is stronger than evaluating biometrics and then reading an unprotected secret. Localized reason strings must explain the action without revealing sensitive data on the lock screen.

### Local Presence And Lost-Key Failure Trace
A successful policy evaluation applies to that request, not every later action. Cancellation,
lockout or enrollment changes may invalidate the next attempt. The completion callback has
an unspecified private threading context; transfer state to its actual owner and do not call
canEvaluatePolicy from inside that callback. Choose passcode fallback deliberately rather
than silently weakening a biometric-only policy.

For example, a protected Keychain item using biometryCurrentSet becomes unavailable after
biometric enrollment changes. Treat that as access/key recovery under the account policy,
not proof of account deletion and not a reason to save the secret unprotected. A standalone
presence prompt is an alternative only when the protected operation does not require an
access-controlled secret. A local success still cannot authorize a remote entity operation.
Primary theory: [Policy evaluation](https://developer.apple.com/documentation/localauthentication/lacontext/evaluatepolicy(_:localizedreason:reply:))
and [Current biometric-set access control](https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/biometrycurrentset).
No biometric prompt or Keychain operation was performed.

## Keychain And Data Protection

Define the credential item identity, including the applicable account/service and access-group
contract, and the intended add/update/delete behavior for that exact item. Distinguish missing,
duplicate, unavailable and failed storage outcomes as the actual operation requires. A Keychain
failure must not silently fall back to plaintext preferences or files; preserve the
credential/access policy and report failure without exposing the secret.

- Choose accessibility class from the required background/locked-device behavior.
- Use `ThisDeviceOnly` when migration to another device would violate the security model.
  Specify backup retention and same-device restoration separately; this class alone is not a no-backup policy.
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

## Key Rotation And Authentication Failure Example
Use a fresh nonce for each encryption operation as required by the authenticated cipher;
changing a filename or retrying a write does not make reuse safe. Bind the key/version and
associated-data contract to the stored ciphertext. On authentication/decryption failure,
preserve recoverable data and report the failure; do not silently accept unauthenticated
plaintext or overwrite the only old ciphertext with an empty replacement.

For example, rotating a key while old records still reference its predecessor can make valid
user data unreadable. Define coexistence, migration progress, interruption recovery, backup
and retirement criteria before deleting the old key. If the real need is storing a credential,
Keychain may satisfy it without a custom encrypted database. This is a design alternative and
failure trace, not key access, cryptographic execution or proof of an app's security.
Primary theory: [AES.GCM.Nonce](https://developer.apple.com/documentation/cryptokit/aes/gcm/nonce)
and [authenticated sealing](https://developer.apple.com/documentation/cryptokit/aes/gcm/seal(_:using:nonce:authenticating:)).

## App Attest And DeviceCheck
These are server-assisted risk signals, not local-only security features and not absolute jailbreak detection. App Attest requires server challenges and server-side attestation/assertion validation. Design unsupported-device fallback, retry, key loss, reinstall, environment separation, and gradual rollout.

Bind attestation/assertion validation to the server challenge and replay policy, key lifecycle
and actual failure/fallback/anti-abuse limits. A validated app-integrity signal is not user
authorization; unavailable attestation must not silently become equivalent successful evidence.

Do not add App Attest to a backend-less app and claim security benefit; document it as unavailable until the server boundary exists.

### Attestation Replay And Recovery Trace
App Attest needs server-owned one-time challenges and validation bound to the actual request,
app/environment, key and assertion history. Neither a valid app instance nor a local Boolean
establishes account permission. Keys survive normal updates but not reinstall, migration or
backup restoration; keep recovery distinct from a new account.

For example, reinstall removes the attestation key while a server still knows its old public
key. Reestablish the app/device binding through the approved recovery policy; do not accept an
old signed request as a fresh challenge response. An unsupported-device fallback is an explicit
server risk policy, not fabricated successful attestation. A transient service failure and a
lost/invalid key require different retry/re-enrollment decisions. Apps without the necessary
server boundary retain ordinary authentication/authorization and make no attestation claim.
Primary theory: [App integrity and key lifecycle](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
and [Server validation and replay protection](https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server).
This is a conceptual recovery trace; no key generation, challenge or server call was executed.

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
- [HTTP 401/403 semantics: RFC 9110 sections 15.5.2 and 15.5.4](https://www.rfc-editor.org/rfc/rfc9110.html#name-401-unauthorized)
- [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices)
- [Supporting passkeys](https://developer.apple.com/documentation/authenticationservices/supporting-passkeys)
- [LocalAuthentication](https://developer.apple.com/documentation/localauthentication)
- [Establishing app integrity with App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
- [Apple Platform Security](https://support.apple.com/guide/security/welcome/web)
- Provider OIDC metadata, OAuth specifications, and W3C WebAuthn for the adopted flow.
