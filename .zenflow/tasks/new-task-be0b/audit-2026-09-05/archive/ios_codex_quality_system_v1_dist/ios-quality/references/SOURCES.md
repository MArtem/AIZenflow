# Source Baseline

This library intentionally prioritizes primary sources. It is not a verbatim restatement of any one source; it converts platform guidance into an engineering-control system.

Reviewed for v1 on 2026-09-05.

## Codex / instruction loading

1. OpenAI — Unrolling the Codex agent loop
   https://openai.com/index/unrolling-the-codex-agent-loop/
   - `AGENTS.md` / `AGENTS.override.md` hierarchy and finite project-document budget.

2. OpenAI — Introducing Codex
   https://openai.com/index/introducing-codex/
   - AGENTS scope and precedence concepts.

## Swift language / concurrency

3. Swift.org — Swift 6.3 Released
   https://www.swift.org/blog/swift-6.3-released/

4. Swift.org — Swift 6.2 Released
   https://www.swift.org/blog/swift-6.2-released/
   - default MainActor isolation option, caller-context async behavior, `@concurrent`.

5. Swift.org — Enable data-race safety checking
   https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/enabledataracesafety/
   - Swift 6 full data-race safety; strict concurrency settings.

6. Swift.org — Data Race Safety
   https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/dataracesafety/

7. Swift Book — Concurrency
   https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/

8. Swift.org — API Design Guidelines
   https://www.swift.org/documentation/api-design-guidelines/

## Xcode / testing / diagnostics

9. Apple — Xcode 26.6 Release Notes
   https://developer.apple.com/documentation/xcode-release-notes/xcode-26_6-release-notes

10. Apple — Xcode 26 Release Notes
    https://developer.apple.com/documentation/Xcode-Release-Notes/xcode-26-release-notes
    - Swift Testing additions, runtime issue detection, SwiftUI instrument improvements.

11. Apple — Swift Testing
    https://developer.apple.com/documentation/testing

12. Apple — Improving code assessment by organizing tests into test plans
    https://developer.apple.com/documentation/xcode/organizing-tests-to-improve-feedback
    - code coverage, ASan, TSan, Main Thread Checker and other diagnostics.

13. Apple — Diagnosing memory, thread, and crash issues early
    https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early

## SwiftUI / UIKit

14. Apple — Migrating from ObservableObject to Observable
    https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro

15. Apple — Managing model data in your app
    https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app

16. Apple — Implementing modern collection views
    https://developer.apple.com/documentation/uikit/implementing-modern-collection-views

## Performance / observability

17. Apple — Improving app responsiveness
    https://developer.apple.com/documentation/xcode/improving-app-responsiveness

18. Apple — SwiftUI performance analysis
    https://developer.apple.com/documentation/swiftui/performance-analysis

19. Apple — Logging / OSLog
    https://developer.apple.com/documentation/os/logging

20. Apple — MetricKit
    https://developer.apple.com/documentation/metrickit

## Security / privacy

21. OWASP — Mobile Application Security Verification Standard
    https://mas.owasp.org/MASVS/

22. Apple — Security overview
    https://developer.apple.com/security/

23. Apple — NSAppTransportSecurity
    https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity

24. Apple — Protecting keys with the Secure Enclave
    https://developer.apple.com/documentation/security/protecting-keys-with-the-secure-enclave

25. Apple — Adding a privacy manifest
    https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk

26. Apple — Describing use of required reason API
    https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api

27. Apple — Third-party SDK requirements
    https://developer.apple.com/support/third-party-SDK-requirements/

## Accessibility / localization

28. Apple — Accessibility Inspector
    https://developer.apple.com/documentation/accessibility/accessibility-inspector

29. Apple — Localizing and varying text with a string catalog
    https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog

30. Apple — Preparing your app’s text for translation
    https://developer.apple.com/documentation/xcode/preparing-your-apps-text-for-translation

## Swift Package Manager / supply chain

31. SwiftPM — PackageDescription / dependency resolution
    https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

32. Apple — Making dependencies available to Xcode Cloud
    https://developer.apple.com/documentation/xcode/making-dependencies-available-to-xcode-cloud

33. Apple — Building Swift packages/apps in CI
    https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows

34. Apple — Identifying binary dependencies
    https://developer.apple.com/documentation/xcode/identifying-binary-dependencies

## Background execution

35. Apple — BGTaskScheduler
    https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler

## Update policy

Before changing a MUST rule because of a new SDK/toolchain behavior, verify against current primary documentation and record the source/date in this file or the project exception/ADR.
