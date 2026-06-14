# AppRemoteAssets

`AppRemoteAssets` is a standalone Swift package for app-independent remote asset coordination.

It does not store files, render images, perform logging, or compose with sibling SDK packages. Its job is to model remote asset manifests, validate asset identity and versions, load manifest data through an explicit transport boundary, and produce a fetch plan that a host app can execute with its own storage and transfer stack.

## Goals

- Safe remote asset identifiers and versions.
- HTTPS-only manifest and asset locations by default, with explicit host opt-in for HTTP.
- Query/fragment redaction for URLs shown in diagnostics.
- Manifest validation with duplicate asset detection.
- Remote asset descriptors with kind, media type, expected byte count, checksum, and cache policy.
- Actor-based manifest loading service.
- Transport abstraction for host-provided networking.
- Optional Foundation URLSession manifest data transport.
- Fetch planning from manifest state plus host-owned local records.
- No dependency on AppDownloads, AppFileStorage, AppLogging, or AppDiagnostics.

`http` is accepted only when the host explicitly includes it in `allowedSchemes`, for example for local development fixtures. Manifest and asset URLs should be `https` in production.

## Minimal usage

```swift
import AppRemoteAssets
import Foundation

let manifestRequest = try RemoteAssetManifestRequest(
    url: URL(string: "https://example.com/assets/manifest.json?signature=redacted")!,
    maximumResponseBytes: 1_000_000
)

let transport = FoundationRemoteAssetManifestDataTransport()
let service = RemoteAssetManifestService(transport: transport)
let manifest = try await service.loadManifest(manifestRequest)

let plan = RemoteAssetFetchPlanner().makePlan(
    manifest: manifest,
    localRecords: [],
    now: Date()
)

for action in plan.actions {
    switch action {
    case .fetch(let asset, let reason):
        print("Fetch asset with reason: \(reason). URL: \(asset.location.redactedURLString)")
    case .keep:
        break
    case .removeLocal:
        break
    }
}
```

## Manifest model

```swift
let asset = try RemoteAssetDescriptor(
    id: try RemoteAssetID("hero.image"),
    version: try RemoteAssetVersion("2026.06.01"),
    location: try RemoteAssetLocation(url: URL(string: "https://example.com/assets/hero.png?signature=abc")!),
    kind: .image,
    mediaType: .png,
    expectedByteCount: 250_000,
    checksum: try RemoteAssetChecksum(algorithm: .sha256, value: String(repeating: "a", count: 64)),
    cachePolicy: .immutable
)

let manifest = try RemoteAssetManifest(
    schemaVersion: try RemoteAssetVersion("1"),
    generatedAt: Date(),
    assets: [asset]
)
```

## Privacy baseline

Descriptions and debug-facing strings redact identifiers, versions, checksum values, URL path details, and URL query/fragment components. The package does not expose raw asset bytes in diagnostics. The host app remains responsible for its own telemetry, persistence, and transfer execution policies.

## Boundaries

This package intentionally does not include:

- File storage.
- Image decoding or transformation.
- Background scheduling.
- Download queue execution.
- App-specific asset names or product-specific manifest fields.
- Cross-package composition.

Use an integration helper outside this package if a project wants to connect remote asset plans to downloads, file storage, analytics, or logging.

## Verification

Run:

```bash
./Scripts/verify_package.sh
```

The verifier copies the package to `../WorktreeScratch/AppRemoteAssets`, runs tests, runs strict concurrency tests, and removes the scratch copy after completion.
