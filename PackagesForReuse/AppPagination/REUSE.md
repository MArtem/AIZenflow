# AppPagination Reuse Notes

## Purpose

`AppPagination` is a standalone reusable package for app-independent pagination mechanics: safe collection IDs and cursors, page size/index validation, cursor/offset/page request positions, page load planning, state merging, explicit loader/store boundaries, and actor-backed paginator coordination.

## SwiftPM Usage

Copy this folder into a project's package area and add it as a local package or dependency. The package has no sibling package dependencies and no remote dependencies.

Run package verification before adoption:

```zsh
cd ./PackagesForReuse/AppPagination
./Scripts/verify_package.sh
```

## Source-Only Usage

For source-only integration, copy this package to the target project's active package/source area and add only `Sources/AppPagination/**/*.swift` to the relevant target. Keep `README.md`, `PackageContract.md`, DocC, tests, and `Scripts/verify_package.sh` with the package folder so it remains portable.

## Host Ownership

The package owns pagination mechanics only. Host apps own endpoint semantics, DTO/domain mapping, backend cursor meaning, retry policy, auth/session behavior, user-visible loading/error states, analytics, logging, and durable/distributed state storage.

`AppPaginator` best-effort clears `isLoading` before rethrowing load/merge/save failures. Cursor responses must advance in the requested direction. Offset/page-number backward pagination is intentionally conservative; exact backward anchors after arbitrary refresh positions belong in host policy or cursor pagination.

## Current TchopApp Decision

Vault-only. Current `TchopApp` has no active backend pagination/feed pagination runtime to migrate. The existing feed is local-first and channel-scoped, so connecting `AppPagination` now would add unused infrastructure.
