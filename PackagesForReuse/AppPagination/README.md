# AppPagination

`AppPagination` is a standalone Swift package for app-independent pagination mechanics. It provides safe pagination identifiers, cursor/offset/page request primitives, page merge rules, load planning, an in-memory state store, and an actor-based paginator boundary.

The package is intentionally independent from networking, persistence, logging, diagnostics, downloads, uploads, and product-specific UI code. Host apps provide their own `PaginationPageLoader` and can replace the in-memory store through `PaginationStateStore`.

## Guarantees

- Single-folder standalone Swift Package.
- No sibling package imports.
- No remote package dependencies.
- Source-owned DocC at `Sources/AppPagination/Documentation.docc/AppPagination.md`.
- Privacy-safe descriptions: collection identifiers and cursors are redacted by default.
- Async loading happens through explicit protocol boundaries.
- No hidden database, file-system, networking, or logging behavior.

## Core types

- `PaginationCollectionID`
- `PaginationCursor`
- `PageSize`
- `PageIndex`
- `ItemOffset`
- `PaginationRequest`
- `PaginationPage`
- `PaginationState`
- `PaginationLoadPlanner`
- `PaginationPageLoader`
- `PaginationStateStore`
- `InMemoryPaginationStateStore`
- `AppPaginator`

## Example

```swift
import AppPagination

struct Article: Sendable, Equatable {
    let id: String
    let title: String
}

struct ArticleLoader: PaginationPageLoader {
    func loadPage(_ request: PaginationRequest) async throws -> PaginationPage<Article> {
        let items: [Article] = []
        return try PaginationPage(
            items: items,
            request: request,
            nextCursor: nil,
            previousCursor: nil,
            hasMoreForward: false,
            hasMoreBackward: false
        )
    }
}

let collectionID = try PaginationCollectionID("articles")
let paginator = AppPaginator(
    collectionID: collectionID,
    pageSize: try PageSize(20),
    mode: .cursor,
    loader: ArticleLoader(),
    store: InMemoryPaginationStateStore<Article>()
)

let state = try await paginator.loadNext()
```

## Runtime contract

`AppPaginator` marks state as loading before calling the host `PaginationPageLoader`. If loading or merging fails, it best-effort clears `isLoading` before rethrowing the original error so a transient loader failure does not permanently block the collection.

Cursor pages must advance in the requested direction. A `next` response cannot return the same `nextCursor` as the request's `after` cursor, and a `previous` response cannot return the same `previousCursor` as the request's `before` cursor.

Offset and page-number backward pagination are intentionally minimal. Host apps that need exact previous-page offsets after arbitrary refresh positions should store app-specific anchor information outside this root package or use cursor pagination.

## Verification

Run:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder:

```text
../WorktreeScratch/AppPagination
```

It must not use `/tmp`, `${TMPDIR}`, `TMPDIR`, or external scratch paths.
