---
name: ios-app-store-compliance
description: Use for App Store or TestFlight compliance involving App Review Guidelines, privacy manifests, required-reason APIs, privacy labels, tracking, account deletion, StoreKit disclosure, encryption/export compliance, SDK signatures, reviewer access, or regional distribution.
---

# iOS App Store Compliance

## Required Context
Read:

- `./docs/IOS_RELEASE_CHECKLIST.md`
- `./docs/IOS_SECURITY_PRIVACY_GATE.md`
- `./docs/knowledge/global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md`
- current official Apple requirements for affected sections

## Workflow
1. Inventory the actual app/extensions, SDKs, capabilities, data flows, commerce, accounts, content, and distribution regions.
2. Re-check current App Review, privacy, required-reason API, SDK, entitlement, and App Store Connect requirements.
3. Reconcile runtime behavior, privacy manifests, privacy labels, policy text, permission prompts, and account deletion/export.
4. Identify legal/product/security owner decisions that cannot be inferred from code.
5. Separate archive, TestFlight, sandbox-service, App Review, and production evidence.
6. Produce a blocking/non-blocking submission checklist with source dates.

## Guardrails
- Do not guess legal, export, age, health, finance, or regional obligations.
- Do not add declarations merely to silence validation.
- Do not infer SDK behavior from marketing text; inspect manifests, network/data behavior, and current vendor docs.
- Never claim App Store acceptance before review.

## Output
Report current sources checked, declarations and runtime reconciliation, blockers, responsible external decisions, evidence, and remaining submission risk.
