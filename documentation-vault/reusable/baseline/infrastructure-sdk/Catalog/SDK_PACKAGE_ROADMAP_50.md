# SDK Package Roadmap — 50 Iterations

This roadmap defines the planned package creation sequence.

## Iteration 0

```text
0. Package Template / SDK Standard
```

## Core infrastructure

```text
1. AppSecureStorage
2. AppSession
3. AppFeatureFlags
4. AppLogging
5. AppObservability
6. AppConnectivity
7. AppPermissions
8. AppEnvironment
9. AppDeviceInfo
10. AppLifecycle
11. AppBackgroundTasks
```

## Storage, files, media

```text
12. AppFileStorage
13. AppImagePipeline
14. AppDownloads
15. AppUploads
16. AppRemoteAssets
```

## Async operation infrastructure

```text
17. AppTaskQueue
18. AppRateLimiter
19. AppStateMachine
```

## Lists, forms, formatting

```text
20. AppPagination
21. AppFormValidation
22. AppValidationCore
23. AppInputFormatting
24. AppDateTime
25. AppNumberFormatting
```

## UX support

```text
26. AppHaptics
27. AppAccessibilitySupport
28. AppReviewPrompt
29. AppEmptyStateKit
30. AppOnboarding
```

## Links, browser, URL, clipboard

```text
31. AppURLSafety
32. AppDeepLinking
33. AppInAppBrowser
34. AppClipboard
```

## Privacy, consent, growth

```text
35. AppPrivacy
36. AppConsent
37. AppABTesting
38. AppCrypto
```

## Diagnostics and production support

```text
39. AppDiagnostics
40. AppPerformance
41. AppCrashReportingCore
```

## Search and text

```text
42. AppSearch
43. AppSortingFiltering
44. AppMarkdown
45. AppHTMLText
```

## Pickers and scanning

```text
46. AppMediaPicker
47. AppDocumentPicker
48. AppQRBarcode
```

## Coordination and final hardening

```text
49. AppCoordinatorSupport
50. Final SDK Hardening / Catalog / Integration Helpers
```

## Priority rationale

The first 10 packages create the runtime/security foundation. Later packages build on the same standards but remain standalone by design.
