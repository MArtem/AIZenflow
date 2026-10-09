# App Store, Privacy, And Compliance

## Load When
Use for App Store submission, TestFlight, privacy manifests, required-reason APIs, privacy labels, tracking, subscriptions, encryption/export compliance, age/kids requirements, account deletion, SDK review, or regional distribution.

## Living Requirements
App Review, privacy, entitlement, SDK, and regional distribution requirements change independently of application code. Re-check primary sources for every release and whenever Xcode/App Store Connect reports a new issue. Do not treat this document as a frozen legal interpretation.

## Submission Contract
Inventory app and extension bundle IDs, versions/builds, supported devices, entitlements, capabilities, associated domains, URL schemes, background modes, permission strings, privacy manifests, third-party SDKs, StoreKit products, account/demo access, review notes, export compliance, and regional availability.

Archive success is necessary but not sufficient. Validate the exported/distributed artifact, embedded frameworks, dSYMs, symbols, privacy files, signing, provisioning, and production service configuration.

## Release Candidate Trace
Define the product version/build-number policy and candidate source/artifact identity, release
branch scope and migration compatibility; library SemVer is not an automatic product-version rule.
Record certificate/profile ownership, signing strategy and expiry/renewal handling as declared
metadata. Reviewing that metadata does not authorize reading keys, credential rotation, signing,
archive/upload or machine changes.

User-facing release notes and internal risk/migration/experiment/support notes describe the actual
candidate delta; neither an assumed branch list nor a green check on another configuration proves
this candidate. Keep TestFlight groups/staged validation, feedback/crash metrics and containment
scoped to the approved delivery plan, with no automatic shipping.

## Privacy Manifest And Required-Reason APIs
- Every app and relevant SDK manifest must be valid and included in the correct bundle.
- Declared collected-data categories must match actual app/SDK behavior and App Store privacy answers.
- Required-reason APIs need an allowed reason that accurately describes use.
- Wrapper packages do not remove the app's responsibility to review use and declarations.
- Re-run archive privacy reports when dependencies or API usage changes.
- Do not declare broad data collection or reasons merely to silence a warning.

## Privacy Labels And Data Lifecycle
Map each collected data type to purpose, linkage, tracking status, source, destination, processor, retention, deletion, and consent/legal basis where applicable. Include analytics, crash reports, support tools, advertising, authentication providers, cloud sync, and SDK behavior.

The in-app privacy policy, permission prompts, settings, account deletion, export, and App Store answers must describe the same system.

## Tracking And Attribution
Apply App Tracking Transparency when the behavior meets Apple's tracking definition. Do not fingerprint, reconstruct profiles, or gate unrelated functionality on tracking permission. Review SDK data use and server-side sharing; absence of an advertising UI does not prove tracking is absent.

## Accounts And User Content
- Apps offering account creation generally need an accessible account-deletion path and complete backend/local deletion behavior.
- Define moderation, reporting, blocking, abuse response, and age/safety requirements for user-generated content.
- Provide accurate reviewer access or a documented no-login path.
- Sign in options must comply with current App Review rules, including Sign in with Apple where applicable.

## StoreKit
- Products, pricing, localization, subscription terms, restore/manage-subscription paths, and reviewer notes must match App Store Connect.
- Entitlement is derived from verified transaction state, not a successful purchase callback alone.
- Handle pending, revoked, refunded, expired, upgraded/downgraded, family/group, billing retry, and offline states.
- Server notifications and validation require an approved backend boundary; do not embed server credentials in the app.

Trace transaction updates through the single entitlement owner, persistence/server sync and
every access consumer. Reconcile duplicate updates, offline periods, interrupted purchases,
relaunch and account changes; optimistic UI must not become permanent access. Review product/
configuration identity and listener lifetime at startup and relaunch. Product display or a completed
animation does not prove verification or consumer agreement.

Select current-entitlement and unfinished-transaction reconciliation for the actual product type;
`currentEntitlements` does not include consumables. Handle unverified results explicitly and keep
restore/subscription transitions consistent with the approved product/server contract. This review
does not authorize purchases, StoreKit test sessions, account/network/configuration or release actions.

## Encryption And Export
Inventory encryption use, including platform networking, custom cryptography, VPN/security features, and third-party SDKs. Answer export-compliance questions from the actual binary and distribution regions. Escalate legal ambiguity to the responsible owner; do not guess exemption status.

## Kids, Health, Finance, Location, And Regulated Data
Sensitive categories require stricter minimization, consent, age/guardian, disclosure, retention, and claim review. Platform API permission does not establish legal permission or medical/financial correctness. Record responsible product/legal owners when required.

## SDK And Supply-Chain Review
For each SDK, review purpose, data behavior, privacy manifest/signature requirements, required-reason APIs, network endpoints, permissions, tracking, license, maintenance, minimum OS, and removal path. Remove unused SDKs and capabilities.

## Release Evidence
- Current App Review Guidelines reviewed for affected sections.
- Archive/export and distributed build smoke check.
- Privacy report/manifests, required reasons, nutrition labels, privacy policy, permission strings, and runtime behavior reconciled.
- Account deletion/export and data-retention paths exercised where offered.
- StoreKit sandbox/TestFlight and production configuration reviewed where used.
- Reviewer notes, demo credentials, backend availability, and contact paths ready.
- dSYMs, crash symbolication, staged rollout, monitoring, rollback, and support plan ready.

## Primary Sources And Mandatory Review Triggers
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [StoreKit](https://developer.apple.com/documentation/storekit)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes)

Review before every release and after App Review, privacy, SDK, entitlement, StoreKit, export, or regional-distribution changes.
