# ``AppAnalyticsNetworkingIntegration``

Optional cross-package integration helper.

## Purpose

Maps networking metrics/failures into sanitized analytics events without raw error strings, bodies, headers, tokens, or URL query/fragment.

## Root package isolation

This helper exists outside root packages so root infrastructure packages stay copyable as single folders.

## Required packages

AppAnalytics + AppNetworking

## Privacy

The helper intentionally emits sanitized values only. Do not add raw request/response bodies, headers, notification copy, or raw error descriptions to telemetry output.
