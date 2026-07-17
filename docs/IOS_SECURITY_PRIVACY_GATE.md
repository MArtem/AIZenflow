# iOS Security And Privacy Gate

## Purpose
Mandatory review gate for secure storage, privacy, logging, permissions, and sensitive data handling in iOS apps.

For identity, OAuth/OIDC/PKCE, passkeys, Sign in with Apple, sessions, LocalAuthentication, cryptography, App Attest, and authorization design, also load `./docs/knowledge/global/ios/IDENTITY_AUTHENTICATION_AND_APP_SECURITY.md`.

## Required Checks
### Secrets And Tokens
- Apply `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md` before creating, importing, auditing, or remediating a project that may contain local secrets.
- Store tokens/secrets in Keychain or approved secure storage.
- Never store tokens in plain UserDefaults, logs, analytics, screenshots, or crash metadata.
- Define token refresh, logout, revocation, and expired-session behavior.
- Separate remote identity/authentication, local user-presence checks, authorization, and fraud signals.
- Do not treat client logic as an authoritative security boundary.

### Files And App Groups
- Review file protection class for persisted user data.
- Exclude caches/regenerable media from backups.
- App Group data must have clear ownership, cleanup, and access policy.
- Do not persist temporary picker/provider URLs as durable data.

### Privacy Manifests And Permissions
- Info.plist permission strings must match actual usage.
- Privacy manifests must reflect SDK/API usage.
- Permission denial paths must be user-friendly.

### Logging And Analytics
- Redact PII, tokens, private URLs, payload bodies, auth headers, and user-generated private content.
- Production logs must be actionable and bounded.
- Analytics events must avoid sensitive values.

### External Input
- Validate external URLs, shared files, deeplinks, universal links, pasteboard, documents, and imported media.
- Do not trust extension/app handoff payloads without validation.

### Data Lifecycle
- Define logout cleanup.
- Define account deletion/local data deletion behavior where relevant.
- Define retention for caches, media, drafts, and diagnostics.

## Blocking Findings
P0/P1 by default:
- secret/PII logging
- insecure token persistence
- unintended backup of sensitive data
- unvalidated external file/URL execution path
- missing permission/privacy explanation for shipped capability
- real secrets present in tracked files, normal AI-readable workspace files, or app bundle resources
