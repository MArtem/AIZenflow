# ``AppRemoteAssets``

Model, validate, load, and plan remote assets without coupling to an app, file store, downloader, image pipeline, logger, or diagnostics package.

## Overview

`AppRemoteAssets` is a standalone infrastructure package for remote asset manifests and fetch planning.

The package provides:

- ``RemoteAssetID``
- ``RemoteAssetVersion``
- ``RemoteAssetLocation``
- ``RemoteAssetDescriptor``
- ``RemoteAssetManifest``
- ``RemoteAssetManifestRequest``
- ``RemoteAssetManifestDataTransport``
- ``RemoteAssetManifestService``
- ``RemoteAssetLocalRecord``
- ``RemoteAssetFetchPlanner``
- ``RemoteAssetFetchPlan``

It intentionally does not download asset bytes or persist files. Those responsibilities belong to a host app or an optional integration helper.

Manifest and asset URLs are `https`-only by default. Hosts may explicitly allow `http` for concrete local-development or fixture needs.

## Loading a manifest

```swift
let request = try RemoteAssetManifestRequest(
    url: URL(string: "https://example.com/assets/manifest.json")!
)
let service = RemoteAssetManifestService(
    transport: FoundationRemoteAssetManifestDataTransport()
)
let manifest = try await service.loadManifest(request)
```

## Planning fetches

```swift
let plan = RemoteAssetFetchPlanner().makePlan(
    manifest: manifest,
    localRecords: existingRecords,
    now: Date()
)
```

A plan can tell the host app to keep an asset, fetch an asset, or remove a local record that no longer appears in the manifest.

## Privacy

Diagnostic descriptions redact asset identifiers, versions, checksum values, URL path details, query components, and fragments. Use explicit app-level tooling outside this package if a product needs richer observability.
