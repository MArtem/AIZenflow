# AppDownloads Package Contract

## Package identity

- Package folder: `AppDownloads`
- Swift package name: `AppDownloads`
- Product: `AppDownloads`
- Main target: `AppDownloads`
- Test target: `AppDownloadsTests`

## Purpose

`AppDownloads` provides app-independent download primitives and persistence boundaries that can be reused in iOS, macOS, tvOS, and watchOS projects.

It covers:

- request validation;
- secure-by-default URL scheme validation;
- safe destination file names;
- directory roles;
- atomic writes;
- metadata access;
- cleanup policies;
- transport abstraction;
- redacted textual diagnostics.

## Explicit non-goals

This package does not provide:

- app-specific business logic;
- UI components;
- image decoding or resizing;
- cache orchestration;
- analytics;
- logging integration;
- crash reporting integration;
- session management;
- retry queues;
- upload support.

Those belong to separate root packages or optional integration helpers.

## Standalone rules

The package must remain single-folder standalone:

1. No sibling path dependencies.
2. No remote package dependencies.
3. No imports of sibling SDK packages.
4. No app/product-specific entities.
5. All sources, tests, docs, and scripts live inside this folder.
6. DocC lives at `Sources/AppDownloads/Documentation.docc/AppDownloads.md`.
7. Cross-package composition must be placed in optional IntegrationHelpers outside this root package.

## Privacy baseline

The package must not expose raw operational identifiers through diagnostics or string descriptions. In particular:

- URL query and fragment components are removed from redacted URL summaries;
- full file paths are not printed by package-provided descriptions;
- file names are redacted by package-provided descriptions;
- shared container identifiers are redacted by package-provided descriptions;
- backend response data is not included in errors.

`DownloadRequest` must be `https`-only by default. `http` is allowed only when the host app explicitly includes it in the allowed scheme set for a concrete development/local use case.

## Concurrency baseline

Potentially blocking file system work must remain behind dedicated actors. `DownloadService` may expose async APIs, but it delegates file system work to `DownloadFileSystemWorker` and cleanup work to `DownloadCleanupWorker`.

Swift task cancellation must not be collapsed into generic transport failure.

## Size and memory baseline

The default Foundation transport stores response data in memory before persistence. Host apps must set `maximumAllowedBytes` for any untrusted or potentially large download. Large streaming, resumable, or background downloads require a host-owned transport or a dedicated future package.

## Host app responsibilities

The host app owns:

- choosing directories and policies;
- requesting any entitlements or platform capabilities;
- mapping package errors to user-facing copy;
- showing progress and retry UI;
- deciding whether downloaded data may be retained;
- integrating with logging, diagnostics, analytics, background tasks, or connectivity packages.

## Verifier contract

`Scripts/verify_package.sh` must be executable and fail fast. It must check package structure, package identity, standalone constraints, source-owned DocC, forbidden source patterns, package-local artifacts, regular tests, and strict concurrency tests.

The verifier must use a worktree-local scratch path outside the package folder:

```bash
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
```

The scratch directory must be removed after verification.

Verification must fail when SwiftPM output emits compiler `warning:` or `error:` lines.
