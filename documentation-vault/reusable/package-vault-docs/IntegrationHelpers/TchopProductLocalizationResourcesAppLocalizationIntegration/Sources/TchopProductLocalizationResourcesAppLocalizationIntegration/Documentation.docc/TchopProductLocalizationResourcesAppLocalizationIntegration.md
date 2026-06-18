# ``TchopProductLocalizationResourcesAppLocalizationIntegration``

Optional cross-package integration helper.

## Purpose

Creates AppLocalization managers backed by product-specific resource bundles.

## Root package isolation

This helper exists outside root packages so root infrastructure packages stay copyable as single folders.

## Required packages

TchopProductLocalizationResources + AppLocalization

## Privacy

The helper intentionally emits sanitized values only. Do not add raw request/response bodies, headers, notification copy, or raw error descriptions to telemetry output.
