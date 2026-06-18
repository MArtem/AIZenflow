# AppUploads Package Contract

## Identity

- Package name: `AppUploads`
- Primary target: `AppUploads`
- Test target: `AppUploadsTests`
- Package type: standalone Swift Package

## Standalone guarantees

`AppUploads` must remain a single-folder standalone package:

1. No `.package(path: "../...")` dependencies.
2. No `.package(url:)` dependencies.
3. No imports of sibling SDK packages.
4. No app-specific or product-specific entities.
5. No dependency on AppDownloads, AppFileStorage, AppDiagnostics, AppLogging, or any other root package.
6. All sources, tests, docs, scripts, fixtures, and DocC documentation stay inside the `AppUploads/` folder.
7. Multi-target expansion is allowed only if all targets are fully contained inside this package folder.

## Source-owned DocC

DocC must stay under the source target:

```text
Sources/AppUploads/Documentation.docc/AppUploads.md
```

Root-level `.docc` bundles are not allowed.

## Verifier scratch path

`Scripts/verify_package.sh` must use a worktree-local scratch path outside the package folder:

```bash
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
```

The verifier must not use system temporary directories or environment scratch variables. It must clean the worktree-local scratch path after verification.

## Privacy and security contract

`AppUploads` must not expose sensitive upload data by default:

- No full local file paths in public descriptions.
- No upload field values in public descriptions.
- No upload file names in public descriptions.
- URL query and fragment must be removed from redacted URL output.
- The root package must not own credential injection.
- Host apps that need credential-bearing requests must provide a custom transport boundary.
- `UploadRequest` must be `https`-only by default; `http` is allowed only when the host explicitly opts in for a concrete local/development use case.

## Concurrency and I/O contract

- Public async upload APIs must not hide potentially blocking file reads on the caller executor.
- File reads and multipart encoding live behind `UploadBodyLoadWorker`, an actor boundary.
- The Foundation transport is an actor.
- Large streaming uploads are intentionally a host-app transport concern.
- Swift task cancellation must not be collapsed into generic transport failure or retried as an ordinary upload failure.
- Retry sleep must remain injectable for package-owned tests and deterministic host behavior.

## Size and memory baseline

The default body worker prepares payload bytes in memory before transport. Host apps must set `maximumPayloadBytes` for untrusted files, user-selected media, or any upload whose size can grow. Large streaming, resumable, or background uploads require a host-owned transport or dedicated future package.

## Verification requirements

The verifier must fail fast for:

- missing required structure;
- package name and target mismatch;
- root-level DocC bundles;
- sibling path dependencies;
- remote dependencies;
- sibling SDK imports;
- disallowed scratch-path usage;
- package-local build/archive artifacts;
- unresolved placeholders;
- forbidden privacy/concurrency/source patterns;
- `swift test` failures;
- strict concurrency test failures.
- compiler `warning:` or `error:` lines emitted by verification output.
