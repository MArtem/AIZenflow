# Universal iOS Engineering Quality Standard

<!-- Rule ID: QC.SWIFT.CONCURRENCY_FLOOR v1.0 -->

## Status and authority

**Version:** 1.0<br>
**Reviewed:** 2026-09-05<br>
**Scope:** production iPhone and iPad applications, frameworks, widgets, and app extensions.

This is the app-neutral quality contract for every current and future iOS codebase. It is a
joining contract, not a second copy of every specialist rule: the linked standards define the
details, while this document defines the minimum bar, decision order, evidence, and release
meaning that apply to every project. An app may strengthen a rule in its own contract, but may
not silently weaken this baseline.

Technical claims follow this authority order: Apple Developer Documentation, Human Interface
Guidelines, App Review Guidelines, Apple Platform Security and WWDC material; the Swift language
reference, standard library documentation, Swift Evolution, and official Swift migration guides;
normative protocol standards such as RFC, W3C, Unicode, and WCAG; then documentation of an
adopted dependency. A secondary source can explain a rule, but cannot be the only authority for a
security, compatibility, privacy, or release decision.

The source review date is not a claim that every example was executed. Re-review this standard
and the affected specialist document after a major Xcode/Swift/iOS release, a beta adoption, an
App Review/privacy/signing change, a compiler diagnostic or deprecation, a security advisory, a
production incident, or an official source move.

## Universal change contract

Before implementation, every non-trivial change records:

1. user-visible behavior and non-goals;
2. owning layer, state owner, producer/consumer contract, and authority boundary;
3. input, memory, storage, network, time, and resource envelopes;
4. ordering, cancellation, retry, migration, and failure semantics;
5. affected targets, extensions, platforms, locales, permissions, and release surfaces;
6. verification required for the claim, including what is intentionally not run.

The contract is reviewed against the complete final diff and all credible false-success or
irreversible-state paths. A passing build, test, linter, or static scan is supporting evidence,
not a substitute for semantic review.

## Quality gates

All applicable gates below are required. A gate is either evidenced, explicitly not applicable with
an owner and reason, or blocked; an unmentioned gate is not a pass.

### 1. Product and architecture

- Product invariants, acceptance criteria, non-goals, and destructive-action confirmation are
  explicit before coding.
- Dependencies point one way: UI → feature/domain → infrastructure; reusable mechanics remain
  app-neutral and product policy remains in the app/feature layer.
- There is one source of truth for each state concept. ViewModels expose explicit intent methods;
  generic action dispatch is used only when a documented reducer/state-machine contract requires
  it.
- DTOs, domain models, and UI models are separated at real boundaries. Identity is stable;
  invalid domain states are rejected at construction or mapping boundaries.
- New protocols, factories, managers, wrappers, or packages require a concrete seam, ownership,
  or measured problem. No decorative abstraction or hidden singleton dependency is accepted.
- Every target and extension has an owner, declared inputs/outputs, and a dependency direction.

### 2. Swift language and concurrency

- New and migrated targets use the selected Swift language mode with strict concurrency diagnostics
  enabled at the strongest level supported by the deployment/toolchain contract.
- Shared mutable state has a real owner: an actor, an isolated value, or a checked synchronization
  primitive with a documented lock/queue owner. Sendability is proven by value semantics or a real
  ownership boundary.
- `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, warning suppression, and
  cosmetic `@MainActor` annotations are not migration strategies. A boundary must explain who may
  access state, when, and why the compiler can verify it.
- Main-actor code is limited to UI state and APIs that actually require it. File I/O, decoding,
  image/video/PDF work, hashing, compression/encryption, database work, large transforms, and
  network orchestration run outside the main actor with cancellation and stale-result protection.
- Tasks have bounded lifetime, cancellation, ownership, and result ordering. Detached work captures
  only Sendable values and returns values rather than sharing mutable objects.

### 3. UI, rendering, accessibility, and localization

- `body`, layout callbacks, row builders, gestures, animations, and scroll callbacks are cheap,
  deterministic, and side-effect free. No synchronous I/O, network, persistence, media decoding,
  or large collection transform occurs in a render path.
- Lists/grids use stable identity, lazy containers where appropriate, bounded pagination and
  backpressure, cancellable media loading, and stable placeholders. One item update does not
  invalidate an unrelated collection without a documented reason.
- Layout adapts to Dynamic Type, iPhone/iPad size classes, orientation, multitasking, keyboard,
  pointer, right-to-left text, safe areas, and long localized strings. System accessibility
  features are not treated as optional polish: VoiceOver, Assistive Access, Reduce Motion,
  contrast, captions, and sufficiently large controls are part of acceptance evidence.
- Color, shape, sound, and motion never carry the only meaning. Destructive and irreversible flows
  have explicit confirmation and recoverability.

### 4. Data, persistence, media, and caches

- Source-of-truth data, user-owned files, temporary files, and regenerable caches are distinct.
  User data survives relaunch and offline use where the product promises it; cache eviction cannot
  delete the source of truth.
- File/provider URLs are copied into app-owned durable storage before the provider scope expires.
  Schema and Codable changes have backward-compatibility, migration, rollback, and partial-failure
  behavior. No migration silently discards data.
- Reads and writes are scoped and bounded. Large payloads are streamed or processed off-main;
  images are downsampled, previews are cancellable and cacheable, and temporary artifacts have a
  cleanup policy.
- Persistence errors preserve recoverable user work and surface an actionable state rather than
  reporting false success.

### 5. Network, API, and synchronization

- Request contracts define authentication, timeout, cancellation, retry/backoff, idempotency,
  pagination, validation errors, rate limits, and observability. Backend DTOs do not leak into UI.
- Offline, poor connectivity, expiration, partial success, duplicate submission, server conflict,
  and app termination behavior are intentional. Local data remains visible when a network refresh
  fails unless product policy says otherwise.
- Background transfers and refresh are scheduled using system facilities and energy constraints;
  polling and retries are bounded. Tokens, credentials, PII, private URLs, and full payloads are
  redacted from logs by default.

### 6. Security, privacy, and platform capabilities

- Threat model data flows, trust boundaries, secrets, authentication/session lifecycle, keychain
  access, local protection, and authorization before implementation. Secrets never enter source,
  logs, fixtures, or crash metadata.
- Every permission, entitlement, App Group, URL scheme, extension, background mode, and required-
  reason API has a declared owner, least-privilege purpose, availability/fallback behavior, and
  privacy-manifest/App Store review evidence.
- Imported files, URLs, share extension input, deep links, web content, and external providers are
  treated as hostile or unavailable until validated. Security-sensitive failure is fail-closed;
  user-visible errors do not reveal secrets or internal topology.

### 7. Build graph, dependencies, and supply chain

- The authoritative project/workspace, schemes, targets, configurations, source membership, and
  generated outputs are versioned and reviewable. Debug and Release settings are compared; release
  builds use the exact signing, entitlements, privacy, and optimization inputs intended for users.
- Dependencies are minimal, pinned to immutable revisions, reviewed for license/security/runtime
  impact, and represented by a committed lockfile. Binary artifacts have provenance, architecture,
  symbol, and update/rollback evidence.
- Generated files have a reproducible owner and hash. Build products, archives, credentials, and
  caches are excluded from source; temporary build output stays in the task-approved sandbox.
- New first-party warnings, strict concurrency diagnostics, forbidden hot-path patterns, format,
  lint, resource, localization, privacy-manifest, secret, and dependency checks block merge when
  the applicable machine gate reports failure.

### 8. Testing, diagnostics, performance, and operations

- Verification is layered: deterministic static checks; unit/component tests for invariants;
  integration tests for persistence/network/auth boundaries; UI/accessibility tests for critical
  flows; representative simulator/device tests; release-build install/update tests; and measured
  performance/energy/memory checks for declared budgets.
- Tests are deterministic, isolated, cancellation-aware, and cover failure/empty/loading/offline/
  migration/relaunch paths. Disabled or skipped coverage is an explicit owner decision, never an
  invisible pass. Test modifications and execution remain separately authorized.
- Logs and metrics are structured, privacy-safe, bounded, and correlated to user-visible failure.
  Crash diagnostics retain symbolication and build identity. SLOs, rollout guardrails, feature-flag
  kill switches, incident response, rollback, and data-repair procedures exist for production risk.

### 9. Release and evidence

- A release candidate is tested as a Release/archive-equivalent build on representative devices,
  including fresh install, upgrade, relaunch, interrupted network, low storage/memory, and supported
  locale/accessibility paths.
- App Store metadata, privacy answers/manifests, required-reason API declarations, signing,
  entitlements, export compliance, support URL, account deletion, and review notes match shipped
  behavior.
- Each completion claim identifies source revision, toolchain/SDK, profile, commands, target/scheme,
  evidence artifacts, reviewer, omitted checks, and residual risk. `PASS` never means “not run”,
  “blocked”, or “assumed from Simulator”.

## Minimum machine enforcement

The app-neutral QualityControl engine is the executable companion to this standard. Adopting
projects should enable the applicable catalog entries, while keeping compiler, Xcode, runtime,
and human review evidence separate:

- `QC.STATIC.SWIFT_HOT_PATH` blocks only high-confidence synchronous file/data, image-file, PDF
  URL, and blocking `copyCGImage` operations in shipped Swift source. It does not prohibit the
  legitimate asynchronous `AVAssetImageGenerator.image(at:)` API and does not claim actor or
  runtime correctness.
- `QC.STATIC.SWIFT_CONCURRENCY_ESCAPE` blocks `@unchecked Sendable`, `nonisolated(unsafe)`,
  `@preconcurrency`, and `@_unsafeInheritExecutor`; the compiler must verify the replacement
  ownership boundary.
- Secret, dependency-lock, generated-ownership, localization, resource, privacy-manifest,
  configuration/signing, disabled-test, format, lint, build-membership, warning, and compiler
  diagnostics gates remain distinct claims. A missing or staged adapter is `BLOCKED`, not a pass.

No project may make the machine controls less strict by adding a suppression list, excluding a
real shipped target, or treating a review-candidate signal as proof of safety. If a legitimate
platform exception is required, record it in the app/task exception ADR and preserve independent
compiler/runtime/release evidence.

## Severity and exception policy

- **P0:** data loss, credential exposure, unsafe release/signing, security bypass, false evidence,
  or a crash/blocker on a promised critical path. Stop immediately.
- **P1:** correctness, concurrency, privacy, migration, release, or major accessibility defect.
  Blocks merge and release.
- **P2:** material performance, maintainability, observability, compatibility, or UX defect.
  Blocks the affected claim until fixed or explicitly accepted by the owning authority.
- **P3:** bounded polish or documentation gap. Fix before completion or record owner and expiry.

An exception is a short app/task ADR with scope, reason, alternatives rejected, risk, owner,
expiry/removal condition, and compensating evidence. Exceptions cannot authorize forbidden Swift
concurrency escapes, hide a failed gate, or claim an unsupported platform.

## Authoritative references

- Swift 6 migration and concurrency: <https://developer.apple.com/documentation/Swift/AdoptingSwift6>,
  <https://developer.apple.com/documentation/swift/concurrency>,
  <https://developer.apple.com/documentation/Swift/Sendable>
- Human Interface Guidelines, accessibility, layout, and motion:
  <https://developer.apple.com/design/human-interface-guidelines>,
  <https://developer.apple.com/design/human-interface-guidelines/accessibility>,
  <https://developer.apple.com/design/human-interface-guidelines/layout>,
  <https://developer.apple.com/design/human-interface-guidelines/motion>
- Xcode build system, schemes, and release-build testing:
  <https://developer.apple.com/documentation/xcode/build-system>,
  <https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project>,
  <https://developer.apple.com/documentation/Xcode/testing-a-release-build>
- URLSession and energy-aware networking:
  <https://developer.apple.com/documentation/foundation/urlsession>,
  <https://developer.apple.com/documentation/xcode/reducing-networking-and-bluetooth-power-usage>
- Privacy manifests and required-reason APIs:
  <https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk>,
  <https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest>
- App Review and distribution: <https://developer.apple.com/app-store/review/guidelines/>

## Routed implementation documents

Use this contract first, then load only the specialist route needed by the change. The active
router and coverage registry are the discovery authority. The production readiness, evidence,
static-gate, release, security, accessibility, concurrency, data, network, and testing documents
remain the detailed operating sources; this standard prevents a narrow project example from being
mistaken for a universal quality bar.
