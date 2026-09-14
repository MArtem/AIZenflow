# Adaptive Risk Model

V4 produces **risk leads**, not defect findings.

High-signal boundaries include:
- persisted schema / migrations / destructive stores;
- authentication/session/token refresh;
- payments/StoreKit/entitlements;
- strict concurrency escapes (`@unchecked Sendable`, `nonisolated(unsafe)`, detached tasks);
- extensions/background execution;
- public SDK/API surfaces;
- secrets/privacy manifests/permissions;
- CI/signing/release automation;
- large cross-module ownership surfaces.

Each lead contains severity, confidence, evidence and the matching audit skill. Severity is about potential blast radius; it does not assert a bug exists.
