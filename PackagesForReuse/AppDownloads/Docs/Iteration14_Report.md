# InfrastructureSDK Iteration 14 — AppDownloads

## Built package

`AppDownloads` is a single-folder standalone Swift package for app-independent download primitives.

## Scope

Implemented:

- validated `DownloadRequest`;
- `DownloadID`;
- safe file name validation and sanitization;
- directory roles and host-provided directories;
- platform guarded shared container resolver;
- transport protocol;
- default Foundation transport;
- actor-isolated file persistence;
- metadata reads;
- cleanup policy worker;
- download service actor;
- redacted descriptions;
- tests;
- source-owned DocC;
- fail-fast verifier.

## Design decisions

1. Downloads are separated from upload, cache, image pipeline, logging, diagnostics, session, and task queue concerns.
2. File system operations are isolated behind actors because they can block.
3. Full URLs, query strings, fragments, file names, paths, and shared container identifiers are not emitted by package-provided descriptions.
4. Shared container support is compile guarded and remains a host-app entitlement concern.
5. The package has no sibling or remote dependencies.

## Verification expectation

Run:

```bash
cd AppDownloads
./Scripts/verify_package.sh
```

Expected checks:

- structure exists;
- package name matches folder;
- target names match package;
- no root-level DocC;
- no sibling or remote dependencies;
- no sibling imports;
- no build/archive artifacts inside package folder;
- no unresolved placeholders;
- forbidden source patterns rejected;
- `swift test` passes;
- `swift test -Xswiftc -strict-concurrency=complete` passes.

## Known limitation

Native Apple shared container resolution is compile guarded. It can be verified only on Apple SDK toolchains with the required platform availability and host app entitlement setup.
