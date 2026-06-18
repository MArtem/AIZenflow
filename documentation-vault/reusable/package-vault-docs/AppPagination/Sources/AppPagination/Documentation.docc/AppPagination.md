# ``AppPagination``

Standalone pagination primitives for Swift applications.

## Overview

`AppPagination` models pagination as a small set of app-independent value types and explicit async boundaries.

Use it when a feature needs cursor, offset, or page-number pagination while keeping networking, database persistence, analytics, logging, and UI concerns outside the root package.

## Topics

### Identifiers

- ``PaginationCollectionID``
- ``PaginationCursor``

### Request positions

- ``PaginationPosition``
- ``PaginationDirection``
- ``PaginationRequest``
- ``PaginationMode``

### Numeric constraints

- ``PageSize``
- ``PageIndex``
- ``ItemOffset``

### Pages and state

- ``PaginationPage``
- ``PaginationState``
- ``PaginationMergePolicy``
- ``PaginationMerger``

### Loading

- ``PaginationLoadPlanner``
- ``PaginationLoadPlan``
- ``PaginationPageLoader``
- ``PaginationStateStore``
- ``InMemoryPaginationStateStore``
- ``AppPaginator``

## Privacy

Collection identifiers and cursors are redacted in textual descriptions. Host apps that need richer diagnostics should create their own privacy review and redaction layer outside this root package.

## Failure and loading state

`AppPaginator` best-effort clears `isLoading` before rethrowing loader, merge, or final-save failures. Host apps still own user-visible retry/error behavior.

## Cursor progress

Cursor responses must advance in the requested direction. Returning the same cursor used by the request is rejected to avoid infinite pagination loops.
