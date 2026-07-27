# AppRemoteAssets Package Contract

## Package identity

- Package name: `AppRemoteAssets`
- Main target: `AppRemoteAssets`
- Test target: `AppRemoteAssetsTests`
- Product: `.library(name: "AppRemoteAssets", targets: ["AppRemoteAssets"])`

## Standalone guarantee

`AppRemoteAssets` is a root package and must remain single-folder standalone.

Rules:

1. No sibling path dependencies.
2. No remote package dependencies.
3. No imports of sibling SDK packages.
4. No app-specific, product-specific, feed-specific, profile-specific, or news-specific entities.
5. All source, tests, docs, scripts, and fixtures must stay inside the `AppRemoteAssets/` folder.
6. Cross-package composition belongs in optional integration helpers outside this package.

## Responsibility

This package owns remote asset coordination primitives:

- remote asset identity;
- remote asset versions;
- remote asset locations;
- manifest data loading through an explicit transport protocol;
- manifest decoding and validation;
- asset metadata;
- cache policy representation;
- local record comparison;
- fetch plan generation;
- privacy-safe diagnostics.

Manifest and asset URLs must be `https` by default. `http` is allowed only when the host explicitly opts in for a concrete local/development use case.

This package does not own:

- file persistence;
- byte transfer queues;
- image pipelines;
- logging systems;
- analytics systems;
- crash reporting;
- background task registration;
- host app lifecycle wiring.

## Concurrency and execution boundaries

`RemoteAssetManifestService` is an actor. Manifest data loading is performed through the `RemoteAssetManifestDataTransport` protocol. Host apps can provide their own networking implementation. The included Foundation transport is also an actor.

The package must not hide blocking file I/O inside async APIs. This iteration intentionally avoids file-system reads and writes.

## Privacy and security baseline

- Diagnostics must not expose raw asset identifiers by default.
- Diagnostics must not expose raw asset versions by default.
- Diagnostics must not expose checksum values by default.
- URL query and fragment components must be removed before display.
- URL path details must be redacted before display because asset paths can contain product or user identifiers.
- Manifest decoding failures must not include backend payload text.
- Transport failures must not leak backend response content.
- Asset descriptors must not include app-specific meaning.

## DocC ownership

DocC must stay source-owned:

```text
Sources/AppRemoteAssets/Documentation.docc/AppRemoteAssets.md
```

Root-level DocC bundles are not allowed.

## Verifier contract

`Scripts/verify_package.sh` must:

- fail fast;
- verify required structure;
- verify package and target naming consistency;
- reject sibling path dependencies;
- reject remote package dependencies;
- reject sibling SDK imports;
- reject package-local build and archive artifacts;
- reject unresolved placeholder markers;
- reject forbidden source patterns;
- use a worktree-local scratch path outside the package folder;
- clean that scratch path after verification;
- run `swift test`;
- run `swift test -Xswiftc -strict-concurrency=complete`.
- fail when verification output emits compiler `warning:` or `error:` lines.

The scratch path must be worktree-local:

```text
../WorktreeScratch/AppRemoteAssets
```

System scratch locations and environment scratch variables are not part of this package contract.
