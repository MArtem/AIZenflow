# ``AppAnalyticsPushNotificationsIntegration``

Optional cross-package integration helper.

## Purpose

Maps push notification lifecycle events into analytics without logging raw notification titles or body text.

## Root package isolation

This helper exists outside root packages so root infrastructure packages stay copyable as single folders.

## Required packages

AppAnalytics + AppPushNotifications

## Privacy

The helper intentionally emits sanitized values only. Do not add raw request/response bodies, headers, notification copy, or raw error descriptions to telemetry output.
