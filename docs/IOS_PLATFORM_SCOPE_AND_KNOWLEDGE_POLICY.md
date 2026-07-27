# iOS Platform Scope And Knowledge Policy

## Purpose
Define the mandatory platform scope, authority model, completeness criteria, and freshness rules for the reusable iOS engineering library.

This policy governs documentation coverage. It does not select product features, deployment targets, or supported devices for a specific app.

## Mandatory Core Scope
The reusable core must support production engineering for:

- iPhone applications;
- iPad applications, including adaptive layout, multitasking, multiple scenes and windows, keyboard, pointer, drag and drop, and document workflows when relevant;
- shared iOS and iPadOS frameworks, app extensions, distribution, privacy, accessibility, localization, testing, diagnostics, and operations;
- current Swift, Xcode, iOS, and iPadOS behavior needed to reason safely about the code being changed.

An iPhone-only implementation must not be treated as complete when the product supports iPad. Compact and regular size classes are evidence inputs, not substitutes for testing representative iPhone and iPad configurations.

## Deferred Apple Platforms
watchOS, visionOS, tvOS, and macOS-specific implementation guidance is not part of the mandatory reusable core at this time.

Load or create platform-specific guidance only when one of these triggers is present:

- the user explicitly requests that platform;
- a target, package, entitlement, extension, shared API, or deployment requirement includes it;
- a cross-platform decision would otherwise create a compatibility or public-API risk;
- an iPhone or iPad feature depends on companion-platform behavior.

Do not infer support for a deferred platform from a reusable package name, a SwiftUI API being multi-platform, or an Apple sample covering several platforms. Record the platform as out of scope until the trigger is explicit.

## Coverage Unit
A topic is fully covered only when the library provides the smallest sufficient chain below:

1. **Primary theory:** a current first-party specification, platform document, or standards source.
2. **Deep reference:** mental model, boundaries, alternatives, failure modes, and examples.
3. **Operating rule:** concise requirements that affect implementation or review.
4. **Route:** a task condition that makes the material discoverable without loading the whole library.
5. **Execution aid:** a prompt or skill when repeated task-specific procedure benefits from one.
6. **Evidence:** build, test, static, runtime, device, release, or manual proof appropriate to the claim.

Not every topic needs a dedicated file or skill. A short topic may share a deep reference and route. A heading, keyword, package catalog entry, or placeholder is not full coverage.

## Maturity Levels
- `missing`: no reliable reusable guidance.
- `outline`: headings or reminders exist, but the topic cannot safely guide implementation.
- `operational`: enforceable rules and evidence expectations exist, but theory or examples remain shallow.
- `complete`: the coverage unit is satisfied for the mandatory core.
- `deferred`: intentionally outside the mandatory core and loaded only by an explicit trigger.

The machine-readable source for topic maturity is `./docs/IOS_KNOWLEDGE_COVERAGE_REGISTRY.json`.

## Source Authority
Use the following order for technical claims:

1. Apple Developer Documentation, release notes, Human Interface Guidelines, App Review Guidelines, Apple Platform Security, and WWDC sessions.
2. The Swift language reference, Swift standard-library documentation, Swift Evolution proposals, and official Swift migration guides.
3. Normative standards used by the platform or protocol, such as RFCs, W3C WebAuthn, Unicode, WCAG, and applicable security standards.
4. Official documentation for an adopted dependency.
5. Secondary material only for explanation, never as the sole authority for a safety, security, compatibility, or release claim.

When primary sources disagree with a local document, stop and classify whether the local document is stale, describes an older deployment target, or records an intentional project exception.

## Version And Availability Discipline
- Distinguish Xcode version, compiler version, Swift language mode, SDK version, and minimum deployment target.
- Beta behavior must be labelled beta and must not silently become the baseline for a stable toolchain.
- Guard APIs with availability checks where deployment targets require it.
- Do not assume Simulator behavior proves physical-device behavior.
- Do not assume an API is usable merely because it appears in an SDK; verify entitlements, account configuration, region, hardware, privacy declarations, and distribution constraints.
- Preserve older-runtime behavior deliberately when adopting a new API.

## Freshness Contract
Review affected knowledge when any of these events occurs:

- a major Xcode, Swift, iOS, or iPadOS release or beta adoption;
- WWDC introduces or materially changes a covered framework;
- App Review, privacy manifest, required-reason API, entitlement, signing, or distribution requirements change;
- a compiler diagnostic or SDK deprecation contradicts current guidance;
- a production incident, rejected submission, security advisory, or migration reveals a missing rule;
- an official source linked by the library moves or becomes obsolete.

The review must update the coverage registry's verification date or leave the topic explicitly stale. A current date is evidence of source review, not proof that all examples were executed.

## Agent Loading Rule
Load Level 0 once, then the smallest task route. Deep references are loaded only when:

- the task designs or changes the covered behavior;
- the operating standard lacks enough detail for a safe decision;
- the user requests teaching, architecture analysis, or a comprehensive audit;
- elevated risk requires alternatives, failure modes, or current-source verification.

Do not add this policy or the deep knowledge library to Level 0.

## Maintenance Ownership
The reusable documentation boundary owns this policy and the coverage registry. App-specific deployment targets, supported platforms, exceptions, and acceptance evidence remain in `apps/<AppName>/` or task state.

Update this policy only when the reusable platform scope, authority hierarchy, maturity model, or freshness contract changes.

## Completion Gate
Before claiming the reusable iOS knowledge system complete:

- every mandatory-core domain is `complete` or has an explicit accepted gap;
- every registry path exists and is routed;
- source and review metadata is current for the adopted toolchain;
- context cost remains bounded;
- documentation, boundary, baseline, and registry validators pass;
- a high-risk final review finds no unresolved blocking contradiction.
