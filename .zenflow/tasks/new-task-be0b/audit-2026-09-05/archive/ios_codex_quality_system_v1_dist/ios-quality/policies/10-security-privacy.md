# 10 — Security and Privacy

## Baseline

Use Apple platform security guidance plus OWASP MASVS as the security-control baseline. Security rules are threat-based; do not add exotic controls with no threat model, but never weaken platform defaults casually.

## Secrets

MUST NOT commit:

- API secrets/private keys;
- access/refresh tokens;
- production credentials;
- signing certificates/passwords;
- personal developer machine secrets.

Client apps cannot safely protect a long-term server secret embedded in the binary. Redesign such protocols rather than obfuscating a secret and calling it secure.

## Storage

- Use Keychain for credential-like secrets.
- Consider Secure Enclave for supported private-key operations when threat model requires hardware-backed protection.
- Avoid sensitive values in UserDefaults/plain logs/cache unless explicitly acceptable.
- Apply appropriate file protection for sensitive files.

## Network

- Preserve ATS defaults.
- No blanket `NSAllowsArbitraryLoads` without explicit approval and documented endpoint need.
- Do not implement custom TLS trust acceptance that accepts invalid certificates.

## Authentication/session

MUST define:

- token lifetime/refresh behavior;
- logout/revocation behavior;
- storage/accessibility class;
- concurrent refresh handling;
- error paths when credentials expire;
- separation of authentication vs authorization.

## Authorization

Never assume a UI-hidden action is authorized. Server authorization remains authoritative for remote resources.

## Logging/privacy

Use unified logging and privacy annotations. Tokens, passwords, precise personal identifiers, health/financial content, and other sensitive payloads MUST NOT be emitted in plaintext logs.

## Privacy manifests

Changes that add required-reason APIs or data collection must review `PrivacyInfo.xcprivacy` and App Store privacy declarations. Third-party SDK privacy manifests do not remove the app’s responsibility for its own APIs/data use.

## Permissions

- Request only capabilities/permissions required for user-visible functionality.
- Purpose strings must accurately explain use and be localized when the product localizes.
- Do not request permissions prematurely without a user-understandable reason.

## URL/deep-link input

Treat external URLs, universal links, clipboard/pasteboard, files and inter-app input as untrusted. Validate scheme/host/path/parameters and authorization state before navigation/action.

## Web views

WebView changes are R3+ when they execute remote content, bridge JavaScript/native code, handle auth, or expose file/custom schemes. Minimize bridge surface and validate messages.

## Cryptography

Do not invent cryptographic algorithms/protocols. Prefer platform CryptoKit/Security primitives and standard protocols.

## Dependency supply chain

Every new dependency is code entering the app and requires dependency gate review: maintainer/repository, license, source vs binary, release activity, privacy manifest/signature requirements, transitive dependencies, and necessity.
