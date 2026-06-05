# ``AppErrorsNetworkingIntegration``

Optional cross-package integration helper.

## Purpose

Maps networking errors and rich HTTP failures into app-facing error descriptors without raw error leakage.

## Root package isolation

This helper exists outside root packages so root infrastructure packages stay copyable as single folders.

## Required packages

AppErrors + AppNetworking

## Privacy

The helper intentionally emits sanitized values only. Do not add raw request/response bodies, headers, notification copy, or raw error descriptions to telemetry output.
