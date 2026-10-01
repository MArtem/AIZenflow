# Security and privacy review — curated copy-only route

Use after project-local security rules when a change handles sensitive data, external input,
permissions, storage, network trust, logging, analytics, SDKs or deletion. This route curates
`IOS-12-01` through `IOS-12-12` as review criteria only; their historical prompts are outside
the active payload. It does not authorize credential, auth, Keychain or host-system changes.

- Identify protected assets, attacker-controlled inputs, trust boundaries, abuse cases and the
  actual authority for decisions. Client-side validation is not a server authorization boundary.
- Trace sensitive values through creation, transit, storage, app-group sharing, backups,
  diagnostics, analytics, crash reports, screenshots and deletion. Check minimization, access,
  retention and redaction at each relevant hop; do not expose secret values in review output.
- For files, URLs, deep links, pasteboard and extension handoffs, inspect validation before use
  and failure behavior. For network trust or WebView changes, inspect actual trust/navigation
  policy; do not weaken platform defaults to make a failing path succeed.
  Trace scheme/host/path/parameter validation, redirects and replay through authorization at
  consumption. For WebViews, include JS bridge inputs/content-world boundaries, file access,
  downloads and cookie/session isolation; an allowlisted initial URL is not the entire flow.
- Check affected permissions, entitlements, privacy manifests and third-party data collection
  against the shipping app/SDK and current authoritative requirements when release claims matter.
  Static project files alone do not establish App Store compliance.
- For analytics or crash SDKs, trace event/schema ownership, consent before collection, user
  identity reset, batching/retry retention, PII redaction and debug versus production routing.
  A wrapper or privacy manifest alone does not prove that collection is consent-gated.
- For permission-dependent flows, inspect minimum scope, request timing/rationale, denied and
  restricted states and recovery UX. An entitlement or prior approval does not prove current access.
- For attestation or cryptographic contracts, inspect server-challenge/replay handling, key
  lifecycle, failure/fallback and anti-abuse limits; attestation is not user authorization.
  Review standard primitive/protocol choice, key management and nonce/randomness assumptions;
  do not invent crypto or treat encryption at rest as proof of end-to-end security.
- Separate authentication, authorization, local user presence and credential storage in a review.
  If a fix would change any of those, stop at a finding unless the user separately authorizes
  that exact work. Never infer permission from `reference ON`.
- When authorized source review includes an app's secure-storage contract, inspect its data
  protection/accessibility class, access groups, locked-device behavior, migration, deletion,
  user-presence requirements and errors. An unavailable or failed read is not proof that a
  credential is absent. Review source/configuration without opening a live secret store.
- For an affected transport-security contract, inspect ATS exceptions and TLS/trust decisions,
  their scope, failure path and certificate/pin rotation or recovery assumptions. Do not
  introduce pinning by default or bypass trust failures; use the project's actual threat and
  backend contracts to assess the existing policy.
  For an authorized security migration, assess compatibility/revocation and containment before
  retiring an old path; this question does not authorize credential rotation or an insecure fallback.

Classify concrete leaks, unsafe input paths and insecure persistence by severity; unresolved
blocking findings prevent a readiness claim. Select synthetic-data, negative-path and runtime
checks only when authorized. Report what was inspected, what was observed, and what remains
unverified without copying credentials or personal data into task notes.

## Second-layer adversarial pass

After the active knowledge-base security gate and its task prompt produce a provisional result,
check the *evidence*, not a second copy of the same checklist. For each material finding, test
whether the entry point is reachable in the shipping configuration, the attacker controls the
claimed input, the named guard can actually be bypassed, and the impact follows from the shown
code path. Conversely, look for one missed cross-component path through extensions, shared
storage, callbacks, redirects or diagnostics. Merge duplicate symptoms of one root cause.
Downgrade unsupported severity and mark an unverified premise `UNKNOWN`, never `PASS`.

`ON/AUTO` may perform this read-only reasoning inside the already authorized review; `ADVISORY`
explains when a deeper scan, secret intake, runtime test, agent review or external source check
would change confidence, and requests any permission those actions need. Neither mode may open
secret stores, run tools with side effects or mutate code merely because this route was loaded.
