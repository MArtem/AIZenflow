# 03_Module_And_Folder_Structure — Coordinator / Flow Architecture

## 1. Purpose

Этот документ задает структуру файлов для Coordinator / Flow Architecture.

---

## 2. Feature-level Structure

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameView.swift
│   ├── FeatureNameViewModel.swift
│   └── FeatureNameViewState.swift
│
├── Navigation/
│   ├── FeatureNameRoute.swift
│   ├── FeatureNameCoordinator.swift
│   └── FeatureNameRouter.swift
│
└── Assembly/
    └── FeatureNameAssembly.swift
```

---

## 3. App-level Structure

```text
App/
├── Navigation/
│   ├── AppRoute.swift
│   ├── AppCoordinator.swift
│   ├── AppRouter.swift
│   └── DeepLinkParser.swift
│
├── Flows/
│   ├── AuthFlow/
│   ├── OnboardingFlow/
│   ├── MainTabFlow/
│   └── SettingsFlow/
│
└── Assembly/
    └── AppAssembly.swift
```

---

## 4. Route Files

Routes:

```text
FeatureNameRoute.swift
AppRoute.swift
AuthRoute.swift
MainTabRoute.swift
```

Routes should be small, explicit, and stable.

---

## 5. Coordinator Files

```text
AppCoordinator.swift
AuthCoordinator.swift
OnboardingCoordinator.swift
MainTabCoordinator.swift
NewsCoordinator.swift
ProfileCoordinator.swift
```

Coordinator names should include flow/domain.

Avoid:

```text
NavigationManager
RouteHelper
ScreenFactoryManager
```

---

## 6. Router Files

Router can be shared:

```text
NavigationRouter.swift
UIKitRouter.swift
SwiftUINavigationRouter.swift
ModalRouter.swift
```

Router contains navigation mechanics, not flow decisions.

---

## 7. Assembly Files

Feature assembly:

```swift
enum NewsAssembly {
    static func makeFeed(onRoute: @escaping (NewsFeedRoute) -> Void) -> NewsFeedView
    static func makeDetails(articleID: ArticleID) -> ArticleDetailsView
}
```

---

## 8. Deep Link Files

```text
DeepLinkParser.swift
DeepLinkResolver.swift
DeepLinkRouteMapper.swift
```

Deep link parsing should not live inside Views.

---

## 9. Tests Structure

```text
NavigationTests/
├── AppCoordinatorTests.swift
├── DeepLinkParserTests.swift
├── NewsRouteTests.swift
└── AuthFlowTests.swift
```

---

## 10. Forbidden Structure

Avoid:

```text
Views/
├── NewsFeedView.swift   // creates ArticleDetailsView directly
├── ProfileView.swift    // handles auth redirect
└── SettingsView.swift   // parses deep links
```

---

## 11. Rule

```text
Navigation files should express flow ownership, not be random screen factories.
```
