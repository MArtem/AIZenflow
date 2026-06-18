# AppPagination Package Contract

## Purpose

`AppPagination` provides app-independent pagination primitives and coordination boundaries for Swift applications.

It owns only pagination mechanics:

- safe pagination collection identifiers;
- safe cursor values;
- page size and index validation;
- cursor, offset, and page-number request positions;
- pagination load planning;
- page/state merge behavior;
- an in-memory state store;
- an actor-based paginator boundary.

## Standalone rules

This package must remain single-folder standalone:

1. No `.package(path: "../...")` dependencies.
2. No `.package(url:)` dependencies.
3. No imports of sibling SDK packages.
4. No app-specific or product-specific entities.
5. No feed/news/profile/Tchop-specific logic.
6. All sources, tests, docs, scripts, and fixtures must stay inside `AppPagination/`.
7. Multi-target structure is allowed only inside this package folder.
8. Cross-package integrations must live outside this root package.

## Privacy and diagnostics

Pagination collection identifiers and cursors may represent backend identifiers. Public textual descriptions must not expose their values.

The package must not log or emit:

- collection identifier values;
- cursor values;
- backend response text;
- request payloads;
- file paths;
- application-specific user identifiers.

## Async and execution boundaries

`AppPagination` does not perform networking, database work, file-system work, or logging by itself.

Async work happens through explicit host-provided boundaries:

- `PaginationPageLoader` for loading pages;
- `PaginationStateStore` for state persistence.

The default `InMemoryPaginationStateStore` is actor-isolated and contains no hidden blocking I/O.

`AppPaginator` must not leave `isLoading == true` after a loader, merge, or final save failure. It should best-effort restore a non-loading state before rethrowing the original failure.

Cursor pagination responses must prove forward/backward cursor progress. Returning the same cursor that was used for the request is invalid because it can create an infinite pagination loop.

Offset and page-number previous-loading support is intentionally conservative. Exact backward anchors after arbitrary refresh positions are host policy and should not be guessed by the root package.

## DocC ownership

DocC must stay source-owned:

```text
Sources/AppPagination/Documentation.docc/AppPagination.md
```

Root-level `.docc` bundles are not allowed.

## Verifier scratch path

`Scripts/verify_package.sh` must use a worktree-local scratch path outside the package folder:

```bash
WORKTREE_DIR="$(cd "${PACKAGE_DIR}/.." && pwd)"
SCRATCH_ROOT="${WORKTREE_DIR}/WorktreeScratch/${PACKAGE_NAME}"
```

The verifier must not use `/tmp`, `${TMPDIR}`, `TMPDIR`, or any external scratch path.

The verifier must clean its scratch path and must not leave `.build`, `.swiftpm`, `Package.resolved`, `.DS_Store`, `__MACOSX`, or `xcuserdata` inside the package folder.

The verifier must fail when SwiftPM emits `warning:` or `error:` output.
