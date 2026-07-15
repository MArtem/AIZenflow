# Secret Handling And Security Intake Standard

## Purpose
Protect credentials, certificates, private keys, user data, and other sensitive material when humans and AI agents work on local projects.

This standard assumes a stronger rule than classic Git hygiene:

```text
Not committed to Git is required, but not sufficient.
Secrets must also stay out of AI-readable workspaces unless the user explicitly opens a security intake/remediation pass.
```

## Core Rules
- Do not paste secrets into chat.
- Do not store real secrets in Swift source, plist files, asset catalogs, tracked xcconfig files, checked-in scripts, documentation, examples, tests, fixtures, or generated reports.
- Do not store real secrets inside an iOS app bundle. Anything shipped in the app can be extracted by a user.
- `.gitignore` reduces commit risk, but it does not prevent an AI agent from reading files inside the workspace.
- Prefer storing real local secrets outside the project/worktree and outside the AI-readable root.
- The assistant may receive logical placeholder file names, environment variable names, build setting names, and expected configuration keys, but not secret values or accessible real paths to secret files.
- If a secret is exposed in chat, logs, committed history, or an AI-readable scan, treat it as compromised and rotate/revoke it.

## Sensitive Material Inventory
Treat these as sensitive by default:

- API keys, OpenAI/provider keys, backend tokens, webhook secrets, JWT secrets, OAuth client secrets;
- private keys: `.p8`, `.pem`, `.key`, `.rsa`, `.ed25519`, SSH private keys;
- Apple signing material: `.p12`, private signing certificates, App Store Connect API private keys, provisioning profiles when they expose team/app capability information;
- service account JSON, Firebase Admin/private service credentials, Google Cloud/AWS/Azure credentials;
- database URLs with credentials, production/staging connection strings;
- encryption keys, salt/pepper values, master keys, recovery keys;
- passwords, passphrases, personal tokens, session cookies;
- production crash/analytics DSNs when project policy treats them as confidential;
- private user data fixtures, screenshots, logs, traces, recordings, exports, and support bundles.

Some mobile configs may be public-ish, but must still be reviewed:

- public client IDs;
- URL schemes;
- non-secret API base URLs;
- Firebase mobile `GoogleService-Info.plist` without private server credentials;
- Sentry-style public client DSNs when the product accepts that exposure.

When uncertain, classify the value as sensitive until reviewed.

## Storage Policy
Preferred storage order:

1. System Keychain or approved secure local credential store.
2. Environment variables set outside the repository/worktree.
3. Local secret files outside the AI-readable project root, for example:

   ```text
   /Users/Artem/.zenflow-secrets/<ProjectName>/
     LocalSecrets.xcconfig
     signing/
     api/
   ```

4. CI/CD secret stores for remote automation.
5. Placeholder/example config files inside the repo.

Allowed in the repository:

- `*.example`, `*.template`, `*.sample`, and placeholder config files with fake values only;
- build setting keys without values;
- documentation that names environment variables, build settings, placeholder file names, or expected config keys without revealing values or accessible real secret paths.

Not allowed in the repository or AI-readable root:

- real `.env`, `*.local.xcconfig`, signing keys, service credentials, private plist files, production tokens, private logs/traces/exports.

## Git Ignore Baseline
Every project that may use local secrets must include an ignore policy equivalent to the reusable `gitignore.secrets.template`.

Minimum patterns:

```gitignore
# Local secret files
.env
.env.*
!.env.example
!.env.template
*.local
*.local.*
*.secret
*.secrets
*.secrets.*
Secrets/
secrets/
Private/
private/
Credentials/
credentials/

# Xcode local configuration
*.local.xcconfig
LocalSecrets.xcconfig
Secrets.xcconfig
Private.xcconfig
Config/Local*
Config/*Secrets*
Config/*Private*

# Apple signing / provisioning / private keys
*.p12
*.cer
*.mobileprovision
*.provisionprofile
AuthKey_*.p8
*.p8
*.pem
*.key
*.keystore

# Service account / cloud credentials
*ServiceAccount*.json
*service-account*.json
*google-services-private*.json
firebase-adminsdk*.json
aws-credentials*
gcloud-*.json

# Local sensitive diagnostics
*.trace
*.xcresult
*.crash
*.ips
*.log
Logs/
logs/
Diagnostics/
SupportBundles/
Exports/

# Local Xcode/user machine state
DerivedData/
.build/
.swiftpm/
xcuserdata/
*.xcuserstate
```

Project-specific `.gitignore` files may be stricter. They must not unignore real secrets.

## AI-Readable Workspace Policy
Before giving an AI agent a project:

1. Remove or move real secrets out of the workspace.
2. Confirm `.gitignore` covers common secret file names.
3. Add only fake examples/templates to the repo.
4. Tell the assistant logical placeholder file names, env var names, build setting names, or config keys only.
5. Do not ask the assistant to open external secret folders unless performing an explicitly approved security intake.

Do not give the assistant a full real path to a secret file if that path may be readable by the assistant. For normal work, say:

```text
The app expects LocalSecrets.xcconfig, but the real file lives outside your readable workspace.
Use build setting API_KEY; I will provide the value locally.
Use env var OPENAI_API_KEY; do not read or print its value.
```

Avoid:

```text
Read /Users/<name>/.zenflow-secrets/MyApp/LocalSecrets.xcconfig
```

The only exception is an explicitly approved security intake/remediation pass, where the user accepts that the assistant may see sensitive material once so it can be removed and rotated.

The recommended local secret root is outside project worktrees:

```text
/Users/Artem/.zenflow-secrets/<ProjectName>/
```

The assistant must not read this root during normal work. If a build needs values from that root, the user or local tooling should wire them into Xcode/build settings without exposing the values in chat or logs.

## Xcode And iOS Rules
- Do not put real secrets in `Info.plist`, entitlements, Swift files, asset catalogs, `.strings`, or app resources.
- Do not embed permanent server/API/provider secrets in the app bundle.
- Use build settings or placeholder config keys for non-secret configuration.
- Use Keychain for runtime tokens that must persist locally.
- Use a backend for secret-bearing provider access, including production OpenAI/cloud AI/API keys.
- Prefer Xcode automatic signing or local signing configuration that does not store private signing material inside the repository.

## Security Intake / Remediation Workflow
The user may explicitly ask for a security intake on a project that might still contain secrets. This is allowed only as a cleanup/remediation pass.

Workflow:

1. State that the scan may expose secrets to the assistant once.
2. Run scoped static checks such as:
   - `scripts/check_secrets.py` when available;
   - `rg` patterns for known secret formats and dangerous file extensions;
   - `git status --ignored --short` to find ignored but present sensitive files when relevant;
   - `git log`/history checks only when explicitly approved or necessary.
3. Report findings without printing secret values. Show file paths, key names, and redacted evidence only.
4. Tell the user what to move out, replace with placeholders, ignore, rotate, or revoke.
5. If a real secret was visible to the assistant, mark it as compromised and recommend rotation/revocation.
6. Re-run the scan after cleanup.
7. Record any accepted residual risk as an app-specific local exception, not a reusable rule.

During intake, the assistant must avoid copying secret values into:

- chat responses;
- docs;
- plans/handoffs;
- git commits;
- generated reports;
- logs.

Use redaction:

```text
OPENAI_API_KEY=<redacted:sk-proj...last4>
AuthKey_ABC123DEFG.p8=<redacted private key file present>
```

## Completion Criteria
A project passes the secret-handling gate only when:

- no real secrets are present in tracked files;
- no real secrets are present in normal AI-readable workspace files unless intentionally accepted for local-only development and documented as a temporary risk;
- `.gitignore` or equivalent covers project-specific secret paths;
- the assistant was given only logical placeholder names, env var names, build setting names, or config keys, not accessible real secret file paths;
- placeholder/example config exists for required keys;
- the assistant can build/review without reading secret values;
- exposed secrets from intake have been rotated/revoked or explicitly tracked as remaining risk.
