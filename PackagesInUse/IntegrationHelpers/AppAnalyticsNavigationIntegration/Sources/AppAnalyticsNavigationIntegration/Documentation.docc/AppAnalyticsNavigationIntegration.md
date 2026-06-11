# ``AppAnalyticsNavigationIntegration``

Optional cross-package integration helper.

## Purpose

Maps navigation diagnostic events into sanitized analytics events.

## Root package isolation

This helper exists outside root packages so root infrastructure packages stay copyable as single folders.

## Required packages

AppAnalytics + AppNavigation

## Privacy

The helper intentionally emits sanitized values only. Do not add raw request/response bodies, headers, notification copy, or raw error descriptions to telemetry output.
