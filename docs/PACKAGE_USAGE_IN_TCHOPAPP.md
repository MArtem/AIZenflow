# Package Usage In TchopApp

## Purpose

Concrete map of where `TchopApp` uses standalone reusable packages and what must stay in app code.

Use this document when changing package imports, moving functionality between app/package code, or checking whether a feature should use an existing package instead of an app-local helper.

## Core rule

- Generic mechanics belong in `./Packages/<PackageName>` with package-owned docs/tests.
- TchopApp-specific product policy stays in `./TchopApp`, `./TchopShareExtension`, or `./TchopWidgetsExtension`.
- Cross-package composition belongs in app code or `./Packages/IntegrationHelpers`, not inside root package folders.

## Active package usage map

### `AppNetworking`
Used by app services for request execution, auth refresh/retry plumbing, cancellation, and HTTP failure context.

App keeps endpoint definitions, DTO mapping, ReqRes/demo auth policy, localized login copy, and session behavior.

### `AppDatabase`
Used by app persistence/repositories for SwiftData/Core Data execution boundaries.

App keeps schema types, record mapping, bootstrap/seeding, and migration policy.

### `AppLocalization` and `TchopProductLocalizationResources`
Used by app/share/widget localization composition. `AppLocalization` owns lookup mechanics; `TchopProductLocalizationResources` owns TchopApp product strings.

App keeps key taxonomy, product copy decisions, and UI placement.

### `AppBranding` and `AppGlassUI`
`AppBranding` owns semantic brand and glass style tokens. `AppGlassUI` owns SwiftUI Liquid Glass availability/fallback mechanics.

App keeps where glass is used, target-specific theme selection, accessibility, layout, and interaction behavior.

### `AppWidgetSupport`
Used by app/widget bridge for generic widget snapshot storage.

App keeps feed headline payload shape and widget timeline composition.

### `AppShareExtensionSupport`
Used by app/share extension for app-group JSON handoff and imported item intake.

App keeps feed-card draft models, composer rules, publish/sync policy, and extension authentication gating.

### `AppConfiguration`
Used by app shell configuration to keep snapshot, source, stale, and refresh metadata mechanics reusable.

App keeps shell payload semantics and fallback policy.

### `AppPushNotifications`
Used by application delegate and bridge for APNs registration/payload mechanics.

App keeps route handling, session requirements, and product-specific push behavior.

### `AppNavigation`
Used by coordinator/deep-link/root-tab code for generic navigation primitives and snapshot contracts.

App keeps `AppTab`, route payloads, and deep-link semantics.

### `AppAnalytics` plus `IntegrationHelpers`
Used by app dependency composition for analytics event primitives and optional navigation/networking/push adapters.

App keeps event taxonomy, instrumentation decisions, redaction policy, and which adapters are enabled.

### `AppAppleAuthentication`
Used by auth service/login flow for Sign in with Apple mechanics.

App keeps session creation, account linking, and user-facing login behavior.

### `AppErrors`
Used by app error manager and view models for reusable error taxonomy/mapping surfaces.

App keeps final localized messages, support copy, and feature-specific error presentation.

### `AppOnDeviceAI`
Used by feed models/view models and composer paths for local translation capabilities.

App keeps which feed fields are translated, UI state, and language-selection behavior.

## Stop list

Do not reintroduce these app-local mechanics if an active package already owns them:

- custom URLSession/retry/cancellation clients outside `AppNetworking`;
- generic cache expiration/file cleanup outside `AppCache`;
- generic localized bundle lookup outside `AppLocalization`;
- Liquid Glass availability wrappers outside `AppGlassUI`;
- generic widget snapshot storage outside `AppWidgetSupport`;
- generic app-group JSON handoff outside `AppShareExtensionSupport`;
- generic APNs state/payload parsing outside `AppPushNotifications`;
- generic route/snapshot primitives outside `AppNavigation`.

## Verification after package usage changes

```bash
./Packages/verify_single_folder_standalone.sh
./Packages/verify_everything.sh
plutil -lint ./TchopApp.xcodeproj/project.pbxproj
git diff --check
./scripts/verify.sh low
```
