# App Store, Privacy, And Compliance

## Load When
Use for App Store submission, TestFlight, privacy manifests, required-reason APIs, privacy labels, tracking, subscriptions, encryption/export compliance, age/kids requirements, account deletion, SDK review, or regional distribution.

## Living Requirements
App Review, privacy, entitlement, SDK, and regional distribution requirements change independently of application code. Re-check primary sources for every release and whenever Xcode/App Store Connect reports a new issue. Do not treat this document as a frozen legal interpretation.

## Submission Contract
Inventory app and extension bundle IDs, versions/builds, supported devices, entitlements, capabilities, associated domains, URL schemes, background modes, permission strings, privacy manifests, third-party SDKs, StoreKit products, account/demo access, review notes, export compliance, and regional availability.

Archive success is necessary but not sufficient. Validate the exported/distributed artifact, embedded frameworks, dSYMs, symbols, privacy files, signing, provisioning, and production service configuration.

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
