# 14_Refactoring_Prompt — Coordinator / Flow Architecture

## 1. Purpose

Prompt for refactoring navigation into Coordinator / Flow Architecture.

---

## 2. Full Refactoring Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно отрефакторить navigation code в Coordinator / Flow Architecture.

Сначала найди проблемы:

1. View creates destination screens.
2. ViewModel returns SwiftUI View/UIViewController.
3. ViewModel accesses UINavigationController.
4. Deep links parsed in random screens.
5. Auth redirects duplicated.
6. DTO/DBModel passed through navigation.
7. Modal flow not centralized.
8. Child flow lifecycle unclear.
9. AppCoordinator is God Object.
10. Business logic inside Coordinator.

Then propose incremental migration:

Step 1:
Introduce Route enum with IDs/value objects.

Step 2:
Replace direct destination creation with route intent.

Step 3:
Create FeatureAssembly for destination construction.

Step 4:
Create Coordinator to handle routes.

Step 5:
Move deep link parsing to DeepLinkParser.

Step 6:
Move auth route checks to RouteGuard/Session boundary.

Step 7:
Extract child coordinators for large flows.

Step 8:
Add route/flow tests.

Rules:
- do not rewrite UI behavior
- do not move business logic to Coordinator
- do not pass DTO/DBModel in routes
- keep simple NavigationLink if flow is truly simple
```

---

## 3. Output Format

```text
1. Current navigation problems
2. Target flow structure
3. Route model
4. Migration steps
5. Files to create/change
6. Tests to add
7. Risks
8. Example refactored code
```
