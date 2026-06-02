# Neutral Package Promotion Guide

## Purpose
Reusable infrastructure copied from an app worktree must be promoted with neutral package, product, target, and symbol names. Source-app prefixes such as `Tchop*` are allowed only in the source app worktree; they are not acceptable in a generic destination project.

## Default Names For New Projects
Use these names unless the destination project already has a documented naming convention:

- `AppInfrastructure` for the root package.
- `AppNetworking` for networking runtime and request/response contracts.
- `AppErrors` or `AppErrorsCore` for reusable error contracts.
- `AppLocalization` for localization lookup mechanisms.
- `AppConfiguration` for runtime/API/session/configuration primitives.
- `AppLogging` for logging/redaction boundaries.
- `AppImageLoading` for image loading, downsampling, cache, and SwiftUI image presentation support.
- `AppCache`, `AppWidgetSupport`, `AppAnalyticsCore`, `AppShareExtensionSupport`, `AppPushNotifications`, `AppDatabaseCore` when those capabilities are needed.

## Non-Negotiable Promotion Rules

1. Copy **source + tests + docs** together. A package without its tests is not considered transferred.
2. Keep packages mechanism-only. App payloads, feature DTOs, copy text, brand variants, widget snapshots, and screen-specific configuration stay in app/feature targets.
3. Keep core/adapters split. Core modules must not import optional platform or sibling runtime modules only to provide convenience mapping.
4. Avoid compatibility wrappers unless they solve an active staged migration problem.
5. Validate with package tests in the destination project before app-level work.

## Minimum Package Documentation
Every reusable package must include:

- `Package.swift` products and target ownership.
- `README.md` explaining module boundaries and tests.
- DocC overview catalog or equivalent public API contract docs.
- Inline public API comments for ownership, side effects, concurrency, errors, and external usage.
